import 'dart:math' as math;

import 'package:get/get.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../../../services/document_storage_service.dart';
import '../../../../services/gemini_service.dart';
import '../../models/document_analysis_model.dart';
import '../../models/document_detail_args.dart';
import '../../models/expense_category_stat.dart';
import '../../models/stored_document_model.dart';
import '../../models/transaction_model.dart';

class DocumentDetailController extends GetxController {
  static const String allCategoriesKey = 'all';
  static const int transactionsTabIndex = 4;

  final DocumentStorageService _storage = Get.find<DocumentStorageService>();

  late final String documentId;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final selectedCategory = allCategoriesKey.obs;
  final groupedView = true.obs;
  final aiRecommendationsStatus = 'idle'.obs;
  final aiRecommendationsText = ''.obs;

  static const Map<String, String> categoryEmoji = {
    'market': '🛒',
    'food': '🍽️',
    'clothing': '👕',
    'transport': '🚗',
    'bills': '🌐',
    'health': '💊',
    'entertainment': '🎬',
    'education': '📚',
    'subscription': '📱',
    'transfer': '💸',
    'other': '📦',
  };

  static const Map<String, String> categoryNames = {
    'market': 'Market ve Alışveriş',
    'food': 'Yemek ve Kafe',
    'clothing': 'Giyim ve Bakım',
    'transport': 'Ulaşım ve Yakıt',
    'bills': 'Fatura ve Abonelik',
    'health': 'Sağlık',
    'entertainment': 'Eğlence',
    'education': 'Eğitim',
    'subscription': 'Dijital Hizmetler',
    'transfer': 'Transfer',
    'other': 'Diğer',
  };

  StoredDocumentModel? get storedDocument => _storage.findById(documentId);

  bool get hasIncompleteAnalysis {
    final doc = storedDocument;
    if (doc == null) return false;
    return !doc.analysis.hasUsableAnalysis;
  }

  DocumentAnalysisModel get model {
    final doc = storedDocument;
    if (doc == null) {
      throw StateError('Document not found: $documentId');
    }
    return doc.analysis;
  }

  @override
  void onInit() {
    super.onInit();
    documentId = _resolveDocumentId(Get.arguments);
    if (storedDocument == null) {
      hasError(true);
      errorMessage('doc_detail_not_found'.tr);
      return;
    }
    selectedCategory.value = allCategoriesKey;
    aiRecommendationsStatus.value = 'idle';
    aiRecommendationsText.value = '';
    Future.microtask(loadAiRecommendations);
  }

  static String _resolveDocumentId(dynamic args) {
    if (args is DocumentDetailArgs) return args.documentId;
    if (args is String && args.isNotEmpty) return args;
    if (args is DocumentAnalysisModel) {
      final storage = Get.find<DocumentStorageService>();
      for (final doc in storage.documents) {
        if (identical(doc.analysis, args)) return doc.id;
        if (_analysisMatches(doc.analysis, args)) return doc.id;
      }
    }
    return '';
  }

  static bool _analysisMatches(
    DocumentAnalysisModel a,
    DocumentAnalysisModel b,
  ) {
    if (a.period.isNotEmpty && a.period == b.period) {
      final aLabel = a.cardLabel.isNotEmpty ? a.cardLabel : a.bankName;
      final bLabel = b.cardLabel.isNotEmpty ? b.cardLabel : b.bankName;
      if (aLabel.isNotEmpty && aLabel == bLabel) return true;
    }
    return a.documentTitle == b.documentTitle &&
        a.transactions.length == b.transactions.length &&
        a.totalExpense == b.totalExpense;
  }

  /// Expense categories sorted by total spent (highest first).
  List<String> get expenseCategoryKeys {
    final keys = categoryBreakdown.keys.toList()
      ..sort(
        (a, b) => categoryBreakdown[b]!.compareTo(categoryBreakdown[a]!),
      );
    return keys;
  }

  List<String> get categories => [allCategoriesKey, ...expenseCategoryKeys];

  List<ExpenseCategoryStat> get categoryStats {
    final breakdown = categoryBreakdown;
    final total = breakdown.values.fold<double>(0, (s, v) => s + v);
    if (total <= 0) return const [];

    return expenseCategoryKeys
        .map(
          (key) => ExpenseCategoryStat(
            key: key,
            total: breakdown[key]!,
            count: _expenseCountForCategory(key),
            percent: (breakdown[key]! / total) * 100,
          ),
        )
        .toList();
  }

