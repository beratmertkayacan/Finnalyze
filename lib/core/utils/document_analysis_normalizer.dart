import '../../pages/documents/models/document_analysis_model.dart';
import '../../pages/documents/models/transaction_model.dart';
import '../../pages/documents/upload/utils/recent_document_display.dart';
import 'expense_category_utils.dart';

/// Cleans Gemini output: canonical categories, reconciled totals from transactions.
class DocumentAnalysisNormalizer {
  DocumentAnalysisNormalizer._();

  static DocumentAnalysisModel normalize(
    DocumentAnalysisModel analysis, {
    String? fileName,
  }) {
    final transactions = analysis.transactions
        .map(_normalizeTransaction)
        .where((t) => t.amount > 0)
        .toList();

    var totalIncome = analysis.totalIncome;
    var totalExpense = analysis.totalExpense;

    if (transactions.isNotEmpty) {
      totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold<double>(0, (sum, t) => sum + t.amount);
      totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold<double>(0, (sum, t) => sum + t.amount);
    }

    final enriched = _enrichCardIdentity(
      analysis.copyWith(
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ),
      fileName: fileName,
    );
    return enriched;
  }

  /// Fills cardLabel/bankName when Gemini omits them (common on Garanti Bonus PDFs).
  static DocumentAnalysisModel _enrichCardIdentity(
    DocumentAnalysisModel analysis, {
    String? fileName,
  }) {
    var bankName = analysis.bankName.trim();
    var cardLabel = analysis.cardLabel.trim();
    var documentType = analysis.documentType.trim();

    final probe = '${analysis.documentTitle} ${analysis.summary} ${fileName ?? ''}'
        .toLowerCase();

    if (bankName.isEmpty && fileName != null) {
      bankName = RecentDocumentDisplay.bankFromFileName(fileName);
    }
    if (bankName.isEmpty && probe.contains('garanti')) {
      bankName = 'Garanti BBVA';
    }

    if (cardLabel.isEmpty) {
      if (probe.contains('bonus')) {
        if (probe.contains('bonus fb') || probe.contains('bonusfb')) {
          cardLabel = 'Bonus FB';
        } else if (probe.contains('bonus gold')) {
          cardLabel = 'Bonus Gold';
        } else {
          cardLabel = 'Bonus';
        }
      } else if (probe.contains('maximum')) {
        cardLabel = probe.contains('genç') || probe.contains('genc')
            ? 'Maximum Genç'
            : 'Maximum';
      }
    }

    if (documentType.isEmpty &&
        (cardLabel.isNotEmpty ||
            analysis.minimumPayment > 0 ||
            analysis.cardLimit > 0)) {
      documentType = 'credit_card';
    }

    if (bankName == analysis.bankName &&
        cardLabel == analysis.cardLabel &&
        documentType == analysis.documentType) {
      return analysis;
    }

    return analysis.copyWith(
      bankName: bankName.isNotEmpty ? bankName : analysis.bankName,
      cardLabel: cardLabel.isNotEmpty ? cardLabel : analysis.cardLabel,
      documentType:
          documentType.isNotEmpty ? documentType : analysis.documentType,
    );
  }

  static TransactionModel _normalizeTransaction(TransactionModel t) {
    final category = ExpenseCategoryUtils.normalize(t.category, t.description);
    final type = _resolveType(t);
    return t.copyWith(category: category, type: type);
  }

  static String _resolveType(TransactionModel t) {
    final desc = t.description.toLowerCase();
    if (_looksLikePaymentOrCredit(desc)) return 'income';
    if (t.type == 'income' || t.type == 'expense') return t.type;
    return 'expense';
  }

  static bool _looksLikePaymentOrCredit(String desc) {
    final d = desc.toLowerCase();
    const paymentHints = [
      'otomatik ödeme',
      'otomatik odeme',
      'hesap ödemesi',
      'hesap odemesi',
      'ekstre ödem',
      'min. ödeme',
      'minimum ödeme',
      'ödeme - teşekkür',
      'ödeme - tesekkur',
      'odeme - tesekkur',
      'thank you',
      'payment received',
      'iade',
      'refund',
      'para yatırma',
      'para yatirma',
      'havale gelen',
    ];
    for (final hint in paymentHints) {
      if (d.contains(hint)) return true;
    }
    return false;
  }
}
