import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/exceptions/app_exception.dart';
import '../core/prompts.dart';
import '../core/utils/document_analysis_normalizer.dart';
import '../core/utils/json_parse_utils.dart';
import '../pages/documents/models/document_analysis_model.dart';

class GeminiService extends GetxService {
  static const _defaultModel = 'gemini-2.5-flash-lite';
  static const _secondaryModel = 'gemini-2.5-flash';

  late final String _apiKey;
  late final String _primaryModel;

  @override
  void onInit() {
    super.onInit();
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw AppException('GEMINI_API_KEY is not configured in .env');
    }
    _apiKey = apiKey;
    final envModel = dotenv.env['GEMINI_MODEL']?.trim();
    _primaryModel = _resolvePrimaryModel(envModel);
    if (kDebugMode) {
      debugPrint('[Gemini] PDF parser model: $_primaryModel');
    }
  }

  /// Unstable aliases (e.g. gemini-flash-latest) often return truncated JSON.
  String _resolvePrimaryModel(String? envModel) {
    if (envModel == null || envModel.isEmpty) return _defaultModel;
    final lower = envModel.toLowerCase();
    if (lower.contains('flash-latest') ||
        lower.contains('1.5') ||
        lower.contains('2.0-flash')) {
      return _defaultModel;
    }
    return envModel;
  }

  Future<String> generateText(String prompt) async {
    final models = <String>{
      _primaryModel,
      _defaultModel,
      _secondaryModel,
    }.toList();

    Object? lastError;
    for (final modelName in models) {
      try {
        return await _generateTextWithModel(modelName, prompt);
      } on GenerativeAIException catch (e) {
        lastError = e;
        if (_isQuotaExceeded(e)) {
          throw AppException('error_gemini_quota'.tr);
        }
        if (_isModelNotFound(e) || _isTransientError(e)) continue;
        throw _mapApiException(e);
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError is AppException) throw lastError;
    if (lastError is GenerativeAIException) throw _mapApiException(lastError);
    throw AppException('error_gemini_parse'.tr);
  }

  Future<String> _generateTextWithModel(String modelName, String prompt) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1500,
      ),
    );

    final response = await model.generateContent([Content.text(prompt)]);
    _ensureResponseUsable(response);

    final text = _extractResponseText(response);
    if (text == null || text.trim().isEmpty) {
      throw AppException('error_gemini_empty'.tr);
    }
    return text.trim();
  }

  Future<DocumentAnalysisModel> runDocumentParserAgent(
    Uint8List pdfBytes,
    String fileName, {
    void Function(double)? onProgress,
  }) async {
    // Max ~3 API calls per PDF — avoids burning free-tier quota on retry loops.
    final attempts = <({String model, String prompt})>[
      (model: _primaryModel, prompt: AppPrompts.documentParser),
      (model: _primaryModel, prompt: AppPrompts.documentParserCompact),
      if (_primaryModel != _defaultModel)
        (model: _defaultModel, prompt: AppPrompts.documentParserCompact)
      else if (_primaryModel != _secondaryModel)
        (model: _secondaryModel, prompt: AppPrompts.documentParserCompact),
    ];

    Object? lastError;

    for (final attempt in attempts) {
      try {
        return await _runDocumentParserWithModel(
          modelName: attempt.model,
          pdfBytes: pdfBytes,
          fileName: fileName,
          prompt: attempt.prompt,
          jsonMode: true,
          onProgress: onProgress,
        );
      } on AppException catch (e) {
        lastError = e;
        if (_isQuotaAppException(e)) rethrow;
        if (kDebugMode) {
          debugPrint('[Gemini] ${attempt.model} parse: ${e.message}');
        }
      } on GenerativeAIException catch (e) {
        lastError = e;
        if (_isQuotaExceeded(e)) {
          throw AppException('error_gemini_quota'.tr);
        }
        if (_isTransientError(e)) {
          throw AppException('error_gemini_unavailable'.tr);
        }
        if (_isModelNotFound(e)) continue;
        throw _mapApiException(e);
      } catch (e) {
        lastError = e;
        if (kDebugMode) debugPrint('[Gemini] ${attempt.model} error: $e');
      }
    }

    if (lastError is AppException) throw lastError;
    if (lastError is GenerativeAIException) throw _mapApiException(lastError);
    throw AppException('error_gemini_parse'.tr);
  }

  bool _isQuotaAppException(AppException e) {
    return e.message == 'error_gemini_quota'.tr;
  }

  Future<DocumentAnalysisModel> _runDocumentParserWithModel({
    required String modelName,
    required Uint8List pdfBytes,
    required String fileName,
    required String prompt,
    required bool jsonMode,
    void Function(double progress)? onProgress,
  }) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: jsonMode ? 'application/json' : null,
        temperature: 0.1,
        maxOutputTokens: 4096,
      ),
    );

    final buffer = StringBuffer();
    var chunkCount = 0;

    try {
      final stream = model.generateContentStream([
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', pdfBytes),
        ]),
      ]);

      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null) {
          buffer.write(text);
          chunkCount++;
          final estimated =
              (0.35 + (chunkCount / 80) * 0.55).clamp(0.35, 0.90);
          onProgress?.call(estimated);
        }

        if (chunk.candidates.isNotEmpty) {
          final reason = chunk.candidates.first.finishReason;
          if (reason == FinishReason.safety ||
              reason == FinishReason.recitation) {
            throw AppException('error_gemini_blocked'.tr);
          }
        }
      }
    } on GenerativeAIException {
      rethrow;
    }

    final rawText = buffer.toString().trim();
    if (rawText.isEmpty) throw AppException('error_gemini_empty'.tr);

    if (kDebugMode) {
      debugPrint(
        '[Gemini] $modelName chunks=$chunkCount len=${rawText.length}',
      );
    }

    try {
      final jsonMap = JsonParseUtils.decodeJsonObject(rawText);
      var analysis = DocumentAnalysisModel.fromJson(jsonMap);
      if (!analysis.hasMeaningfulData) {
        analysis = _applyFileNameFallback(analysis, fileName);
      }
      if (!analysis.hasMeaningfulData) {
        throw AppException('error_gemini_parse'.tr);
      }
      final normalized = DocumentAnalysisNormalizer.normalize(
        analysis,
        fileName: fileName,
      );
      if (kDebugMode) {
        final expenses = normalized.transactions
            .where((t) => t.type == 'expense')
            .length;
        debugPrint(
          '[Gemini] parsed tx=${normalized.transactions.length} '
          'expenses=$expenses totalExpense=${normalized.totalExpense}',
        );
      }
      return normalized;
    } on FormatException {
      throw AppException('error_gemini_parse'.tr);
    }
  }

  DocumentAnalysisModel _applyFileNameFallback(
    DocumentAnalysisModel analysis,
    String fileName,
  ) {
    final baseName = fileName
        .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
        .trim();
    if (baseName.isEmpty) return analysis;

    return analysis.copyWith(
      documentTitle: analysis.documentTitle.isNotEmpty
          ? analysis.documentTitle
          : baseName,
    );
  }

  void _ensureResponseUsable(GenerateContentResponse response) {
    final feedback = response.promptFeedback;
    if (feedback?.blockReason != null) {
      throw AppException('error_gemini_blocked'.tr);
    }

    if (response.candidates.isEmpty) return;

    final reason = response.candidates.first.finishReason;
    if (reason == FinishReason.safety || reason == FinishReason.recitation) {
      throw AppException('error_gemini_blocked'.tr);
    }
  }

  String? _extractResponseText(GenerateContentResponse response) {
    try {
      final direct = response.text;
      if (direct != null && direct.trim().isNotEmpty) return direct;
    } on GenerativeAIException {
      // Fall through to manual part extraction.
    }

    final buffer = StringBuffer();
    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is TextPart && part.text.trim().isNotEmpty) {
          buffer.writeln(part.text);
        }
      }
    }
    final combined = buffer.toString().trim();
    return combined.isEmpty ? null : combined;
  }

  bool _isModelNotFound(GenerativeAIException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('not found') ||
        msg.contains('not_found') ||
        msg.contains('is not supported');
  }

  bool _isQuotaExceeded(GenerativeAIException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('quota') ||
        msg.contains('rate limit') ||
        msg.contains('429') ||
        msg.contains('resource_exhausted') ||
        msg.contains('exceeded your current quota');
  }

  bool _isTransientError(GenerativeAIException e) {
    if (e is ServerException) return true;
    final msg = e.message.toLowerCase();
    return msg.contains('503') ||
        msg.contains('500') ||
        msg.contains('502') ||
        msg.contains('504') ||
        msg.contains('unavailable') ||
        msg.contains('overloaded') ||
        msg.contains('deadline') ||
        msg.contains('internal error') ||
        msg.contains('try again');
  }

  AppException _mapApiException(GenerativeAIException e) {
    if (e is InvalidApiKey) {
      return AppException('error_gemini_api_key'.tr);
    }
    if (_isQuotaExceeded(e)) {
      return AppException('error_gemini_quota'.tr);
    }
    if (_isTransientError(e)) {
      return AppException('error_gemini_unavailable'.tr);
    }
    final msg = e.message.toLowerCase();
    if (msg.contains('location') || msg.contains('region')) {
      return AppException('error_gemini_region'.tr);
    }
    return AppException('error_gemini_parse'.tr);
  }
}
