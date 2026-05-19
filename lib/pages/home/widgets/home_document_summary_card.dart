import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/app_date_formats.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../documents/models/stored_document_model.dart';
import '../../documents/models/transaction_model.dart';
import '../controllers/home_controller.dart';
import 'document_tab_bar.dart';

class HomeDocumentSummaryCard extends GetView<HomeController> {
  const HomeDocumentSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        AppConstants.paddingXxl,
      ),
      child: Obx(() {
        final docs = controller.homeDocuments;

        if (docs.isEmpty) {
          return _EmptyState(onUpload: controller.goToDocumentsTab);
        }

        final selectedIndex = controller.selectedHomeDocIndex.value
            .clamp(0, docs.length - 1);
        final selected = docs[selectedIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'home_doc_summary_title'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (docs.length > 1) ...[
              const SizedBox(height: AppConstants.paddingSm),
              DocumentTabBar(
                docs: docs,
                selectedIndex: selectedIndex,
                onSelect: controller.selectHomeDoc,
              ),
            ],
            const SizedBox(height: AppConstants.paddingMd),
            _SummaryContent(
              doc: selected,
              previousDoc: controller.findPreviousPeriodDoc(selected),
              onViewDetail: () => controller.openDocumentDetail(selected),
              onUpload: controller.goToDocumentsTab,
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({
    required this.doc,
    required this.previousDoc,
    required this.onViewDetail,
    required this.onUpload,
  });

  final StoredDocumentModel doc;
  final StoredDocumentModel? previousDoc;
  final VoidCallback onViewDetail;
  final VoidCallback onUpload;

  static final _money = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final analysis = doc.analysis;
    final showLimit = analysis.isCreditCard && analysis.cardLimit > 0;
    final showComparison = previousDoc != null;
    final chartData = _buildStatementDailyChart(
      analysis.transactions,
      periodRaw: analysis.period,
    );

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
          Text(
            doc.smartTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          if (doc.smartPeriodLabel.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingXs / 2),
            Text(
              doc.smartPeriodLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingMd),
          if (showLimit) ...[
            _LimitBar(
              cardLimit: analysis.cardLimit,
              availableLimit: analysis.availableLimit > 0
                  ? analysis.availableLimit
                  : math.max(
                      0,
                      analysis.cardLimit - analysis.displayDebt,
                    ),
              money: _money,
            ),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          if (showComparison) ...[
            _MonthComparison(
              currentExpense: analysis.totalExpense,
              previousExpense: previousDoc!.analysis.totalExpense,
              money: _money,
            ),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          if (chartData.hasSpending) ...[
            _SpendingTrendLineChart(
              data: chartData,
              money: _money,
              periodLabel: doc.smartPeriodLabel,
            ),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewDetail,
              icon: const Icon(
                Icons.analytics_outlined,
                size: AppConstants.iconSm,
              ),
              label: Text('home_doc_btn_view'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSm,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(
                Icons.upload_file_rounded,
                size: AppConstants.iconSm,
              ),
              label: Text('home_doc_btn_upload'.tr),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ekstre döneminin tüm günleri — günlük harcama toplamları.
  static _TrendChartData _buildStatementDailyChart(
    List<TransactionModel> transactions, {
    required String periodRaw,
  }) {
    final daily = <DateTime, double>{};

    for (final t in transactions) {
      if (t.type != 'expense') continue;
      final parsed = _parseDate(t.date);
      if (parsed == null) continue;
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      daily[day] = (daily[day] ?? 0) + t.amount;
    }

    if (daily.isEmpty) {
      return const _TrendChartData(
        spots: [],
        labels: [],
        amounts: [],
      );
    }

    final txnMin = daily.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final txnMax = daily.keys.reduce((a, b) => a.isAfter(b) ? a : b);

    var start = txnMin;
    var end = txnMax;

    if (periodRaw.isNotEmpty) {
      final parts = periodRaw.split(RegExp(r'\s*[-–]\s*'));
      if (parts.length == 2) {
        final periodStart = _parseDate(parts[0].trim());
        final periodEnd = _parseDate(parts[1].trim());
        if (periodStart != null && periodEnd != null) {
          start = DateTime(
            periodStart.year,
            periodStart.month,
            periodStart.day,
          );
          end = DateTime(periodEnd.year, periodEnd.month, periodEnd.day);
          if (start.isAfter(txnMin)) start = txnMin;
          if (end.isBefore(txnMax)) end = txnMax;
        }
      }
    }

    final locale = Get.locale?.languageCode ?? 'tr';

    final spots = <FlSpot>[];
    final labels = <String>[];
    final amounts = <double>[];

    var day = start;
    var index = 0;
    while (!day.isAfter(end)) {
      final amount = daily[day] ?? 0;
      spots.add(FlSpot(index.toDouble(), amount));
      labels.add(AppDateFormats.dayMonth(day, languageCode: locale));
      amounts.add(amount);
      day = day.add(const Duration(days: 1));
      index++;
    }

    return _TrendChartData(
      spots: spots,
      labels: labels,
      amounts: amounts,
    );
  }

  static DateTime? _parseDate(String raw) {
    final normalized = _normalizeDate(raw);
    if (normalized == null) return null;
    return DateTime.tryParse(normalized);
  }

  static String? _normalizeDate(String raw) {
    if (raw.isEmpty) return null;
    final dotMatch = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(raw);
    if (dotMatch != null) {
      return '${dotMatch.group(3)}-${dotMatch.group(2)}-${dotMatch.group(1)}';
    }
    final slashMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(raw);
    if (slashMatch != null) {
      return '${slashMatch.group(3)}-${slashMatch.group(2)}-${slashMatch.group(1)}';
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw)) {
      return raw.substring(0, 10);
    }
    return null;
  }
}

class _LimitBar extends StatelessWidget {
  const _LimitBar({
    required this.cardLimit,
    required this.availableLimit,
    required this.money,
  });

  final double cardLimit;
  final double availableLimit;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final used = cardLimit - availableLimit;
    final pct = (used / cardLimit).clamp(0.0, 1.0);
    final barColor = pct > 0.85
        ? AppColors.negative
        : pct > 0.60
            ? AppColors.neutral
            : AppColors.positive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'home_doc_limit_label'.tr,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              money.format(cardLimit),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${'home_doc_limit_used'.tr}: ${money.format(used)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${'home_doc_limit_available'.tr}: ${money.format(availableLimit)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthComparison extends StatelessWidget {
  const _MonthComparison({
    required this.currentExpense,
    required this.previousExpense,
    required this.money,
  });

  final double currentExpense;
  final double previousExpense;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final diff = currentExpense - previousExpense;
    final pct = previousExpense > 0
        ? ((diff / previousExpense) * 100).abs().round()
        : 0;
    final isMore = diff > 0;
    final color = isMore ? AppColors.negative : AppColors.positive;
    final icon =
        isMore ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final label = isMore
        ? 'home_doc_comparison_more'.trParams({'pct': pct.toString()})
        : 'home_doc_comparison_less'.trParams({'pct': pct.toString()});

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppConstants.paddingXs),
          Expanded(
            child: Text(
              '${'home_doc_vs_last_month'.tr}: $label · ${money.format(previousExpense)}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartData {
  const _TrendChartData({
    required this.spots,
    required this.labels,
    required this.amounts,
  });

  final List<FlSpot> spots;
  final List<String> labels;
  final List<double> amounts;

  bool get hasSpending => amounts.any((a) => a > 0);
}

class _SpendingTrendLineChart extends StatelessWidget {
  const _SpendingTrendLineChart({
    required this.data,
    required this.money,
    required this.periodLabel,
  });

  final _TrendChartData data;
  final NumberFormat money;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final spots = data.spots;
    final labels = data.labels;
    final pointCount = spots.length;
    final maxAmount = spots.map((s) => s.y).reduce(math.max);
    final maxY = maxAmount > 0 ? (maxAmount * 1.2).toDouble() : 100.0;
    final labelStep = pointCount <= 7 ? 1 : (pointCount / 6).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'home_spending_trend_title'.tr,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSm),
            Flexible(
              child: Text(
                periodLabel.isNotEmpty
                    ? periodLabel
                    : 'home_spending_trend_full_period'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSm),
        SizedBox(
          height: 110,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: math.max(0, pointCount - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              gridData: const FlGridData(show: false),
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
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      final isLast = i == labels.length - 1;
                      if (i % labelStep != 0 && !isLast) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          labels[i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.onPrimary,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primary,
                  tooltipRoundedRadius: AppConstants.radiusSm,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final i = spot.spotIndex;
                      if (i < 0 || i >= data.amounts.length) return null;
                      return LineTooltipItem(
                        money.format(data.amounts[i]),
                        const TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.4,
                  preventCurveOverShooting: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.22),
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Text(
            'home_documents_empty'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text('home_doc_btn_upload'.tr),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
