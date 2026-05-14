import 'package:get/get.dart';
import '../controllers/document_upload_controller.dart';
class DocumentUploadBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => DocumentUploadController());
}
