import '../../../core/utils/json_parse_utils.dart';
import 'transaction_model.dart';

class DocumentAnalysisModel {
  const DocumentAnalysisModel({
    required this.documentTitle,
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.closingBalance,
    required this.currency,
    required this.transactions,
    required this.summary,
    this.documentType = 'bank_statement',
    this.bankName = '',
    this.cardLabel = '',
    this.cardLastFour = '',
    this.currentDebt = 0,
    this.minimumPayment = 0,
    this.lastPaymentDate = '',
    this.paymentDueDate = '',
    this.previousPeriodBalance = 0,
    this.nextStatementDate = '',
    this.nextPaymentDueDate = '',
    this.cardLimit = 0,
    this.availableLimit = 0,
  });

  final String documentTitle;
  final String period;
  final double totalIncome;
  final double totalExpense;
  final double closingBalance;
  final String currency;
  final List<TransactionModel> transactions;
  final String summary;

  final String documentType;
  final String bankName;
  final String cardLabel;
  final String cardLastFour;
  final double currentDebt;
  final double minimumPayment;
  final String lastPaymentDate;
  final String paymentDueDate;
  final double previousPeriodBalance;
  final String nextStatementDate;
  final String nextPaymentDueDate;
  final double cardLimit;
  final double availableLimit;

  bool get isCreditCard {
    final type = documentType.toLowerCase();
    if (type == 'credit_card' || type == 'credit card') return true;
    if (type == 'bank_statement' || type == 'bank statement') {
      if (cardLabel.trim().isEmpty &&
          minimumPayment <= 0 &&
          cardLimit <= 0) {
        return false;
      }
    }
    if (cardLabel.trim().isNotEmpty) return true;
    if (minimumPayment > 0 || cardLimit > 0) return true;
    final haystack =
        '${documentTitle.toLowerCase()} ${cardLabel.toLowerCase()} ${bankName.toLowerCase()}';
    return haystack.contains('kredi') ||
        haystack.contains('kart') ||
        haystack.contains('credit card') ||
        haystack.contains('bonus') ||
        haystack.contains('maximum') ||
        haystack.contains('ekstre');
  }

  double get displayDebt =>
      currentDebt > 0 ? currentDebt : closingBalance;

  bool get hasMeaningfulData =>
      documentTitle.isNotEmpty ||
      bankName.isNotEmpty ||
      summary.isNotEmpty ||
      period.isNotEmpty ||
      transactions.isNotEmpty ||
      displayDebt > 0 ||
      totalExpense > 0 ||
      closingBalance > 0;

  /// Enough data to show detail charts, transactions, and summaries.
  bool get hasUsableAnalysis =>
      transactions.isNotEmpty ||
      totalExpense > 0 ||
      minimumPayment > 0 ||
      cardLimit > 0 ||
      displayDebt > 0 ||
      closingBalance > 0;

