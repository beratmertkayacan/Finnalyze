import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/document_fingerprint.dart';
import '../../../../core/utils/pdf_upload_validator.dart';
import '../../../../routes/routes.dart';
import '../../../../services/document_storage_service.dart';
import '../../../../services/pdf_file_service.dart';
import '../../../../services/gemini_service.dart';
import '../../../home/controllers/home_controller.dart';
import '../../models/document_analysis_model.dart';
import '../../models/document_detail_args.dart';
import '../../models/stored_document_model.dart';
import '../models/upload_recent_item_model.dart';
import '../utils/recent_document_display.dart';
import '../views/pdf_preview_view.dart';
import '../widgets/document_name_sheet.dart';
import '../widgets/upload_source_sheet.dart';

enum UploadStep { choose, review, analyze }

class DocumentUploadController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  late final GeminiService _geminiService;
  late final DocumentStorageService _storage;

  // 2. Reactive state
  final isLoading = false.obs;
  final isAnalyzing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final currentStep = UploadStep.choose.obs;
  final analysisProgress = 0.0.obs;
  final isParsing = false.obs;

  final selectedFileName = RxnString();
  final selectedFileSizeLabel = RxnString();
  final selectedSourceIsPhoto = false.obs;
  final selectedLocalPath = RxnString();

  final activeAnalysisDocument = Rxn<UploadRecentItemModel>();
  final allDocuments = <UploadRecentItemModel>[].obs;
  final showAllHistory = false.obs;

  static const int _collapsedHistoryCount = 2;

  // 5. Getters
  /// All items for Belgeler / Analiz tabs: analyzing & errors always visible.
  List<UploadRecentItemModel> get visibleDocuments {
    final sorted = List<UploadRecentItemModel>.from(allDocuments)
      ..sort(compareByStatus);

    if (showAllHistory.value) return sorted;

    final pending =
        sorted.where((d) => d.status != UploadScanStatus.complete).toList();
    final completed = sorted
        .where((d) => d.status == UploadScanStatus.complete)
        .take(_collapsedHistoryCount)
        .toList();
    return [...pending, ...completed];
  }

  bool get canExpandHistory {
    final completedCount =
        allDocuments.where((d) => d.status == UploadScanStatus.complete).length;
    return completedCount > _collapsedHistoryCount ||
        allDocuments.any((d) => d.status != UploadScanStatus.complete);
  }

  static int compareByStatus(
    UploadRecentItemModel a,
    UploadRecentItemModel b,
  ) {
    int order(UploadScanStatus s) => switch (s) {
          UploadScanStatus.analyzing => 0,
          UploadScanStatus.error => 1,
          UploadScanStatus.complete => 2,
        };
    final byStatus = order(a.status).compareTo(order(b.status));
    if (byStatus != 0) return byStatus;
    return b.id.compareTo(a.id);
  }

  UploadRecentItemModel? documentById(String? id) {
    if (id == null) return null;
    for (final doc in allDocuments) {
      if (doc.id == id) return doc;
    }
    if (activeAnalysisDocument.value?.id == id) {
      return activeAnalysisDocument.value;
    }
    return null;
  }

  // 6. Lifecycle
  @override
  void onInit() {
    super.onInit();
    _geminiService = Get.find<GeminiService>();
    _loadDocumentHistory();
  }

  // 7. Public methods
  void onBackTap() {
    if (isAnalyzing.value) return;
    Get.back();
  }

  void onDropZoneTap() => showUploadSourceSheet();

  void onBrowseTap() => pickAndAnalyze();

  void onScanTap() => showScanSourceSheet();

  void toggleShowAllHistory() => showAllHistory.toggle();

  void onDocumentDeleted(String id) {
    allDocuments.removeWhere((doc) => doc.id == id);
    if (activeAnalysisDocument.value?.id == id) {
      activeAnalysisDocument.value = null;
    }
    _syncHistoryFromStorage();
  }

  Future<void> pickAndAnalyze() async {
    if (isAnalyzing.value) return;

    hasError(false);
    errorMessage('');

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (!_validateFileSize(file.size)) return;

      final pdfBytes = await _readPdfBytes(file);
      if (pdfBytes == null) {
        _showUploadError(
          fileName: file.name,
          sizeBytes: file.size,
        );
        return;
      }

      if (!_validatePdfForAnalysis(
        fileName: file.name,
        sizeBytes: file.size,
        pdfBytes: pdfBytes,
      )) {
        return;
      }

      if (_storage.hasDuplicate(pdfBytes)) {
        _showError('upload_duplicate_file'.tr);
        return;
      }

      await _runGeminiAnalysis(
        pdfBytes: pdfBytes,
        fileName: file.name,
        sizeBytes: file.size,
        localPath: file.path,
      );
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _handlePickError(e);
    }
  }

  void openStoredDocumentDetail(UploadRecentItemModel document) {
    if (document.status != UploadScanStatus.complete) return;

    if (_storage.findById(document.id) != null) {
      Get.toNamed(
        AppRoutes.documentDetail,
        arguments: DocumentDetailArgs(documentId: document.id),
      );
      return;
    }

    _showError('doc_detail_not_found'.tr);
  }

  Future<void> openPdfPreview(UploadRecentItemModel document) async {
    if (document.status != UploadScanStatus.complete) return;

    final stored = _storage.findById(document.id);
    final path = await PdfFileService.resolvePath(
      document.id,
      stored?.localPath ?? document.localPath,
    );

    if (path == null) {
      _showError('doc_preview_unavailable'.tr);
      return;
    }

    Get.to(
      () => PdfPreviewView(
        filePath: path,
        title: stored?.displayTitle ?? document.title,
      ),
      fullscreenDialog: true,
    );
  }

  Future<void> showUploadSourceSheet() async {
    await Get.bottomSheet<void>(
      UploadSourceSheet(
        titleKey: 'upload_source_sheet_title',
        onBrowse: () {
          Get.back();
          pickAndAnalyze();
        },
        onCamera: () {
          Get.back();
          pickPhoto(ImageSource.camera);
        },
        onGallery: () {
          Get.back();
          pickPhoto(ImageSource.gallery);
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> showScanSourceSheet() async {
    await Get.bottomSheet<void>(
      UploadSourceSheet(
        titleKey: 'upload_scan_sheet_title',
        showBrowse: false,
        onCamera: () {
          Get.back();
          pickPhoto(ImageSource.camera);
        },
        onGallery: () {
          Get.back();
          pickPhoto(ImageSource.gallery);
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> pickPhoto(ImageSource source) async {
    hasError(false);
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      final file = File(image.path);
      final sizeBytes = await file.length();
      if (!_validateFileSize(sizeBytes)) return;

      Get.snackbar(
        'upload_title'.tr,
        'upload_pdf_only_for_analysis'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      final message = source == ImageSource.camera
          ? 'upload_camera_error'.tr
          : 'upload_gallery_error'.tr;
      _showError(message);
    }
  }

  int stepIndex(UploadStep step) {
    switch (step) {
      case UploadStep.choose:
        return 0;
      case UploadStep.review:
        return 1;
      case UploadStep.analyze:
        return 2;
    }
  }

  bool isStepActive(UploadStep step) =>
      stepIndex(currentStep.value) >= stepIndex(step);

  bool isStepCurrent(UploadStep step) => currentStep.value == step;

  // 8. Private methods
  void _loadDocumentHistory() {
    _storage = Get.find<DocumentStorageService>();
    _storage.purgeLegacyMockEntries();
    _syncHistoryFromStorage();
  }

  void _syncHistoryFromStorage() {
    _storage.reload();
    _applyHistoryFromStorage();
  }

  Future<void> refreshDocumentList() async {
    await _storage.reload();
    _applyHistoryFromStorage();
  }

  void _applyHistoryFromStorage() {
    final items = _storage.documents.map(_mapStoredToRecent).toList();

    final active = activeAnalysisDocument.value;
    if (active != null &&
        !items.any((doc) => doc.id == active.id) &&
        (active.status == UploadScanStatus.analyzing ||
            active.status == UploadScanStatus.error)) {
      items.insert(0, active);
    }

    allDocuments.assignAll(items);
  }

  UploadRecentItemModel _mapStoredToRecent(StoredDocumentModel stored) {
    final analysis = stored.analysis;
    return UploadRecentItemModel(
      id: stored.id,
      title: RecentDocumentDisplay.headlineForStored(stored),
      meta: RecentDocumentDisplay.fileNameSubtitle(stored),
      status: UploadScanStatus.complete,
      icon: analysis.isCreditCard
          ? Icons.credit_card_outlined
          : Icons.picture_as_pdf_outlined,
      localPath: stored.localPath,
    );
  }

  Future<Uint8List?> _readPdfBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes;
    if (file.path != null) {
      return File(file.path!).readAsBytes();
    }
    return null;
  }

  Future<void> _runGeminiAnalysis({
    required Uint8List pdfBytes,
    required String fileName,
    required int? sizeBytes,
    String? localPath,
  }) async {
    final docId = DateTime.now().millisecondsSinceEpoch.toString();

    final bankGuess = RecentDocumentDisplay.bankFromFileName(fileName);
    final pendingTitle = bankGuess.isNotEmpty
        ? '${'upload_status_analyzing'.tr} · $bankGuess'
        : 'upload_status_analyzing'.tr;

    activeAnalysisDocument.value = UploadRecentItemModel(
      id: docId,
      title: pendingTitle,
      meta: fileName,
      status: UploadScanStatus.analyzing,
      icon: Icons.picture_as_pdf_outlined,
      localPath: localPath,
    );

    final fingerprint = DocumentFingerprint.fromPdfBytes(pdfBytes);
    final cached = _storage.findByFingerprint(fingerprint);
    if (cached != null) {
      if (kDebugMode) debugPrint('[Upload] Cache hit for $fileName');
      _goToAnalysisTab();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().clearAnalysisSelection();
      }
      await _handleAnalysisSuccess(
        docId: cached.id,
        analysis: cached.analysis,
        pdfBytes: pdfBytes,
        fileName: fileName,
        localPath: localPath,
      );
      return;
    }

    isAnalyzing(true);
    hasError(false);
    currentStep.value = UploadStep.analyze;
    analysisProgress.value = 0.1;
    isParsing.value = false;
    _clearSelectedFilePreview();

    _syncHistoryFromStorage();
    _goToAnalysisTab();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().clearAnalysisSelection();
    }

    if (!_validatePdfForAnalysis(
      fileName: fileName,
      sizeBytes: sizeBytes,
      pdfBytes: pdfBytes,
    )) {
      _resetAnalysisState();
      return;
    }

    try {
      analysisProgress.value = 0.35;
      isParsing.value = true;

      final result = await _geminiService.runDocumentParserAgent(
        pdfBytes,
        fileName,
        onProgress: (p) => analysisProgress.value = p,
      );

      await _handleAnalysisSuccess(
        docId: docId,
        analysis: result,
        pdfBytes: pdfBytes,
        fileName: fileName,
        localPath: localPath,
      );
    } on AppException catch (e) {
      _markActiveDocumentError();
      _promoteActiveToHistory();
      _resetAnalysisState();
      _showError(e.message);
    } catch (e) {
      _markActiveDocumentError();
      _promoteActiveToHistory();
      _resetAnalysisState();
      if (e is AppException) {
        _showError(e.message);
      } else {
        _showError('error_gemini_parse'.tr);
      }
    }
  }

  Future<void> _handleAnalysisSuccess({
    required String docId,
    required DocumentAnalysisModel analysis,
    required Uint8List pdfBytes,
    required String fileName,
    String? localPath,
  }) async {
    analysisProgress.value = 1;

    await _storage.saveDocument(
      id: docId,
      analysis: analysis,
      fileName: fileName,
      pdfBytes: pdfBytes,
      localPath: localPath,
    );

    showAllHistory.value = true;
    _syncHistoryFromStorage();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refresh();
    }

    _resetAnalysisState();

    final stored = _storage.findById(docId);

    await _showNameConfirmationSheet(
      docId: docId,
      suggestedTitle: stored?.smartTitle ?? fileName,
      suggestedPeriod: stored?.smartPeriodLabel ?? '',
    );

    final updated = _storage.findById(docId);
    final smartTitle = updated?.smartTitle ?? fileName;

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().selectAnalysisDocument(docId, smartTitle);
    }

    if (updated != null) {
      Get.snackbar(
        'home_ai_ready_title'.tr,
        updated.smartTitle,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(AppConstants.paddingMd),
      );
    }
  }

  Future<void> _showNameConfirmationSheet({
    required String docId,
    required String suggestedTitle,
    required String suggestedPeriod,
  }) async {
    await Get.bottomSheet<void>(
      DocumentNameSheet(
        initialTitle: suggestedTitle,
        initialPeriod: suggestedPeriod,
        onSave: (title, period) async {
          final trimmedTitle = title.trim();
          final trimmedPeriod = period.trim();
          if (trimmedTitle != suggestedTitle ||
              trimmedPeriod != suggestedPeriod) {
            await _storage.updateDocument(
              id: docId,
              customTitle: trimmedTitle.isEmpty ? null : trimmedTitle,
              customPeriod: trimmedPeriod.isEmpty ? null : trimmedPeriod,
            );
            _syncHistoryFromStorage();
            if (Get.isRegistered<HomeController>()) {
              await Get.find<HomeController>().refresh();
            }
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _promoteActiveToHistory() {
    final active = activeAnalysisDocument.value;
    if (active == null) return;
    final index = allDocuments.indexWhere((doc) => doc.id == active.id);
    if (index >= 0) {
      allDocuments[index] = active;
    } else {
      allDocuments.insert(0, active);
    }
  }

  void _clearSelectedFilePreview() {
    selectedFileName.value = null;
    selectedFileSizeLabel.value = null;
    selectedLocalPath.value = null;
    selectedSourceIsPhoto.value = false;
  }

  void _resetAnalysisState() {
    isAnalyzing(false);
    isParsing.value = false;
    analysisProgress.value = 0;
    activeAnalysisDocument.value = null;
    currentStep.value = UploadStep.choose;
    _clearSelectedFilePreview();
  }

  void _goToAnalysisTab() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().goToAnalysisTab();
    }
  }

  bool _validateFileSize(int? sizeBytes) {
    if (sizeBytes == null) return true;
    const maxBytes = AppConstants.uploadMaxFileSizeMb * 1024 * 1024;
    if (sizeBytes > maxBytes) {
      _showError(
        'upload_file_too_large'
            .trParams({'max': AppConstants.uploadMaxFileSizeMb.toString()}),
      );
      return false;
    }
    return true;
  }

  bool _validatePdfForAnalysis({
    required String fileName,
    required int? sizeBytes,
    required Uint8List pdfBytes,
  }) {
    if (PdfUploadValidator.exceedsGeminiLimit(sizeBytes)) {
      _showError(
        'upload_file_too_large'.trParams({
          'max': PdfUploadValidator.geminiMaxFileSizeMb.toString(),
        }),
      );
      return false;
    }
    if (!PdfUploadValidator.isPdfBytes(pdfBytes)) {
      _showError('upload_invalid_pdf'.tr);
      return false;
    }
    return true;
  }

  void _markActiveDocumentError() {
    final active = activeAnalysisDocument.value;
    if (active == null) return;
    activeAnalysisDocument.value = active.copyWith(
      status: UploadScanStatus.error,
    );
  }

  void _handlePickError(Object e) {
    _showError('upload_pick_error'.tr);
  }

  void _showUploadError({
    required String fileName,
    required int? sizeBytes,
    Uint8List? pdfBytes,
    bool geminiFailed = false,
  }) {
    final messageKey = PdfUploadValidator.resolveUploadErrorKey(
      fileName: fileName,
      sizeBytes: sizeBytes,
      pdfBytes: pdfBytes,
      geminiFailed: geminiFailed,
    );
    final message = messageKey == 'upload_file_too_large'
        ? messageKey.trParams({
            'max': PdfUploadValidator.geminiMaxFileSizeMb.toString(),
          })
        : messageKey.tr;
    _showError(message);
  }

  void _showError(String message) {
    hasError(true);
    errorMessage(message);
    Get.snackbar(
      'upload_title'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
