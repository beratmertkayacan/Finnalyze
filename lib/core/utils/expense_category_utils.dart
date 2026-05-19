import 'package:get/get.dart';

/// Canonical expense category keys and Turkish display labels.
class ExpenseCategoryUtils {
  ExpenseCategoryUtils._();

  static const String keyOther = 'other';

  static const _canonicalKeys = {
    'market',
    'food',
    'clothing',
    'transport',
    'bills',
    'health',
    'entertainment',
    'education',
    'subscription',
    'transfer',
    keyOther,
  };

  /// Uses Gemini's [rawCategory] when present (including `other`).
  /// Description-based inference runs only when the model left category empty.
  static String normalize(String rawCategory, String description) {
    final raw = rawCategory.trim().toLowerCase();
    if (raw.isNotEmpty) {
      return _mapRawCategory(raw);
    }
    if (description.trim().isNotEmpty) {
      return _inferFromDescription(description);
    }
    return keyOther;
  }

  static String label(String categoryKey) {
    if (categoryKey == 'all') return 'doc_detail_category_all'.tr;
    return 'expense_category_$categoryKey'.tr;
  }

  static String _mapRawCategory(String raw) {
    if (_canonicalKeys.contains(raw)) return raw;

    if (_containsAny(raw, ['grocery', 'groceries', 'supermarket'])) {
      return 'market';
    }
    if (_containsAny(raw, ['dining', 'restaurant', 'cafe', 'coffee'])) {
      return 'food';
    }
    if (_containsAny(raw, ['shopping', 'retail', 'ecommerce', 'e-commerce'])) {
      return 'clothing';
    }
    if (_containsAny(raw, ['fuel', 'gas', 'parking', 'taxi'])) {
      return 'transport';
    }
    if (_containsAny(raw, ['utility', 'internet', 'mobile', 'phone'])) {
      return 'bills';
    }
    if (_containsAny(raw, ['medical', 'doctor', 'dental'])) {
      return 'health';
    }
    if (_containsAny(raw, ['streaming', 'movie', 'game'])) {
      return 'entertainment';
    }
    if (_containsAny(raw, ['school', 'tuition', 'course'])) {
      return 'education';
    }
    if (_containsAny(raw, ['digital', 'software', 'saas'])) {
      return 'subscription';
    }

    if (_containsAny(raw, [
      'market',
      'gıda',
      'gida',
      'supermarket',
      'süpermarket',
      'bakkal',
      'grocery',
      'market ve',
    ])) {
      return 'market';
    }
    if (_containsAny(raw, ['yemek', 'kafe', 'restoran', 'içecek', 'icecek'])) {
      return 'food';
    }
    if (_containsAny(raw, ['alisveris', 'alışveriş', 'giyim', 'moda'])) {
      return 'clothing';
    }
    if (_containsAny(raw, ['ulasim', 'ulaşım', 'yakit', 'yakıt', 'otobus', 'otobüs'])) {
      return 'transport';
    }
    if (_containsAny(raw, ['saglik', 'sağlık', 'eczane', 'hastane'])) {
      return 'health';
    }
    if (_containsAny(raw, ['eglence', 'eğlence', 'sinema'])) {
      return 'entertainment';
    }
    if (_containsAny(raw, ['egitim', 'eğitim', 'okul'])) {
      return 'education';
    }
    if (_containsAny(raw, ['abonelik', 'dijital'])) {
      return 'subscription';
    }
    if (_containsAny(raw, [
      'food',
      'yeme',
      'içme',
      'icecek',
      'restaurant',
      'restoran',
      'cafe',
      'kahve',
    ])) {
      return 'food';
    }
    if (_containsAny(raw, [
      'clothing',
      'giyim',
      'fashion',
      'moda',
      'shopping',
      'alisveris',
      'alışveriş',
    ])) {
      return 'clothing';
    }
    if (_containsAny(raw, [
      'transport',
      'ulaşım',
      'ulasim',
      'travel',
      'seyahat',
      'fuel',
      'yakıt',
      'yakit',
      'otobüs',
      'otobus',
    ])) {
      return 'transport';
    }
    if (_containsAny(raw, [
      'bills',
      'fatura',
      'utility',
      'utilities',
      'telekom',
      'elektrik',
      'su',
    ])) {
      return 'bills';
    }
    if (_containsAny(raw, [
      'health',
      'sağlık',
      'saglik',
      'eczane',
      'pharmacy',
      'hospital',
      'hastane',
    ])) {
      return 'health';
    }
    if (_containsAny(raw, [
      'entertainment',
      'eğlence',
      'eglence',
      'sinema',
      'oyun',
    ])) {
      return 'entertainment';
    }
    if (_containsAny(raw, [
      'education',
      'eğitim',
      'egitim',
      'okul',
      'kurs',
    ])) {
      return 'education';
    }
    if (_containsAny(raw, [
      'subscription',
      'abonelik',
      'membership',
    ])) {
      return 'subscription';
    }
    if (_containsAny(raw, [
      'transfer',
      'havale',
      'eft',
      'virman',
    ])) {
      return 'transfer';
    }
    return keyOther;
  }

  static String _inferFromDescription(String description) {
    final d = description.toLowerCase();

    if (_containsAny(d, [
      'migros',
      'bim',
      'a101',
      'şok',
      'sok',
      'carrefour',
      'macro',
      'metro gros',
      'hakmar',
    ])) {
      return 'market';
    }
    if (_containsAny(d, [
      'mcdonald',
      'burger',
      'starbucks',
      'kahve',
      'cafe',
      'kafe',
      'restaurant',
      'restoran',
      'yemek',
      'getir yemek',
      'yemeksepeti',
      'dominos',
      'pizza',
    ])) {
      return 'food';
    }
    if (_containsAny(d, [
      'zara',
      'h&m',
      'lcw',
      'lc waikiki',
      'defacto',
      'mango',
      'nike',
      'adidas',
      'bershka',
      'pull',
      'koton',
    ])) {
      return 'clothing';
    }
    if (_containsAny(d, [
      'uber',
      'bolt',
      'taksi',
      'metro',
      'iett',
      'shell',
      'opet',
      'bp ',
      'petrol',
      'akaryakıt',
      'akaryakit',
      'otopark',
      'hgs',
      'ogs',
    ])) {
      return 'transport';
    }
    if (_containsAny(d, [
      'turkcell',
      'vodafone',
      'turk telekom',
      'superonline',
      'enerjisa',
      'ck boğaziçi',
      'elektrik',
      'doğalgaz',
      'dogalgaz',
      'su fatura',
    ])) {
      return 'bills';
    }
    if (_containsAny(d, [
      'eczane',
      'pharmacy',
      'hastane',
      'hospital',
      'medical',
      'sağlık',
      'saglik',
    ])) {
      return 'health';
    }
    if (_containsAny(d, [
      'netflix',
      'spotify',
      'youtube',
      'sinema',
      'cinema',
      'blutv',
      'exxen',
    ])) {
      return 'entertainment';
    }
    if (_containsAny(d, [
      'udemy',
      'coursera',
      'okul',
      'üniversite',
      'universite',
      'kurs',
    ])) {
      return 'education';
    }

    return keyOther;
  }

  static bool _containsAny(String text, List<String> needles) {
    for (final needle in needles) {
      if (text.contains(needle)) return true;
    }
    return false;
  }
}
