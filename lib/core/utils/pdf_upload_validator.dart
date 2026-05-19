import 'dart:typed_data';

/// Client-side checks before sending a PDF to Gemini.
class PdfUploadValidator {
  PdfUploadValidator._();

  static const int geminiMaxFileSizeMb = 50;

  static bool isPdfBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final header = String.fromCharCodes(bytes.sublist(0, 5));
    return header.startsWith('%PDF');
  }

  static bool exceedsGeminiLimit(int? sizeBytes) {
    if (sizeBytes == null) return false;
    return sizeBytes > geminiMaxFileSizeMb * 1024 * 1024;
  }

  /// Heuristic: filename suggests a Turkish bank statement or card summary.
  static bool isLikelyFinancialStatement(String fileName) {
    final name = fileName.toLowerCase();
    const keywords = [
      'ekstre',
      'ekstresi',
      'hesap',
      'özet',
      'ozet',
      'kredi',
      'kart',
      'banka',
      'bank',
      'statement',
      'account',
      'extract',
      'hareket',
      'garanti',
      'iş bank',
      'is bank',
      'yapı',
      'yapi',
      'ziraat',
      'akbank',
      'vakıf',
      'vakif',
      'halkbank',
      'deniz',
      'qnb',
      'enpara',
      'finans',
      'credit',
      'debit',
      'visa',
      'master',
    ];
    return keywords.any(name.contains);
  }

  /// Whether Gemini parse error is appropriate (valid PDF, under 50MB, statement-like).
  static bool shouldShowGeminiParseError({
    required String fileName,
    required int? sizeBytes,
    required Uint8List pdfBytes,
  }) {
    if (exceedsGeminiLimit(sizeBytes)) return false;
    if (!isPdfBytes(pdfBytes)) return false;
    if (!isLikelyFinancialStatement(fileName)) return false;
    return true;
  }

  static String resolveUploadErrorKey({
    required String fileName,
    required int? sizeBytes,
    Uint8List? pdfBytes,
    bool geminiFailed = false,
  }) {
    if (exceedsGeminiLimit(sizeBytes)) return 'upload_file_too_large';
    if (pdfBytes != null && !isPdfBytes(pdfBytes)) return 'upload_invalid_pdf';
    if (!isLikelyFinancialStatement(fileName)) return 'upload_not_statement';
    if (geminiFailed &&
        pdfBytes != null &&
        shouldShowGeminiParseError(
          fileName: fileName,
          sizeBytes: sizeBytes,
          pdfBytes: pdfBytes,
        )) {
      return 'error_gemini_parse';
    }
    if (geminiFailed) return 'upload_not_statement';
    return 'upload_pick_error';
  }
}
