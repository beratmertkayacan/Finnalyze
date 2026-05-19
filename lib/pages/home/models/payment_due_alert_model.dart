class PaymentDueAlertModel {
  const PaymentDueAlertModel({
    required this.documentId,
    required this.title,
    required this.dueDateLabel,
    required this.daysRemaining,
    this.bankName = '',
  });

  final String documentId;
  final String title;
  final String bankName;
  final String dueDateLabel;
  final int daysRemaining;

  bool get isOverdue => daysRemaining < 0;
  bool get isDueToday => daysRemaining == 0;
}
