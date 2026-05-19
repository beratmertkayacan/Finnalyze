import 'package:get/get.dart';

import 'en.dart';
import 'tr.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'tr_TR': tr,
        'en_US': en,
      };
}
