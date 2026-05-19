import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/login_controller.dart';
import 'login_form_field.dart';

class LoginPasswordInput extends GetView<LoginController> {
  const LoginPasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'password_label'.tr,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            TextButton(
              onPressed: controller.onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'forgot_password'.tr,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Obx(() {
          final isVisible = controller.isPasswordVisible.value;

          return LoginFormField(
            label: '',
            showLabel: false,
            controller: controller.passwordController,
            validator: controller.validatePassword,
            obscureText: !isVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: AppConstants.loginPasswordIconSize,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          );
        }),
      ],
    );
  }
}