  Map<String, double> get categoryBreakdown {
    final breakdown = <String, double>{};
    for (final transaction in model.transactions) {
      if (transaction.type != 'expense') continue;
      final key = ExpenseCategoryUtils.normalize(
        transaction.category,
        transaction.description,
      );
      breakdown[key] = (breakdown[key] ?? 0) + transaction.amount;
    }
    return breakdown;
  }

  double get totalExpenseFromTransactions {
    return model.transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double categoryExpenseTotal(String categoryKey) {
    if (categoryKey == allCategoriesKey) {
      return totalExpenseFromTransactions;
    }
    return categoryBreakdown[categoryKey] ?? 0;
  }

  int categoryTransactionCount(String categoryKey) {
    if (categoryKey == allCategoriesKey) {
      return model.transactions.length;
    }
    return model.transactions
        .where(
          (t) =>
              ExpenseCategoryUtils.normalize(t.category, t.description) ==
              categoryKey,
        )
        .length;
  }

  List<TransactionModel> get filteredTransactions {
    if (selectedCategory.value == allCategoriesKey) {
      return model.transactions;
    }
    return model.transactions
        .where(
          (t) =>
              ExpenseCategoryUtils.normalize(t.category, t.description) ==
              selectedCategory.value,
        )
        .toList();
  }

  List<TransactionModel> get categoryFilteredExpenses {
    if (selectedCategory.value == allCategoriesKey) {
      return model.transactions.where((t) => t.type == 'expense').toList();
    }
    return model.transactions
        .where((t) => t.type == 'expense')
        .where(
          (t) =>
              ExpenseCategoryUtils.normalize(t.category, t.description) ==
              selectedCategory.value,
        )
        .toList();
  }

  int get categoryFilteredExpenseCount => categoryFilteredExpenses.length;

  double get selectedCategoryExpenseTotal =>
      categoryExpenseTotal(selectedCategory.value);

  double get selectedCategoryPercent {
    final total = totalExpenseFromTransactions;
    if (total <= 0) return 0;
    return (selectedCategoryExpenseTotal / total) * 100;
  }

  double get totalIncome => model.totalIncome;

  double get totalExpense => model.totalExpense;

  double get closingBalance => model.closingBalance;

  int get transactionCount => model.transactions.length;

  double get financialHealthScore {
    final income = totalIncome;
    final expense = totalExpense;
    final divisor = income > 0 ? income : 1.0;
    final raw = ((income - expense) / divisor) * 100 + 50;
    return raw.clamp(0, 100);
  }

  TransactionModel? get topExpense {
    final expenses =
        model.transactions.where((t) => t.type == 'expense').toList();
    if (expenses.isEmpty) return null;
    return expenses.reduce(
      (current, next) => next.amount > current.amount ? next : current,
    );
  }

  Map<String, List<TransactionModel>> get groupedExpenses {
    final grouped = <String, List<TransactionModel>>{};
    for (final t in model.transactions) {
      if (t.type != 'expense') continue;
      final key = ExpenseCategoryUtils.normalize(t.category, t.description);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final sumA = a.value.fold<double>(0, (s, tx) => s + tx.amount);
        final sumB = b.value.fold<double>(0, (s, tx) => s + tx.amount);
        return sumB.compareTo(sumA);
      });
    return Map.fromEntries(entries);
  }

  double categoryTotal(String key) =>
      (groupedExpenses[key] ?? []).fold(0, (s, t) => s + t.amount);

  List<TransactionModel> get installmentTransactions =>
      model.transactions.where((t) => t.isInstallment).toList();

  double get netDebt {
    final gross = model.totalExpense;
    final carry = model.previousPeriodBalance;
    return gross + carry;
  }

  bool get hasCarryover => model.previousPeriodBalance != 0;

  bool get hasFutureDates =>
      model.nextStatementDate.isNotEmpty ||
      model.nextPaymentDueDate.isNotEmpty;

  // ── Borç hesaplayıcı ──────────────────────────────────────────────────────

  /// Turkish BDDK regulated monthly CC interest rate cap (~3.53%)
  static const double monthlyInterestRate = 0.035;

