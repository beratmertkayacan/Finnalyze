import '../../../core/utils/json_parse_utils.dart';

class TransactionModel {
  const TransactionModel({
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    this.installmentCurrent = 0,
    this.installmentTotal = 0,
  });

  final String date;
  final String description;
  final double amount;
  final String type;
  final String category;
  final int installmentCurrent;
  final int installmentTotal;

  bool get isInstallment => installmentTotal > 1;

  String get installmentLabel => '$installmentCurrent/$installmentTotal';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['tutar'] ?? json['value'];
    var amount = JsonParseUtils.parseAmount(rawAmount).abs();

    var type = JsonParseUtils.readString(json, ['type', 'islemTuru', 'transactionType'])
        .toLowerCase();
    if (type.isEmpty) {
      type = _inferType(json, amount);
    }
    type = _normalizeTransactionType(type);

    final description = JsonParseUtils.readString(json, [
      'description',
      'desc',
      'aciklama',
      'açıklama',
      'detail',
      'merchant',
    ]);

    final category = JsonParseUtils.readString(json, [
      'category',
      'kategori',
      'categoryName',
    ]);

    return TransactionModel(
      date: JsonParseUtils.readString(json, ['date', 'tarih', 'transactionDate']),
      description: description,
      amount: amount,
      type: type,
      category: category.isEmpty ? 'other' : category,
      installmentCurrent: _parseInt(
        json['installmentCurrent'] ?? json['taksitNo'],
      ),
      installmentTotal: _parseInt(
        json['installmentTotal'] ?? json['toplamTaksit'],
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// KK ekstrelerinde Gemini bazen type=credit döndürür; bu harcamadır, gelir değil.
  static String _normalizeTransactionType(String type) {
    final t = type.trim().toLowerCase();
    if (t == 'income' ||
        t == 'gelir' ||
        t == 'alacak' ||
        t.contains('income') ||
        t.contains('gelir')) {
      return 'income';
    }
    if (t == 'expense' ||
        t == 'gider' ||
        t == 'borc' ||
        t == 'borç' ||
        t == 'debit' ||
        t == 'charge' ||
        t == 'purchase' ||
        t == 'harcama' ||
        t == 'credit' ||
        t.contains('expense') ||
        t.contains('gider')) {
      return 'expense';
    }
    return 'expense';
  }

  static String _inferType(Map<String, dynamic> json, double amount) {
    final signed = JsonParseUtils.parseAmount(
      json['signedAmount'] ?? json['amount'] ?? json['tutar'],
    );
    if (signed < 0) return 'expense';
    if (signed > 0 && json.containsKey('credit')) return 'income';
    return amount >= 0 ? 'expense' : 'income';
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'description': description,
        'amount': amount,
        'type': type,
        'category': category,
        'installmentCurrent': installmentCurrent,
        'installmentTotal': installmentTotal,
      };

  TransactionModel copyWith({
    String? date,
    String? description,
    double? amount,
    String? type,
    String? category,
    int? installmentCurrent,
    int? installmentTotal,
  }) {
    return TransactionModel(
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      installmentCurrent: installmentCurrent ?? this.installmentCurrent,
      installmentTotal: installmentTotal ?? this.installmentTotal,
    );
  }
}
