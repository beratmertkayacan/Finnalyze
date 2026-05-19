import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/document_analysis_normalizer.dart';
import '../core/utils/document_fingerprint.dart';
import '../pages/documents/models/document_analysis_model.dart';
import '../pages/documents/models/stored_document_model.dart';
import 'gemini_service.dart';
import 'pdf_file_service.dart';

class DocumentStorageService extends GetxService {
  static const _storageKey = 'analyzed_documents';

  final _box = GetStorage();
  final documents = <StoredDocumentModel>[].obs;

  static const _legacyMockIds = {'2', '3', '4', '5', '6'};

  @override
  void onInit() {
    super.onInit();
    _initStorage();
  }

  Future<void> _initStorage() async {
    await PdfFileService.init();
    _loadFromStorage();
    await _repairStoredPdfPaths();
    purgeLegacyMockEntries();
    deduplicateByFingerprint();
  }

  List<StoredDocumentModel> get creditCardStatements =>
      documents.where((doc) => doc.analysis.isCreditCard).toList();

  /// Non–credit-card documents for the home "recent" list (avoids duplicate with KK section).
  List<StoredDocumentModel> get recentNonCreditCardDocuments => documents
      .where((doc) => !doc.analysis.isCreditCard)
      .toList();

  bool hasDuplicate(Uint8List pdfBytes) {
    final fingerprint = DocumentFingerprint.fromPdfBytes(pdfBytes);
    return findByFingerprint(fingerprint) != null;
  }

  StoredDocumentModel? findByFingerprint(String fingerprint) {
    if (fingerprint.isEmpty) return null;
    for (final doc in documents) {
      if (doc.contentFingerprint == fingerprint) return doc;
    }
    return null;
  }

  Future<void> saveDocument({
    required String id,
    required DocumentAnalysisModel analysis,
    required String fileName,
    Uint8List? pdfBytes,
    String? localPath,
  }) async {
    var resolvedPath = localPath;
    if (pdfBytes != null) {
      resolvedPath =
          await PdfFileService.persistPdf(id, pdfBytes) ?? resolvedPath;
    }
    resolvedPath ??= await PdfFileService.resolvePath(id, localPath);

    final fingerprint =
        pdfBytes != null ? DocumentFingerprint.fromPdfBytes(pdfBytes) : '';

    final normalized = DocumentAnalysisNormalizer.normalize(
      analysis,
      fileName: fileName,
    );

    final existing = findById(id);
    final duplicateIndex = fingerprint.isEmpty
        ? -1
        : documents.indexWhere(
            (doc) => doc.contentFingerprint == fingerprint,
          );
    final previous = duplicateIndex >= 0
        ? documents[duplicateIndex]
        : existing;

    final stored = StoredDocumentModel(
      id: id,
      analysis: normalized,
      fileName: fileName,
      uploadedAt: previous?.uploadedAt ?? DateTime.now(),
      localPath: resolvedPath,
      contentFingerprint: fingerprint,
      customTitle: previous?.customTitle,
      customPeriod: previous?.customPeriod,
    );

    if (duplicateIndex >= 0) {
      documents[duplicateIndex] = stored;
    } else {
      final index = documents.indexWhere((doc) => doc.id == id);
      if (index >= 0) {
        documents[index] = stored;
      } else {
        documents.insert(0, stored);
      }
    }

    deduplicateByFingerprint();
    _persist();
  }

  StoredDocumentModel? findById(String id) {
    for (final doc in documents) {
      if (doc.id == id) return doc;
    }
    return null;
  }

  DocumentAnalysisModel? analysisById(String id) => findById(id)?.analysis;

  Future<void> updateDocument({
    required String id,
    String? customTitle,
    String? customPeriod,
  }) async {
    final index = documents.indexWhere((doc) => doc.id == id);
    if (index < 0) return;
    final doc = documents[index];
    final title = customTitle?.trim();
    final period = customPeriod?.trim();
    documents[index] = doc.copyWith(
      customTitle: title == null || title.isEmpty ? null : title,
      customPeriod: period == null || period.isEmpty ? null : period,
      clearCustomTitle: title == null || title.isEmpty,
      clearCustomPeriod: period == null || period.isEmpty,
    );
    _persist();
  }

  Future<void> deleteDocument(String id) async {
    final doc = findById(id);
    if (doc == null) return;

    await PdfFileService.deleteForDocument(id, doc.localPath);
    documents.removeWhere((item) => item.id == id);
    _persist();
  }

  Future<void> reload() async {
    await PdfFileService.init();
    _loadFromStorage();
    await _repairStoredPdfPaths();
    deduplicateByFingerprint();
  }

  /// Re-runs Gemini when PDF file exists but analysis JSON is empty or stale.
  Future<bool> reanalyzeDocument(String id) async {
    final doc = findById(id);
    if (doc == null) return false;

    final bytes = await PdfFileService.readBytes(id, doc.localPath);
    if (bytes == null) return false;

    final gemini = Get.find<GeminiService>();
    final analysis = await gemini.runDocumentParserAgent(bytes, doc.fileName);
    final path = await PdfFileService.resolvePath(id, doc.localPath);

    await saveDocument(
      id: id,
      analysis: analysis,
      fileName: doc.fileName,
      pdfBytes: bytes,
      localPath: path,
    );
    return true;
  }

  Future<void> _repairStoredPdfPaths() async {
    var changed = false;
    final repaired = <StoredDocumentModel>[];

    for (final doc in documents) {
      final path = await PdfFileService.resolvePath(doc.id, doc.localPath);
      if (path != doc.localPath) {
        changed = true;
        repaired.add(
          doc.copyWith(localPath: path),
        );
      } else {
        repaired.add(doc);
      }
    }

    if (changed) {
      documents.assignAll(repaired);
      _persist();
    }
  }

  void purgeLegacyMockEntries() {
    final before = documents.length;
    documents.removeWhere((doc) => _legacyMockIds.contains(doc.id));
    if (documents.length != before) {
      _persist();
    }
  }

  /// Keeps the newest upload when the same PDF was saved more than once.
  void deduplicateByFingerprint() {
    final seen = <String, StoredDocumentModel>{};
    for (final doc in documents) {
      if (doc.contentFingerprint.isEmpty) {
        seen[doc.id] = doc;
        continue;
      }
      final existing = seen[doc.contentFingerprint];
      if (existing == null || doc.uploadedAt.isAfter(existing.uploadedAt)) {
        seen[doc.contentFingerprint] = doc;
      }
    }

    final unique = seen.values.toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    if (unique.length != documents.length) {
      documents.assignAll(unique);
      _persist();
    }
  }

  void _loadFromStorage() {
    final raw = _box.read<String>(_storageKey);
    if (raw == null || raw.isEmpty) {
      documents.clear();
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        documents.clear();
        return;
      }

      documents.assignAll(
        decoded.whereType<Map>().map((item) {
          final doc = StoredDocumentModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          final normalized = DocumentAnalysisNormalizer.normalize(
            doc.analysis,
            fileName: doc.fileName,
          );
          return doc.copyWith(analysis: normalized);
        }).toList(),
      );
      _persist();
    } catch (_) {
      documents.clear();
    }
  }

  void _persist() {
    final encoded = jsonEncode(documents.map((doc) => doc.toJson()).toList());
    _box.write(_storageKey, encoded);
  }
}
