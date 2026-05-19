import '../../../core/constants.dart';
import '../../documents/models/stored_document_model.dart';
import '../models/payment_due_alert_model.dart';

abstract class PaymentDueUtils {
  static DateTime? parseDueDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    final normalized = value.replaceAll('/', '.');
    final parts = normalized.split('.');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0].trim());
      final month = int.tryParse(parts[1].trim());
      var year = int.tryParse(parts[2].trim());
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  static List<PaymentDueAlertModel> alertsFromDocuments(
    List<StoredDocumentModel> documents,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alerts = <PaymentDueAlertModel>[];

    for (final doc in documents) {
      final due = parseDueDate(doc.analysis.paymentDueDate);
      if (due == null) continue;

      final dueDay = DateTime(due.year, due.month, due.day);
      final daysRemaining = dueDay.difference(today).inDays;
      if (daysRemaining > AppConstants.paymentDueAlertWithinDays) continue;

      alerts.add(
        PaymentDueAlertModel(
          documentId: doc.id,
          title: doc.displayTitle,
          bankName: doc.analysis.bankName,
          dueDateLabel: doc.analysis.paymentDueDate,
          daysRemaining: daysRemaining,
        ),
      );
    }

    alerts.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return alerts;
  }
}
