import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';

class DetailRecurringPaymentsSection extends GetView<DocumentDetailController> {
  const DetailRecurringPaymentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final recurring = controller.recurringPayments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'doc_detail_recurring_title'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSm),
        if (recurring.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'doc_detail_recurring_empty'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < recurring.length; i++) ...[
                  _RecurringRow(item: recurring[i]),
                  if (i < recurring.length - 1)
                    Divider(
                      height: 1,
                      indent: AppConstants.paddingMd,
                      endIndent: AppConstants.paddingMd,
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RecurringRow extends StatelessWidget {
  const _RecurringRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final count = item['count'] as int;
    final total = item['total'] as double;
    final description = item['description'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: const Icon(
              Icons.repeat_rounded,
              color: AppColors.primary,
              size: AppConstants.iconSm,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingXs / 2),
                Text(
                  'doc_detail_recurring_count'.trParams({
                    'count': count.toString(),
                  }),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            DocumentDetailFormat.money(total),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.negative,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
