import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_upload_controller.dart';

class UploadStepperWidget extends GetView<DocumentUploadController> {
  const UploadStepperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final steps = [
        ('upload_step_choose'.tr, UploadStep.choose),
        ('upload_step_review'.tr, UploadStep.review),
        ('upload_step_analyze'.tr, UploadStep.analyze),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLg,
          vertical: AppConstants.paddingMd,
        ),
        child: Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepBefore = steps[index ~/ 2].$2;
              final active = controller.isStepActive(stepBefore);
              return Expanded(
                child: Container(
                  height: 2,
                  color: active
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              );
            }

            final stepIndex = index ~/ 2;
            final label = steps[stepIndex].$1;
            final step = steps[stepIndex].$2;
            final active = controller.isStepActive(step);
            final current = controller.isStepCurrent(step);

            return _StepCircle(
              number: stepIndex + 1,
              label: label,
              active: active,
              current: current,
            );
          }),
        ),
      );
    });
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.number,
    required this.label,
    required this.active,
    required this.current,
  });

  final int number;
  final String label;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppConstants.uploadStepperCircleSize,
          height: AppConstants.uploadStepperCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.surfaceContainer,
            border: Border.all(
              color: active ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: current
                    ? AppColors.primary
                    : active
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
        if (current) ...[
          const SizedBox(height: AppConstants.paddingXs),
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}
