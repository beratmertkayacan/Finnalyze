import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

class UploadAiInfoCard extends StatelessWidget {
  const UploadAiInfoCard({super.key});

  static const _featureKeys = [
    'upload_ai_feature_1',
    'upload_ai_feature_2',
    'upload_ai_feature_3',
    'upload_ai_feature_4',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingXs),
                  decoration: BoxDecoration(
                    gradient: AppColors.aiGradient,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: AppConstants.iconSm,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Text(
                  'upload_ai_section_title'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.positive,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMd),
            ..._featureKeys.map(
              (key) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
                child: _FeatureRow(text: key.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.positive.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.positive,
          ),
        ),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}
