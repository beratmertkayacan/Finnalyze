import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/locale_utils.dart';
import '../../../routes/routes.dart';
import '../../home/controllers/home_controller.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final userName = 'Mert'.obs;
  final userEmail = 'mert@example.com'.obs;
  final avatarInitial = 'M'.obs;
  final currentLanguageLabel = 'settings_language_tr'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _syncLanguageLabel();
  }

  void showLanguagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingXs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLg),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('settings_language_tr'.tr),
                onTap: () => _setLocale('tr'),
              ),
              ListTile(
                title: Text('settings_language_en'.tr),
                onTap: () => _setLocale('en'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text(
          'settings_about'.tr,
          style: const TextStyle(color: AppColors.onSurface),
        ),
        content: Text(
          'settings_about_text'.tr,
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'doc_delete_cancel'.tr,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text(
          'settings_logout_title'.tr,
          style: const TextStyle(color: AppColors.onSurface),
        ),
        content: Text(
          'settings_logout_confirm'.tr,
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'doc_delete_cancel'.tr,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: Text(
              'settings_logout_action'.tr,
              style: const TextStyle(color: AppColors.negative),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    isLoading(true);
    hasError(false);
    errorMessage('');
    try {
      _clearRememberedLogin();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      hasError(true);
      errorMessage('login_error'.tr);
      Get.snackbar(
        'settings_logout'.tr,
        'login_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(AppConstants.paddingMd),
      );
    } finally {
      isLoading(false);
    }
  }

  void _loadProfile() {
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      userName.value = home.userName.value;
      avatarInitial.value = home.avatarInitial.value;
    }
  }

  void _setLocale(String languageCode) {
    Get.back();
    Get.updateLocale(LocaleUtils.fromLanguageCode(languageCode));
    _box.write(AppConstants.localeStorageKey, languageCode);
    currentLanguageLabel.value = LocaleUtils.labelKeyForCode(languageCode);
  }

  void _syncLanguageLabel() {
    final code = Get.locale?.languageCode ??
        _box.read<String>(AppConstants.localeStorageKey) ??
        'tr';
    currentLanguageLabel.value = LocaleUtils.labelKeyForCode(code);
  }

  void _clearRememberedLogin() {
    _box.remove(AppConstants.rememberMeStorageKey);
    _box.remove(AppConstants.rememberedEmailStorageKey);
  }
}
