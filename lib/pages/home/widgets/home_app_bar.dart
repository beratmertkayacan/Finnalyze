import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../controllers/home_controller.dart';

class HomeAppBar extends GetView<HomeController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingSm,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
      ),
      child: Row(
        children: [
          Obx(
            () => GestureDetector(
              onTap: () => controller.onTabSelected(3),
              child: CircleAvatar(
                radius: AppConstants.homeAvatarSize / 2,
                backgroundColor: AppColors.primary,
                child: Text(
                  controller.avatarInitial.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: Text(
              'app_name'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
          ),
          Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: controller.onNotificationTap,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primary,
                  ),
                ),
                if (controller.hasNotificationAlerts)
                  Positioned(
                    right: AppConstants.paddingSm,
                    top: AppConstants.paddingSm,
                    child: Container(
                      width: AppConstants.paddingXs,
                      height: AppConstants.paddingXs,
                      decoration: const BoxDecoration(
                        color: AppColors.negative,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
