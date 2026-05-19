import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';

class InsightCardsWidget extends GetView<DocumentDetailController> {
  const InsightCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final topExpense = controller.topExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'doc_detail_insights_title'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSm),
        _InsightCard(
          emoji: '🔴',
          title: 'doc_detail_top_expense'.tr,
          value: topExpense != null
              ? '${topExpense.description}\n${DocumentDetailFormat.money(topExpense.amount)}'
              : 'doc_detail_no_expense'.tr,
          accentColor: AppColors.negative,
        ),
        const SizedBox(height: AppConstants.paddingSm),
        _InsightCard(
          emoji: '🟡',
          title: 'doc_detail_total_transactions'.tr,
          value: controller.transactionCount.toString(),
          accentColor: AppColors.neutral,
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final String emoji;
  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppConstants.paddingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingXs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
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
