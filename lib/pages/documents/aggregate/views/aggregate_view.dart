import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../../../global_widgets/ai_notes_list.dart';
import '../../../../global_widgets/shimmer_box.dart';
import '../controllers/aggregate_controller.dart';

class AggregateView extends GetView<AggregateController> {
  const AggregateView({super.key});

  static final _money = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: Text(
          'aggregate_title'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        final _ = controller.documentCount;
        if (!controller.hasDocuments) {
          return const _EmptyState();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMd,
            0,
            AppConstants.paddingMd,
            AppConstants.paddingXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TotalsSummaryCard(money: _money),
              const SizedBox(height: AppConstants.paddingMd),
              _MonthlyBarChart(money: _money),
              const SizedBox(height: AppConstants.paddingMd),
              _CategoryBreakdown(money: _money),
              const SizedBox(height: AppConstants.paddingMd),
              const _AiInsightSection(),
            ],
          ),
        );
      }),
    );
  }
}

class _TotalsSummaryCard extends GetView<AggregateController> {
  const _TotalsSummaryCard({required this.money});

  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'aggregate_grand_total'.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              _TotalChip(
                label: 'aggregate_total_expense'.tr,
                value: money.format(controller.grandTotalExpense),
                color: AppColors.negative,
              ),
              const SizedBox(width: AppConstants.paddingSm),
              if (controller.grandTotalDebt > 0)
                _TotalChip(
                  label: 'aggregate_total_debt'.tr,
                  value: money.format(controller.grandTotalDebt),
                  color: AppColors.primary,
                ),
              if (controller.grandTotalDebt <= 0 &&
                  controller.grandTotalIncome > 0)
                _TotalChip(
                  label: 'aggregate_total_income'.tr,
                  value: money.format(controller.grandTotalIncome),
                  color: AppColors.positive,
                ),
              const SizedBox(width: AppConstants.paddingSm),
              _TotalChip(
                label: 'aggregate_doc_count'.tr,
                value: '${controller.documentCount}',
                color: AppColors.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  const _TotalChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingSm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends GetView<AggregateController> {
  const _MonthlyBarChart({required this.money});

  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final stats = controller.monthlyStats;
    if (stats.length < 2) return const SizedBox.shrink();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'aggregate_monthly_chart'.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: controller.barMaxY,
                minY: 0,
                barGroups: controller.barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= stats.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            stats[i].label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        money.format(rod.toY),
                        const TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends GetView<AggregateController> {
  const _CategoryBreakdown({required this.money});

  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final cats = controller.topCategories;
    if (cats.isEmpty) return const SizedBox.shrink();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'aggregate_top_categories'.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          ...cats.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        controller.categoryEmojiFor(cat.key),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: AppConstants.paddingXs),
                      Expanded(
                        child: Text(
                          controller.categoryLabel(cat.key),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                        ),
                      ),
                      Text(
                        '${cat.percent.toStringAsFixed(0)}%',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: AppConstants.paddingSm),
                      Text(
                        money.format(cat.total),
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.negative,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingXs),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSm),
                    child: LinearProgressIndicator(
                      value: cat.percent / 100,
                      minHeight: 5,
                      backgroundColor:
                          AppColors.outlineVariant.withValues(alpha: 0.3),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightSection extends GetView<AggregateController> {
  const _AiInsightSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.aiInsightStatus.value) {
        case 'loading':
          return const ShimmerBox(
            width: double.infinity,
            height: 120,
            borderRadius: AppConstants.radiusLg,
          );
        case 'done':
          return Container(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            decoration: BoxDecoration(
              gradient: AppColors.aiGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.onPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: AppConstants.paddingXs),
                    Text(
                      'aggregate_ai_insight'.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSm),
                AiNotesList(
                  text: controller.aiInsightText.value,
                  noteBackgroundColor:
                      AppColors.onPrimary.withValues(alpha: 0.12),
                ),
              ],
            ),
          );
        case 'error':
          return OutlinedButton.icon(
            onPressed: controller.loadAiInsight,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('aggregate_ai_retry'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          );
        default:
          return FilledButton.icon(
            onPressed: controller.loadAiInsight,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text('aggregate_ai_load'.tr),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize:
                  const Size.fromHeight(AppConstants.buttonHeight),
            ),
          );
      }
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 56,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Text(
              'aggregate_empty'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
