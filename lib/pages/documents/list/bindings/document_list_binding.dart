import 'package:get/get.dart';
import '../controllers/document_list_controller.dart';
class DocumentListBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => DocumentListController());
}