  /// Whether the debt payoff calculator has enough data to display.
  bool get canShowDebtCalculator =>
      model.isCreditCard &&
      model.displayDebt > 0 &&
      model.minimumPayment > 0 &&
      model.minimumPayment > model.displayDebt * monthlyInterestRate;

  /// Months to pay off debt paying only the minimum each month.
  int get debtPayoffMonths {
    final balance = model.displayDebt;
    final minPay = model.minimumPayment;
    const r = monthlyInterestRate;
    final raw = -math.log(1 - (balance * r / minPay)) / math.log(1 + r);
    return raw.ceil();
  }

  /// Total interest paid if paying minimum every month until debt is cleared.
  double get totalInterestIfMinimum {
    final months = debtPayoffMonths;
    return (months * model.minimumPayment) - model.displayDebt;
  }

  /// Total amount paid (principal + interest) if paying minimum every month.
  double get totalPaidIfMinimum => model.displayDebt + totalInterestIfMinimum;

  String categoryDisplayName(String key) =>
      categoryNames[key] ?? categoryLabel(key);

  String categoryEmojiFor(String key) => categoryEmoji[key] ?? '📦';

  void toggleGroupedView() => groupedView.toggle();

  List<Map<String, dynamic>> get recurringPayments {
    final freq = <String, List<TransactionModel>>{};
    for (final t in model.transactions) {
      if (t.type != 'expense') continue;
      final key = t.description.toLowerCase().trim();
      if (key.isEmpty) continue;
      freq[key] = [...(freq[key] ?? []), t];
    }
    return freq.entries
        .where((e) => e.value.length >= 2)
        .map(
          (e) => {
            'description': e.value.first.description.isNotEmpty
                ? e.value.first.description
                : e.key,
            'count': e.value.length,
            'total': e.value.fold<double>(0, (s, t) => s + t.amount),
          },
        )
        .toList()
      ..sort(
        (a, b) =>
            (b['total'] as double).compareTo(a['total'] as double),
      );
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void focusCategoryInTransactions(String categoryKey) {
    selectedCategory.value = categoryKey;
    groupedView.value = true;
  }

  String categoryLabel(String categoryKey) {
    return ExpenseCategoryUtils.label(categoryKey);
  }

  /// Category key from Gemini JSON (`transaction.category`).
  String geminiCategoryKey(TransactionModel transaction) {
    return ExpenseCategoryUtils.normalize(
      transaction.category,
      transaction.description,
    );
  }

  String normalizedCategoryFor(TransactionModel transaction) =>
      geminiCategoryKey(transaction);

  int _expenseCountForCategory(String key) {
    return model.transactions
        .where((t) => t.type == 'expense')
        .where(
          (t) =>
              ExpenseCategoryUtils.normalize(t.category, t.description) ==
              key,
        )
        .length;
  }

  Future<void> loadAiRecommendations() async {
    if (hasError.value || storedDocument == null) return;
    if (aiRecommendationsStatus.value == 'loading') return;
    aiRecommendationsStatus.value = 'loading';
    try {
      final gemini = Get.find<GeminiService>();
      final breakdownText = categoryStats
          .map(
            (s) =>
                '${categoryLabel(s.key)}: ₺${s.total.toStringAsFixed(0)} (${s.percent.toStringAsFixed(0)}%)',
          )
          .join(', ');
      final recurringText = recurringPayments
          .take(5)
          .map((r) => '${r['description']} (${r['count']}x)')
          .join(', ');

      final prompt = '''
Sen bir kişisel finans danışmanısın. Aşağıdaki finansal analiz verilerine göre kullanıcıya 3-5 somut, uygulanabilir öneri ver.
Her öneriyi AYRI SATIRDA yaz; satır başına "- " koy. Paragraf yazma. Her satırda bir emoji kullan. Türkçe yaz.

Belge: ${model.documentTitle}
Dönem: ${model.period}
Toplam Gelir: ${model.totalIncome} ${model.currency}
Toplam Gider: ${model.totalExpense} ${model.currency}
İşlem Sayısı: ${model.transactions.length}
Özet: ${model.summary}
Kategori dağılımı: $breakdownText
Tekrar eden ödemeler: $recurringText
''';

      final result = await gemini.generateText(prompt);
      aiRecommendationsText.value = result;
      aiRecommendationsStatus.value = 'done';
    } on AppException {
      aiRecommendationsStatus.value = 'error';
    } catch (_) {
      aiRecommendationsStatus.value = 'error';
    }
  }
}
