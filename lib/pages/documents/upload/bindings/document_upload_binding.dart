import 'package:get/get.dart';

import '../../../../services/gemini_service.dart';
import '../controllers/document_upload_controller.dart';

class DocumentUploadBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GeminiService>()) {
      Get.lazyPut(() => GeminiService(), fenix: true);
    }
    if (!Get.isRegistered<DocumentUploadController>()) {
      Get.lazyPut(() => DocumentUploadController(), fenix: true);
    }
  }
}
