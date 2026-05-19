import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/login_controller.dart';

class LoginPrimaryButton extends GetView<LoginController> {
  const LoginPrimaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;

      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          gradient: loading
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: loading ? AppColors.primary.withValues(alpha: 0.7) : null,
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: AppConstants.loginPrimaryButtonShadowBlur,
                    offset: const Offset(0, AppConstants.paddingXs),
                  ),
                ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: loading ? null : controller.submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: AppConstants.loginProgressSize,
                    height: AppConstants.loginProgressSize,
                    child: CircularProgressIndicator(
                      strokeWidth: AppConstants.loginProgressStroke,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'login_button'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                      ),
                      const SizedBox(width: AppConstants.paddingSm),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingXs),
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: AppConstants.loginArrowIconSize,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
