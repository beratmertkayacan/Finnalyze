import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/constants.dart';
import '../../../../routes/routes.dart';

class LoginController extends GetxController {
  // 1. Services / dependencies — Firebase Auth will be injected here later
  final _box = GetStorage();

  // 2. Reactive state
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;

  // 4. Controllers & keys
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // 6. Lifecycle
  @override
  void onInit() {
    super.onInit();
    _restoreRememberedSession();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // 7. Public methods
  void submitForm() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _signInWithEmail();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  void onForgotPassword() {
    Get.snackbar(
      'forgot_password'.tr,
      'forgot_password_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppConstants.paddingMd),
    );
  }

  void onGoogleSignIn() {
    Get.snackbar(
      'sign_in_with_google'.tr,
      'google_sign_in_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppConstants.paddingMd),
    );
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'email_empty'.tr;
    if (!GetUtils.isEmail(value)) return 'email_invalid'.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'password_empty'.tr;
    if (value.length < 6) return 'password_min_length'.tr;
    return null;
  }

  // 8. Private methods
  void _restoreRememberedSession() {
    final savedRemember = _box.read<bool>(AppConstants.rememberMeStorageKey) ?? false;
    rememberMe.value = savedRemember;
    if (!savedRemember) return;

    final email = _box.read<String>(AppConstants.rememberedEmailStorageKey);
    if (email != null && email.isNotEmpty) {
      emailController.text = email;
    }
  }

  void _persistRememberMe() {
    if (rememberMe.value) {
      _box.write(AppConstants.rememberMeStorageKey, true);
      _box.write(
        AppConstants.rememberedEmailStorageKey,
        emailController.text.trim(),
      );
    } else {
      _box.remove(AppConstants.rememberMeStorageKey);
      _box.remove(AppConstants.rememberedEmailStorageKey);
    }
  }

  Future<void> _signInWithEmail() async {
    isLoading(true);
    hasError(false);
    errorMessage('');
    try {
      // TODO: FirebaseAuth.instance.signInWithEmailAndPassword(...)
      _persistRememberMe();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      hasError(true);
      errorMessage('login_error'.tr);
      Get.snackbar(
        'login_button'.tr,
        'login_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(AppConstants.paddingMd),
      );
    } finally {
      isLoading(false);
    }
  }
}
