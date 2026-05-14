import 'package:get/get.dart';
import '../controllers/aggregate_controller.dart';
class AggregateBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AggregateController());
}
