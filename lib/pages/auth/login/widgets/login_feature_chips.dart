import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

class LoginFeatureChips extends StatelessWidget {
  const LoginFeatureChips({super.key, this.compact = false});

  final bool compact;

  static const _features = <(String, IconData)>[
    ('login_feature_upload', Icons.upload_file_outlined),
    ('login_feature_ai', Icons.auto_awesome_outlined),
    ('login_feature_card_summary', Icons.credit_card_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppConstants.paddingXs,
      runSpacing: AppConstants.paddingXs,
      children: _features
          .map(
            (feature) => _FeatureChip(
              label: feature.$1.tr,
              icon: feature.$2,
              compact: compact,
            ),
          )
          .toList(),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
    required this.icon,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppConstants.paddingSm : AppConstants.paddingMd,
        vertical: AppConstants.paddingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppConstants.loginFeatureChipIconSize,
            color: AppColors.textOnPrimary.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppConstants.paddingXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11 : 12,
                ),
          ),
        ],
      ),
    );
  }
}
