import 'package:get/get.dart';
import '../routes/routes.dart';
import '../pages/splash/views/splash_view.dart';
import '../pages/auth/login/views/login_view.dart';
import '../pages/auth/login/bindings/login_binding.dart';
import '../pages/auth/register/views/register_view.dart';
import '../pages/auth/register/bindings/register_binding.dart';
import '../pages/home/views/home_view.dart';
import '../pages/home/bindings/home_binding.dart';
import '../pages/documents/upload/views/document_upload_view.dart';
import '../pages/documents/upload/bindings/document_upload_binding.dart';
import '../pages/documents/detail/views/document_detail_view.dart';
import '../pages/documents/detail/bindings/document_detail_binding.dart';
import '../pages/documents/list/views/document_list_view.dart';
import '../pages/documents/list/bindings/document_list_binding.dart';
import '../pages/documents/aggregate/views/aggregate_view.dart';
import '../pages/documents/aggregate/bindings/aggregate_binding.dart';

abstract class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash,         page: () => const SplashView()),
    GetPage(name: AppRoutes.login,          page: () => const LoginView(),          binding: LoginBinding()),
    GetPage(name: AppRoutes.register,       page: () => const RegisterView(),       binding: RegisterBinding()),
    GetPage(name: AppRoutes.home,           page: () => const HomeView(),           binding: HomeBinding()),
    GetPage(name: AppRoutes.documentUpload, page: () => const DocumentUploadView(), binding: DocumentUploadBinding()),
    GetPage(name: AppRoutes.documentDetail, page: () => const DocumentDetailView(), binding: DocumentDetailBinding()),
    GetPage(name: AppRoutes.documentList,   page: () => const DocumentListView(),   binding: DocumentListBinding()),
    GetPage(name: AppRoutes.aggregate,      page: () => const AggregateView(),      binding: AggregateBinding()),
  ];
}
