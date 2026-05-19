import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/payment_due_utils.dart';
import '../../../core/app_date_formats.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../routes/routes.dart';
import '../../../services/document_storage_service.dart';
import '../../documents/models/document_detail_args.dart';
import '../../documents/models/stored_document_model.dart';
import '../../../core/utils/document_card_identity.dart';
import '../../../core/utils/expense_category_utils.dart';
import '../models/payment_due_alert_model.dart';
import '../widgets/home_notifications_sheet.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../documents/upload/views/pdf_preview_view.dart';
import '../../../services/pdf_file_service.dart';
import '../models/home_document_model.dart';

class HomeController extends GetxController {
  final DocumentStorageService _storage = Get.find<DocumentStorageService>();

  // 2. Reactive state
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentTabIndex = 0.obs;

  final userName = 'Mert'.obs;
  final avatarInitial = 'M'.obs;
  final analyzedDocumentCount = 0.obs;
  final documents = <HomeDocumentModel>[].obs;
  final creditCardStatements = <StoredDocumentModel>[].obs;
  final homeDocuments = <StoredDocumentModel>[].obs;
  final expandedDocumentId = RxnString();

  final selectedAnalysisDocumentId = RxnString();
  final selectedAnalysisDocumentTitle = RxnString();
  final paymentDueAlerts = <PaymentDueAlertModel>[].obs;
  final selectedHomeDocIndex = 0.obs;

  static final _moneyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  // 6. Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // 7. Public methods
  @override
  Future<void> refresh() => loadDashboard();

  void onTabSelected(int index) {
    currentTabIndex.value = index;
    if (index == 2) {
      Future.microtask(() async {
        await _storage.reload();
        _syncFromStorage();
      });
    }
  }

  Future<void> goToAnalysisTab() async {
    currentTabIndex.value = 2;
    await _storage.reload();
    _syncFromStorage();
  }

  void goToAnalyses() {
    clearAnalysisSelection();
    goToAnalysisTab();
  }

  void toggleDocumentExpanded(String id) {
    expandedDocumentId.value =
        expandedDocumentId.value == id ? null : id;
  }

  void openAnalysisForDocument(String id, String title) {
    selectedAnalysisDocumentId.value = id;
    selectedAnalysisDocumentTitle.value = title;
    currentTabIndex.value = 2;
  }

  void selectAnalysisDocument(String id, String title) {
    selectedAnalysisDocumentId.value = id;
    selectedAnalysisDocumentTitle.value = title;
  }

  Future<void> openPdfPreview(String documentId) async {
    final stored = _storage.findById(documentId);
    if (stored == null) {
      Get.snackbar('upload_title'.tr, 'doc_detail_not_found'.tr);
      return;
    }
    final path = await PdfFileService.resolvePath(documentId, stored.localPath);
    if (path == null) {
      Get.snackbar('upload_title'.tr, 'doc_preview_unavailable'.tr);
      return;
    }
    Get.to(
      () => PdfPreviewView(
        filePath: path,
        title: stored.displayTitle,
      ),
      fullscreenDialog: true,
    );
  }

  Future<void> reanalyzeDocument(String documentId) async {
    isLoading(true);
    try {
      final ok = await _storage.reanalyzeDocument(documentId);
      if (!ok) {
        Get.snackbar('upload_title'.tr, 'doc_preview_unavailable'.tr);
        return;
      }
      await refresh();
      Get.snackbar('doc_reanalyze_success_title'.tr, 'doc_reanalyze_success'.tr);
    } on AppException catch (e) {
      Get.snackbar('upload_title'.tr, e.message);
    } catch (_) {
      Get.snackbar('upload_title'.tr, 'error_gemini_parse'.tr);
    } finally {
      isLoading(false);
    }
  }

  void clearAnalysisSelection() {
    selectedAnalysisDocumentId.value = null;
    selectedAnalysisDocumentTitle.value = null;
  }

  bool get hasNotificationAlerts => paymentDueAlerts.isNotEmpty;

  void onNotificationTap() {
    Get.bottomSheet(
      const HomeNotificationsSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
    );
  }

  void goToDocumentsTab() => currentTabIndex.value = 1;

  void goToDocumentUpload() => goToDocumentsTab();

  void goToAllDocuments() => goToDocumentsTab();

