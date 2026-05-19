import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'constants.dart';

/// Shared locale resolution for [main] and [SettingsController].
abstract class LocaleUtils {
  LocaleUtils._();

  static Locale fromLanguageCode(String? code) {
    return code == 'en' ? const Locale('en', 'US') : const Locale('tr', 'TR');
  }

  static Locale readSaved(GetStorage box) {
    return fromLanguageCode(box.read<String>(AppConstants.localeStorageKey));
  }

  static String toLanguageCode(Locale locale) {
    return locale.languageCode == 'en' ? 'en' : 'tr';
  }

  static String labelKeyForCode(String? code) {
    return code == 'en' ? 'settings_language_en' : 'settings_language_tr';
  }
}
