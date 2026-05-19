class ExpenseCategoryStat {
  const ExpenseCategoryStat({
    required this.key,
    required this.total,
    required this.count,
    required this.percent,
  });

  final String key;
  final double total;
  final int count;
  final double percent;
}
