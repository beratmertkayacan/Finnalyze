import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../controllers/home_controller.dart';

class HomeQuickInsightsRow extends GetView<HomeController> {
  const HomeQuickInsightsRow({super.key});

  static final _money = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doc = controller.selectedHomeDoc;
      if (doc == null) return const SizedBox.shrink();

      final expense = doc.analysis.totalExpense;
      final insight = controller.selectedDocAiInsight;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMd,
          0,
          AppConstants.paddingMd,
          AppConstants.paddingLg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TotalSpendingCard(amount: _money.format(expense)),
            ),
            const SizedBox(width: AppConstants.paddingSm),
            Expanded(
              child: _AiInsightCard(text: insight),
            ),
          ],
        ),
      );
    });
  }
}

class _TotalSpendingCard extends StatelessWidget {
  const _TotalSpendingCard({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
            size: AppConstants.iconMd,
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Text(
            'home_total_spending_label'.tr,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXs),
          Text(
            amount,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: AppConstants.iconSm,
              ),
              const SizedBox(width: AppConstants.paddingXs),
              Text(
                'home_ai_suggestion_label'.tr,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
