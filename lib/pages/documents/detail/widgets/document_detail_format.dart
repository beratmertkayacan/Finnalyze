import 'package:intl/intl.dart';

class DocumentDetailFormat {
  DocumentDetailFormat._();

  static final _currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static String money(double amount) => _currency.format(amount);
}
