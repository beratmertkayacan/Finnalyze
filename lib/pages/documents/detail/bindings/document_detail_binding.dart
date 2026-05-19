import 'package:get/get.dart';
import '../controllers/document_detail_controller.dart';
class DocumentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentDetailController>(
      () => DocumentDetailController(),
      fenix: true,
    );
  }
}