  void goToReports() => Get.toNamed(AppRoutes.aggregate);

  void openDocumentDetail(StoredDocumentModel document) {
    Get.toNamed(
      AppRoutes.documentDetail,
      arguments: DocumentDetailArgs(documentId: document.id),
    );
  }

  void onDocumentDeleted(String id) {
    if (selectedAnalysisDocumentId.value == id) {
      clearAnalysisSelection();
    }
    if (expandedDocumentId.value == id) {
      expandedDocumentId.value = null;
    }
    _syncFromStorage();
  }

  void onCreditCardTap(StoredDocumentModel document) {
    toggleDocumentExpanded(document.id);
  }

  void onDocumentTap(HomeDocumentModel document) {
    toggleDocumentExpanded(document.id);
  }

  String greetingText() =>
      'home_greeting'.trParams({'name': userName.value});

  String greetingDateText() {
    final locale = Get.locale?.languageCode ?? 'tr';
    final formatted = AppDateFormats.weekdayMonth(
      DateTime.now(),
      languageCode: locale,
    );
    return _capitalizeFirst(formatted);
  }

  String greetingTaglineText() => 'home_greeting_tagline'.tr;

  StoredDocumentModel? get selectedHomeDoc {
    final docs = homeDocuments;
    if (docs.isEmpty) return null;
    final idx = selectedHomeDocIndex.value.clamp(0, docs.length - 1);
    return docs[idx];
  }

  void selectHomeDoc(int index) {
    selectedHomeDocIndex.value =
        index.clamp(0, homeDocuments.length - 1);
  }

  /// Same card (cardLabel or bankName) from an earlier upload period.
  StoredDocumentModel? findPreviousPeriodDoc(StoredDocumentModel current) {
    StoredDocumentModel? best;
    for (final doc in homeDocuments) {
      if (doc.id == current.id) continue;
      if (!DocumentCardIdentity.isSameCard(doc, current)) continue;
      if (doc.uploadedAt.isBefore(current.uploadedAt)) {
        if (best == null || doc.uploadedAt.isAfter(best.uploadedAt)) {
          best = doc;
        }
      }
    }
    return best;
  }

  String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  String aiCardSubtitleText() {
    final count = analyzedDocumentCount.value;
    if (count <= 0) return 'home_ai_empty_subtitle'.tr;
    if (count == 1) return 'home_ai_ready_subtitle'.tr;
    return 'home_ai_ready_subtitle_count'
        .trParams({'count': count.toString()});
  }

