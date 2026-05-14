import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

import 'routes/pages.dart';
import 'routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await dotenv.load(fileName: '.env');

  // Initialize GetStorage for local persistence
  await GetStorage.init();

  // TODO: Firebase.initializeApp() — add after FlutterFire configure
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FinnalyzeApp());
}

class FinnalyzeApp extends StatelessWidget {
  const FinnalyzeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Fin'nalyze",
      debugShowCheckedModeBanner: false,
      // Theme — will be filled in core/theme.dart
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B6CA8)),
        useMaterial3: true,
      ),
      // Routing
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