  factory DocumentAnalysisModel.fromJson(Map<String, dynamic> json) {
    final transactions = JsonParseUtils.asMapList(
      json['transactions'] ?? json['islemListesi'] ?? json['items'],
    ).map(TransactionModel.fromJson).toList();

    var totalIncome = JsonParseUtils.parseAmount(
      json['totalIncome'] ?? json['toplamGelir'] ?? json['income'],
    );
    var totalExpense = JsonParseUtils.parseAmount(
      json['totalExpense'] ?? json['toplamGider'] ?? json['expense'],
    );
    var closingBalance = JsonParseUtils.parseAmount(
      json['closingBalance'] ??
          json['closing_balance'] ??
          json['kapanisBakiyesi'] ??
          json['balance'],
    );

    final currentDebt = JsonParseUtils.parseAmount(
      json['currentDebt'] ??
          json['current_debt'] ??
          json['guncelBorc'] ??
          json['statementBalance'] ??
          json['ekstreBorcu'],
    );

    if (transactions.isNotEmpty) {
      if (totalIncome == 0) {
        totalIncome = transactions
            .where((t) => t.type == 'income')
            .fold<double>(0, (sum, t) => sum + t.amount);
      }
      if (totalExpense == 0) {
        totalExpense = transactions
            .where((t) => t.type == 'expense')
            .fold<double>(0, (sum, t) => sum + t.amount);
      }
    }

    final resolvedDebt = currentDebt > 0 ? currentDebt : closingBalance;

    final title = JsonParseUtils.readString(json, [
      'documentTitle',
      'title',
      'accountHolder',
    ]);
    final bank = JsonParseUtils.readString(json, ['bankName', 'bank', 'banka']);

    return DocumentAnalysisModel(
      documentTitle: title.isNotEmpty ? title : bank,
      period: JsonParseUtils.readString(json, ['period', 'donem', 'dateRange']),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      closingBalance: closingBalance,
      currency: JsonParseUtils.readString(json, ['currency', 'paraBirimi']).isEmpty
          ? 'TRY'
          : JsonParseUtils.readString(json, ['currency', 'paraBirimi']),
      transactions: transactions,
      summary: JsonParseUtils.readString(json, [
        'summary',
        'ozet',
        'özet',
        'crossAccountSummary',
        'analysis',
      ]),
      documentType: JsonParseUtils.readString(json, [
        'documentType',
        'document_type',
        'type',
      ]),
      bankName: bank,
      cardLabel: JsonParseUtils.readString(json, [
        'cardLabel',
        'cardName',
        'card_label',
        'kartAdi',
      ]),
      cardLastFour: JsonParseUtils.readString(json, [
        'cardLastFour',
        'card_last_four',
        'lastFourDigits',
      ]),
      currentDebt: resolvedDebt,
      minimumPayment: JsonParseUtils.parseAmount(
        json['minimumPayment'] ??
            json['minimum_payment'] ??
            json['asgariOdeme'],
      ),
      lastPaymentDate: JsonParseUtils.readString(json, [
        'lastPaymentDate',
        'last_payment_date',
        'sonOdemeTarihi',
      ]),
      paymentDueDate: JsonParseUtils.readString(json, [
        'paymentDueDate',
        'payment_due_date',
        'dueDate',
        'sonOdemeTarihiEkstre',
        'vadeTarihi',
      ]),
      previousPeriodBalance: JsonParseUtils.parseAmount(
        json['previousPeriodBalance'] ??
            json['previous_period_balance'] ??
            json['öncekiDönemAlacak'] ??
            json['oncekiDonemAlacak'],
      ),
      nextStatementDate: JsonParseUtils.readString(json, [
        'nextStatementDate',
        'gelecekKesimTarihi',
      ]),
      nextPaymentDueDate: JsonParseUtils.readString(json, [
        'nextPaymentDueDate',
        'gelecekSonOdemeTarihi',
      ]),
      cardLimit: JsonParseUtils.parseAmount(
        json['cardLimit'] ?? json['card_limit'] ?? json['kartLimiti'],
      ),
      availableLimit: JsonParseUtils.parseAmount(
        json['availableLimit'] ??
            json['available_limit'] ??
            json['kullanilabilirLimit'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'documentTitle': documentTitle,
        'period': period,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'closingBalance': closingBalance,
        'currency': currency,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'summary': summary,
        'documentType': documentType,
        'bankName': bankName,
        'cardLabel': cardLabel,
        'cardLastFour': cardLastFour,
        'currentDebt': currentDebt,
        'minimumPayment': minimumPayment,
        'lastPaymentDate': lastPaymentDate,
        'paymentDueDate': paymentDueDate,
        'previousPeriodBalance': previousPeriodBalance,
        'nextStatementDate': nextStatementDate,
        'nextPaymentDueDate': nextPaymentDueDate,
        'cardLimit': cardLimit,
        'availableLimit': availableLimit,
      };

  DocumentAnalysisModel copyWith({
    String? documentTitle,
    String? period,
    double? totalIncome,
    double? totalExpense,
    double? closingBalance,
    String? currency,
    List<TransactionModel>? transactions,
    String? summary,
    String? documentType,
    String? bankName,
    String? cardLabel,
    String? cardLastFour,
    double? currentDebt,
    double? minimumPayment,
    String? lastPaymentDate,
    String? paymentDueDate,
    double? previousPeriodBalance,
    String? nextStatementDate,
    String? nextPaymentDueDate,
    double? cardLimit,
    double? availableLimit,
  }) {
    return DocumentAnalysisModel(
      documentTitle: documentTitle ?? this.documentTitle,
      period: period ?? this.period,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      closingBalance: closingBalance ?? this.closingBalance,
      currency: currency ?? this.currency,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      documentType: documentType ?? this.documentType,
      bankName: bankName ?? this.bankName,
      cardLabel: cardLabel ?? this.cardLabel,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      currentDebt: currentDebt ?? this.currentDebt,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      previousPeriodBalance:
          previousPeriodBalance ?? this.previousPeriodBalance,
      nextStatementDate: nextStatementDate ?? this.nextStatementDate,
      nextPaymentDueDate: nextPaymentDueDate ?? this.nextPaymentDueDate,
      cardLimit: cardLimit ?? this.cardLimit,
      availableLimit: availableLimit ?? this.availableLimit,
    );
  }
}