  String get topExpenseCategoryKey {
    final totals = <String, double>{};
    for (final doc in homeDocuments) {
      for (final t in doc.analysis.transactions) {
        if (t.type != 'expense') continue;
        final key = t.category.isEmpty ? 'other' : t.category;
        totals[key] = (totals[key] ?? 0) + t.amount;
      }
    }
    if (totals.isEmpty) return '';
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get topExpenseCategoryTotal {
    final totals = <String, double>{};
    for (final doc in homeDocuments) {
      for (final t in doc.analysis.transactions) {
        if (t.type != 'expense') continue;
        final key = t.category.isEmpty ? 'other' : t.category;
        totals[key] = (totals[key] ?? 0) + t.amount;
      }
    }
    if (totals.isEmpty) return 0;
    return totals.values.reduce((a, b) => a > b ? a : b);
  }

  double get totalCreditCardDebt => homeDocuments
      .where((d) => d.analysis.isCreditCard)
      .fold<double>(0, (sum, d) => sum + d.analysis.displayDebt);

  double get totalExpenseAllDocs => homeDocuments.fold<double>(
        0,
        (sum, d) => sum + d.analysis.totalExpense,
      );

  bool get hasAnyData => homeDocuments.isNotEmpty;

  /// Short AI note for the home insight card (category vs previous period).
  String get selectedDocAiInsight {
    final doc = selectedHomeDoc;
    if (doc == null) return 'home_ai_insight_empty'.tr;

    final prev = findPreviousPeriodDoc(doc);
    if (prev == null) {
      return 'home_ai_insight_no_compare'.tr;
    }

    final topChange = _topCategoryChange(doc, prev);
    if (topChange == null) {
      final diff = doc.analysis.totalExpense - prev.analysis.totalExpense;
      final pct = prev.analysis.totalExpense > 0
          ? ((diff / prev.analysis.totalExpense) * 100).abs().round()
          : 0;
      if (pct == 0) return 'home_ai_insight_stable'.tr;
      final isMore = diff > 0;
      return isMore
          ? 'home_ai_insight_total_more'.trParams({'pct': '$pct'})
          : 'home_ai_insight_total_less'.trParams({'pct': '$pct'});
    }

    final categoryName = ExpenseCategoryUtils.label(topChange.key);
    final pct = topChange.percent.round();
    if (pct == 0) return 'home_ai_insight_stable'.tr;
    return topChange.increased
        ? 'home_ai_insight_category_more'.trParams({
            'category': categoryName,
            'pct': '$pct',
          })
        : 'home_ai_insight_category_less'.trParams({
            'category': categoryName,
            'pct': '$pct',
          });
  }

  ({String key, double percent, bool increased})? _topCategoryChange(
    StoredDocumentModel current,
    StoredDocumentModel previous,
  ) {
    final keys = <String>{};
    for (final t in current.analysis.transactions) {
      if (t.type == 'expense') {
        keys.add(ExpenseCategoryUtils.normalize(t.category, t.description));
      }
    }
    for (final t in previous.analysis.transactions) {
      if (t.type == 'expense') {
        keys.add(ExpenseCategoryUtils.normalize(t.category, t.description));
      }
    }

    ({String key, double percent, bool increased})? best;
    for (final key in keys) {
      final cur = _categoryTotal(current, key);
      final prev = _categoryTotal(previous, key);
      if (cur == 0 && prev == 0) continue;
      final diff = cur - prev;
      final pct = prev > 0 ? (diff / prev * 100).abs() : (cur > 0 ? 100.0 : 0);
      if (best == null || pct > best.percent) {
        best = (key: key, percent: pct.toDouble(), increased: diff > 0);
      }
    }
    return best;
  }

  double _categoryTotal(StoredDocumentModel doc, String categoryKey) {
    return doc.analysis.transactions
        .where((t) => t.type == 'expense')
        .where(
          (t) =>
              ExpenseCategoryUtils.normalize(t.category, t.description) ==
              categoryKey,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  String notificationMessage(PaymentDueAlertModel alert) {
    if (alert.isOverdue) {
      return 'home_notifications_payment_overdue'.trParams({
        'title': alert.title,
        'date': alert.dueDateLabel,
      });
    }
    if (alert.isDueToday) {
      return 'home_notifications_payment_due_today'.trParams({
        'title': alert.title,
        'date': alert.dueDateLabel,
      });
    }
    return 'home_notifications_payment_due'.trParams({
      'title': alert.title,
      'date': alert.dueDateLabel,
      'days': alert.daysRemaining.toString(),
    });
  }

  void openDocumentFromAlert(String documentId) {
    Get.back();
    final stored = _storage.findById(documentId);
    if (stored == null) return;
    openDocumentDetail(stored);
  }

  // 8. Private methods
  Future<void> loadDashboard() async {
    isLoading(true);
    hasError(false);
    errorMessage('');
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _storage.reload();
      _syncFromStorage();
    } catch (e) {
      hasError(true);
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void _syncFromStorage() {
    creditCardStatements.assignAll(_storage.creditCardStatements);
    homeDocuments.assignAll(_storage.documents);
    if (selectedHomeDocIndex.value >= homeDocuments.length) {
      selectedHomeDocIndex.value =
          homeDocuments.isEmpty ? 0 : homeDocuments.length - 1;
    }
    analyzedDocumentCount.value = _storage.documents.length;

    paymentDueAlerts.assignAll(
      PaymentDueUtils.alertsFromDocuments(_storage.documents),
    );

    documents.assignAll(
      _storage.recentNonCreditCardDocuments.map(
        (stored) => HomeDocumentModel(
          id: stored.id,
          title: stored.analysis.documentTitle.isNotEmpty
              ? stored.analysis.documentTitle
              : stored.fileName,
          dateLabel: stored.analysis.period.isNotEmpty
              ? stored.analysis.period
              : _formatUploadDate(stored.uploadedAt),
          amountLabel: _moneyFormat.format(stored.analysis.displayDebt),
          icon: Icons.account_balance_outlined,
        ),
      ),
    );
  }

  String _formatUploadDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
