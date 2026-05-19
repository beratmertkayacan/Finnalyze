import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/login_controller.dart';

class LoginRememberMeRow extends GetView<LoginController> {
  const LoginRememberMeRow({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isChecked = controller.rememberMe.value;

      return Row(
        children: [
          SizedBox(
            height: AppConstants.loginCheckboxSize,
            width: AppConstants.loginCheckboxSize,
            child: Checkbox(
              value: isChecked,
              onChanged: controller.toggleRememberMe,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusSm / 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingXs),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.toggleRememberMe(!isChecked),
              behavior: HitTestBehavior.opaque,
              child: Text(
                'remember_me'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: compact ? 13 : null,
                    ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
