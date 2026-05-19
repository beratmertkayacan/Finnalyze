import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'core/app_date_formats.dart';
import 'core/colors.dart';
import 'core/locale_utils.dart';
import 'core/localization/app_translations.dart';
import 'routes/pages.dart';
import 'routes/routes.dart';
import 'services/document_storage_service.dart';
import 'services/gemini_service.dart';
import 'services/pdf_file_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) — required for Gemini API key
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    assert(false, 'Missing .env — copy .env.example and set GEMINI_API_KEY');
  }

  // Initialize GetStorage for local persistence
  await GetStorage.init();

  await AppDateFormats.ensureInitialized();

  await PdfFileService.init();

  Get.put(GeminiService(), permanent: true);
  Get.put(DocumentStorageService(), permanent: true);

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final box = GetStorage();
  final initialLocale = LocaleUtils.readSaved(box);

  runApp(FinnalyzeApp(initialLocale: initialLocale));
}

class FinnalyzeApp extends StatelessWidget {
  const FinnalyzeApp({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Fin'nalyze",
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
