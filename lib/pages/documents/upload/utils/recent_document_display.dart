import 'package:intl/intl.dart';

import '../../models/document_analysis_model.dart';
import '../../models/stored_document_model.dart';

/// Titles and subtitles for "Son Tarananlar" list rows.
class RecentDocumentDisplay {
  RecentDocumentDisplay._();

  static final _monthYear = DateFormat('MMMM yyyy', 'tr_TR');

  static String headline({
    required DocumentAnalysisModel analysis,
    required DateTime uploadedAt,
    String? fileName,
  }) {
    final period = analysis.period.trim();
    var bank = _resolveBankName(analysis);
    if (bank.isEmpty && fileName != null) {
      bank = bankFromFileName(fileName);
    }

    if (period.isNotEmpty && bank.isNotEmpty) {
      return '$period · $bank';
    }
    if (period.isNotEmpty) return period;
    if (bank.isNotEmpty) return bank;

    final monthLabel = _monthYear.format(uploadedAt);
    if (bank.isNotEmpty) {
      return '$monthLabel · $bank';
    }
    if (analysis.documentTitle.trim().isNotEmpty) {
      return analysis.documentTitle.trim();
    }
    return monthLabel;
  }

  static String headlineForStored(StoredDocumentModel stored) {
    // Always use the same smart title logic as StoredDocumentCard
    return stored.smartTitle;
  }

  static String fileNameSubtitle(StoredDocumentModel stored) =>
      stored.smartPeriodLabel;

  static String bankFromFileName(String fileName) {
    final name = fileName.toLowerCase();
    const banks = <String, String>{
      'garanti': 'Garanti BBVA',
      'akbank': 'Akbank',
      'yapı': 'Yapı Kredi',
      'yapi': 'Yapı Kredi',
      'iş bank': 'İş Bankası',
      'is bank': 'İş Bankası',
      'ziraat': 'Ziraat Bankası',
      'halkbank': 'Halkbank',
      'vakıf': 'VakıfBank',
      'vakif': 'VakıfBank',
      'deniz': 'DenizBank',
      'qnb': 'QNB Finansbank',
      'finansbank': 'QNB Finansbank',
      'enpara': 'Enpara',
      'teb': 'TEB',
      'ing': 'ING',
      'kuveyt': 'Kuveyt Türk',
    };
    for (final entry in banks.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return '';
  }

  static String _resolveBankName(DocumentAnalysisModel analysis) {
    if (analysis.bankName.trim().isNotEmpty) {
      return analysis.bankName.trim();
    }
    final fromTitle = _bankFromDocumentTitle(analysis.documentTitle);
    if (fromTitle.isNotEmpty) return fromTitle;
    return '';
  }

  static String _bankFromDocumentTitle(String title) {
    final lower = title.toLowerCase();
    const banks = <String, String>{
      'garanti': 'Garanti BBVA',
      'akbank': 'Akbank',
      'yapı kredi': 'Yapı Kredi',
      'yapi kredi': 'Yapı Kredi',
      'iş bank': 'İş Bankası',
      'is bank': 'İş Bankası',
      'ziraat': 'Ziraat Bankası',
      'halkbank': 'Halkbank',
      'vakıfbank': 'VakıfBank',
      'vakifbank': 'VakıfBank',
      'denizbank': 'DenizBank',
      'qnb': 'QNB Finansbank',
      'enpara': 'Enpara',
    };
    for (final entry in banks.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '';
  }
}
