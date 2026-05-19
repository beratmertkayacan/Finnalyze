import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../controllers/home_controller.dart';

class HomeGreetingSection extends GetView<HomeController> {
  const HomeGreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              controller.greetingText(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingXs),
            Text(
              controller.greetingDateText(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSm),
            Text(
              controller.greetingTaglineText(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
