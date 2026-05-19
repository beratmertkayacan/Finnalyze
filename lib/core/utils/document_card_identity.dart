import '../../pages/documents/models/stored_document_model.dart';

/// Matches the same physical card across statement periods (e.g. Maximum Genç Visa).
class DocumentCardIdentity {
  DocumentCardIdentity._();

  static String key(StoredDocumentModel doc) {
    final a = doc.analysis;
    final label = a.cardLabel.trim().toLowerCase();
    if (label.isNotEmpty) {
      final last4 = a.cardLastFour.trim();
      return last4.isNotEmpty ? '$label|$last4' : label;
    }

    final bank = a.bankName.trim().toLowerCase();
    final last4 = a.cardLastFour.trim();
    if (bank.isNotEmpty && last4.isNotEmpty) return '$bank|$last4';

    final title = a.documentTitle.trim().toLowerCase();
    if (title.isNotEmpty) return title;

    return doc.fileName.trim().toLowerCase();
  }

  static bool isSameCard(StoredDocumentModel a, StoredDocumentModel b) {
    if (a.id == b.id) return true;
    final ka = key(a);
    final kb = key(b);
    if (ka.isEmpty || kb.isEmpty) return false;
    return ka == kb;
  }
}
