import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/colors.dart';
import '../core/constants.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.amountLabel,
    this.icon = Icons.description_outlined,
    this.onTap,
    this.onMenuTap,
  });

  final String title;
  final String dateLabel;
  final String amountLabel;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppConstants.homeDocIconSize,
                height: AppConstants.homeDocIconSize,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: AppColors.onSecondaryContainer,
                  size: AppConstants.iconMd,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingXs),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            dateLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingXs,
                          ),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text(
                          amountLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const _AiSummaryBadge(),
                  const SizedBox(height: AppConstants.paddingSm),
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: AppConstants.iconMd,
                      minHeight: AppConstants.iconMd,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiSummaryBadge extends StatelessWidget {
  const _AiSummaryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingXs,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: AppConstants.homeAiBadgeIconSize,
            color: AppColors.onPrimary,
          ),
          const SizedBox(width: AppConstants.paddingXs),
          Text(
            'home_ai_summary_badge'.tr,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
