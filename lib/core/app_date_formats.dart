import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Safe date formatting — avoids [LocaleDataException] after hot reload.
abstract class AppDateFormats {
  AppDateFormats._();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initializeDateFormatting('tr_TR', null);
    await initializeDateFormatting('en_US', null);
    _initialized = true;
  }

  static String weekdayMonth(DateTime date, {required String languageCode}) {
    try {
      final locale = languageCode == 'en' ? 'en_US' : 'tr_TR';
      return DateFormat('EEEE, d MMMM', locale).format(date);
    } catch (_) {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  static String dayMonth(DateTime date, {required String languageCode}) {
    try {
      final locale = languageCode == 'en' ? 'en_US' : 'tr_TR';
      return DateFormat('d MMM', locale).format(date);
    } catch (_) {
      return '${date.day}.${date.month}';
    }
  }

  static String monthYear(DateTime date, {String languageCode = 'tr'}) {
    try {
      final locale = languageCode == 'en' ? 'en_US' : 'tr_TR';
      return DateFormat('MMMM yyyy', locale).format(date);
    } catch (_) {
      return '${date.month}.${date.year}';
    }
  }
}
