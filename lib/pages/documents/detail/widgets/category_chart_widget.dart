import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../models/expense_category_stat.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';

class CategoryChartWidget extends GetView<DocumentDetailController> {
  const CategoryChartWidget({super.key});

  static const _chartColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.positive,
    AppColors.negative,
    AppColors.neutral,
    AppColors.primaryContainer,
    AppColors.secondaryContainer,
    AppColors.aiGradientEnd,
    AppColors.onSecondaryContainer,
    AppColors.outline,
  ];

  static Color colorForIndex(int index) {
    return _chartColors[index % _chartColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final stats = controller.categoryStats;
    final total = controller.totalExpenseFromTransactions;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'doc_detail_expense_distribution'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          if (stats.isEmpty || total <= 0)
            Text(
              'doc_detail_chart_empty'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                        sections: _buildSections(stats),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMd),
                  Expanded(
                    flex: 2,
                    child: _ChartLegend(stats: stats),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            ...List.generate(
              stats.length,
              (index) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.paddingSm,
                ),
                child: _CategoryBreakdownRow(
                  stat: stats[index],
                  color: colorForIndex(index),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<ExpenseCategoryStat> stats) {
    return List.generate(stats.length, (index) {
      final stat = stats[index];
      return PieChartSectionData(
        value: stat.total,
        color: colorForIndex(index),
        radius: 52,
        title: '${stat.percent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
    });
  }
}

class _ChartLegend extends GetView<DocumentDetailController> {
  const _ChartLegend({required this.stats});

  final List<ExpenseCategoryStat> stats;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.paddingXs),
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = CategoryChartWidget.colorForIndex(index);

        return Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppConstants.paddingXs),
            Expanded(
              child: Text(
                controller.categoryLabel(stat.key),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
            ),
            Text(
              '${stat.percent.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  const _CategoryBreakdownRow({
    required this.stat,
    required this.color,
  });

  final ExpenseCategoryStat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentDetailController>();
    return Obx(() {
      final isSelected = controller.selectedCategory.value == stat.key;

      return Material(
        color: isSelected
            ? AppColors.secondaryContainer.withValues(alpha: 0.5)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: InkWell(
          onTap: () {
            controller.focusCategoryInTransactions(stat.key);
            final tabController = DefaultTabController.maybeOf(context);
            tabController?.animateTo(
              DocumentDetailController.transactionsTabIndex,
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
              vertical: AppConstants.paddingSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.categoryLabel(stat.key),
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                      ),
                      Text(
                        'doc_detail_category_tx_count'.trParams({
                          'count': stat.count.toString(),
                        }),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DocumentDetailFormat.money(stat.total),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.negative,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      '${stat.percent.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(width: AppConstants.paddingXs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: AppConstants.iconMd,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
