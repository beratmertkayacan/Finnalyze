import 'package:get/get.dart';

import '../../documents/upload/controllers/document_upload_controller.dart';
import '../../../services/gemini_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GeminiService>()) {
      Get.lazyPut(() => GeminiService(), fenix: true);
    }
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => DocumentUploadController(), fenix: true);
  }
}
