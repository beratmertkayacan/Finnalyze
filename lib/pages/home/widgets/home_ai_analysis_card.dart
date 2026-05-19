import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../global_widgets/shimmer_box.dart';
import '../controllers/home_controller.dart';

const _categoryEmoji = {
  'market': '🛒',
  'food': '🍽️',
  'clothing': '👕',
  'transport': '🚗',
  'bills': '🌐',
  'health': '💊',
  'entertainment': '🎬',
  'education': '📚',
  'subscription': '📱',
  'transfer': '💸',
  'other': '📦',
};

const _categoryNames = {
  'market': 'Market',
  'food': 'Yemek',
  'clothing': 'Giyim',
  'transport': 'Ulaşım',
  'bills': 'Faturalar',
  'health': 'Sağlık',
  'entertainment': 'Eğlence',
  'education': 'Eğitim',
  'subscription': 'Dijital',
  'transfer': 'Transfer',
  'other': 'Diğer',
};

class HomeInsightsCard extends GetView<HomeController> {
  const HomeInsightsCard({super.key});

  static final _money = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        0,
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerBox(
            width: double.infinity,
            height: 120,
            borderRadius: AppConstants.radiusLg,
          );
        }
        controller.homeDocuments.length;
        return controller.hasAnyData
            ? _InsightsBody(controller: controller, money: _money)
            : _UploadCta(controller: controller);
      }),
    );
  }
}

class _InsightsBody extends StatelessWidget {
  const _InsightsBody({required this.controller, required this.money});

  final HomeController controller;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final topKey = controller.topExpenseCategoryKey;
    final topTotal = controller.topExpenseCategoryTotal;
    final topEmoji = _categoryEmoji[topKey] ?? '📦';
    final topName = _categoryNames[topKey] ?? topKey;
    final debt = controller.totalCreditCardDebt;
    final totalExp = controller.totalExpenseAllDocs;
    final docCount = controller.analyzedDocumentCount.value;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'home_insights_title'.tr,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingXs,
                  vertical: AppConstants.paddingXs / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                ),
                child: Text(
                  '$docCount ${'home_insights_doc_count'.tr}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              if (topKey.isNotEmpty)
                Expanded(
                  child: _StatTile(
                    emoji: topEmoji,
                    label: '${'home_insights_top_category'.tr}\n$topName',
                    value: money.format(topTotal),
                    valueColor: AppColors.negative,
                  ),
                ),
              if (topKey.isNotEmpty) const SizedBox(width: AppConstants.paddingSm),
              if (debt > 0)
                Expanded(
                  child: _StatTile(
                    emoji: '💳',
                    label: 'home_insights_total_debt'.tr,
                    value: money.format(debt),
                    valueColor: AppColors.negative,
                  ),
                ),
              if (debt <= 0 && totalExp > 0)
                Expanded(
                  child: _StatTile(
                    emoji: '📊',
                    label: 'home_insights_total_expense'.tr,
                    value: money.format(totalExp),
                    valueColor: AppColors.onSurface,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.goToAnalyses,
                  icon: const Icon(
                    Icons.analytics_outlined,
                    size: AppConstants.iconSm,
                  ),
                  label: Text('home_view_analyses'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingXs,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: controller.goToDocumentsTab,
                  icon: const Icon(
                    Icons.upload_file_rounded,
                    size: AppConstants.iconSm,
                  ),
                  label: Text('home_ai_upload_new'.tr),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingXs,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String emoji;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: AppConstants.paddingXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _UploadCta extends StatelessWidget {
  const _UploadCta({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'home_ai_ready_title'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXs),
          Text(
            'home_cta_subtitle'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          FilledButton.icon(
            onPressed: controller.goToDocumentsTab,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text('home_ai_upload_new'.tr),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.onPrimary,
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
