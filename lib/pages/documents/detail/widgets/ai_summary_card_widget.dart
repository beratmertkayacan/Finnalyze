import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../../../core/utils/ai_notes_parser.dart';
import '../../models/document_analysis_model.dart';
import '../controllers/document_detail_controller.dart';
import 'ai_section_label.dart';
import 'document_detail_format.dart';

class AiSummaryCardWidget extends GetView<DocumentDetailController> {
  const AiSummaryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final dateItems = _dateItems(model);
    final metrics = _metricItems(model, controller);
    final highlights = _highlightNotes(model);

    if (dateItems.isEmpty && metrics.isEmpty && highlights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiSectionLabel(labelKey: 'doc_ai_section_summary'),
        const SizedBox(height: AppConstants.paddingSm),
        if (dateItems.isNotEmpty) ...[
          _DatesCard(items: dateItems),
          const SizedBox(height: AppConstants.paddingSm),
        ],
        if (metrics.isNotEmpty) ...[
          _MetricsGrid(metrics: metrics),
          const SizedBox(height: AppConstants.paddingSm),
        ],
        if (highlights.isNotEmpty) _HighlightCards(notes: highlights),
      ],
    );
  }

  static List<_DateItem> _dateItems(DocumentAnalysisModel model) {
    final items = <_DateItem>[];
    if (model.period.isNotEmpty) {
      items.add(
        _DateItem(
          icon: Icons.date_range_rounded,
          label: 'doc_ai_summary_period'.tr,
          value: model.period,
          emphasized: true,
        ),
      );
    }
    if (model.paymentDueDate.isNotEmpty) {
      items.add(
        _DateItem(
          icon: Icons.event_busy_rounded,
          label: 'doc_detail_payment_due'.tr,
          value: model.paymentDueDate,
        ),
      );
    }
    if (model.lastPaymentDate.isNotEmpty) {
      items.add(
        _DateItem(
          icon: Icons.payments_outlined,
          label: 'doc_ai_summary_last_payment'.tr,
          value: model.lastPaymentDate,
        ),
      );
    }
    if (model.nextStatementDate.isNotEmpty) {
      items.add(
        _DateItem(
          icon: Icons.calendar_month_outlined,
          label: 'doc_next_statement'.tr,
          value: model.nextStatementDate,
        ),
      );
    }
    if (model.nextPaymentDueDate.isNotEmpty) {
      items.add(
        _DateItem(
          icon: Icons.schedule_rounded,
          label: 'doc_ai_summary_next_payment'.tr,
          value: model.nextPaymentDueDate,
        ),
      );
    }
    return items;
  }

  static List<_MetricItem> _metricItems(
    DocumentAnalysisModel model,
    DocumentDetailController controller,
  ) {
    final items = <_MetricItem>[];

    if (model.isCreditCard) {
      if (model.cardLimit > 0) {
        items.add(
          _MetricItem(
            'home_credit_card_limit'.tr,
            DocumentDetailFormat.money(model.cardLimit),
            AppColors.primary,
            Icons.credit_card_rounded,
          ),
        );
      }
      if (model.availableLimit > 0 || model.cardLimit > 0) {
        items.add(
          _MetricItem(
            'home_credit_available_limit'.tr,
            DocumentDetailFormat.money(model.availableLimit),
            AppColors.positive,
            Icons.account_balance_wallet_outlined,
          ),
        );
      }
      final usedLimit = model.cardLimit > 0 && model.availableLimit >= 0
          ? model.cardLimit - model.availableLimit
          : 0.0;
      if (usedLimit > 0) {
        items.add(
          _MetricItem(
            'home_doc_limit_used'.tr,
            DocumentDetailFormat.money(usedLimit),
            AppColors.negative,
            Icons.trending_up_rounded,
          ),
        );
      }
      if (model.totalExpense > 0) {
        items.add(
          _MetricItem(
            'doc_detail_gross_expense'.tr,
            DocumentDetailFormat.money(model.totalExpense),
            AppColors.negative,
            Icons.shopping_bag_outlined,
          ),
        );
      }
      if (model.displayDebt > 0) {
        items.add(
          _MetricItem(
            'home_credit_current_debt'.tr,
            DocumentDetailFormat.money(model.displayDebt),
            AppColors.primary,
            Icons.receipt_long_rounded,
          ),
        );
      }
      if (model.minimumPayment > 0) {
        items.add(
          _MetricItem(
            'doc_detail_min_payment'.tr,
            DocumentDetailFormat.money(model.minimumPayment),
            AppColors.neutral,
            Icons.savings_outlined,
          ),
        );
      }
    } else {
      if (controller.totalIncome > 0) {
        items.add(
          _MetricItem(
            'doc_detail_total_income'.tr,
            DocumentDetailFormat.money(controller.totalIncome),
            AppColors.positive,
            Icons.arrow_downward_rounded,
          ),
        );
      }
      if (controller.totalExpense > 0) {
        items.add(
          _MetricItem(
            'doc_detail_total_expense'.tr,
            DocumentDetailFormat.money(controller.totalExpense),
            AppColors.negative,
            Icons.arrow_upward_rounded,
          ),
        );
      }
      if (controller.closingBalance != 0) {
        items.add(
          _MetricItem(
            'doc_detail_closing'.tr,
            DocumentDetailFormat.money(controller.closingBalance),
            AppColors.primary,
            Icons.account_balance_rounded,
          ),
        );
      }
    }

    if (model.transactions.isNotEmpty) {
      items.add(
        _MetricItem(
          'doc_detail_total_transactions'.tr,
          '${model.transactions.length}',
          AppColors.onSurfaceVariant,
          Icons.receipt_outlined,
        ),
      );
    }

    return items;
  }

  static List<String> _highlightNotes(DocumentAnalysisModel model) {
    final parsed = AiNotesParser.parse(model.summary);
    if (parsed.isEmpty) return const [];

    final notes = <String>[];
    for (final note in parsed) {
      final trimmed = note.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.length > 140) {
        final parts = trimmed.split(RegExp(r'(?<=[.!?])\s+'));
        for (final part in parts) {
          final p = part.trim();
          if (p.length > 12) notes.add(p);
          if (notes.length >= 3) break;
        }
      } else {
        notes.add(trimmed);
      }
      if (notes.length >= 3) break;
    }
    return notes;
  }
}

class _DateItem {
  const _DateItem({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;
}

class _MetricItem {
  const _MetricItem(this.label, this.value, this.color, this.icon);

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

class _DatesCard extends StatelessWidget {
  const _DatesCard({required this.items});

  final List<_DateItem> items;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingXs,
                ),
                child: Divider(
                  height: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            _DateRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.item});

  final _DateItem item;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: item.emphasized ? FontWeight.w800 : FontWeight.w600,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppConstants.paddingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: labelStyle),
              const SizedBox(height: 2),
              Text(item.value, style: valueStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final List<_MetricItem> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 360 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppConstants.paddingSm,
            crossAxisSpacing: AppConstants.paddingSm,
            childAspectRatio: crossAxisCount == 2 ? 2.35 : 3.2,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) =>
              _MetricMiniCard(metric: metrics[index]),
        );
      },
    );
  }
}

class _MetricMiniCard extends StatelessWidget {
  const _MetricMiniCard({required this.metric});

  final _MetricItem metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(metric.icon, size: 18, color: metric.color),
          const SizedBox(width: AppConstants.paddingXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: metric.color,
                        fontWeight: FontWeight.w800,
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

class _HighlightCards extends StatelessWidget {
  const _HighlightCards({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'doc_ai_summary_highlights'.tr,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        for (var i = 0; i < notes.length; i++) ...[
          if (i > 0) const SizedBox(height: AppConstants.paddingXs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingSm),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.paddingXs),
                Expanded(
                  child: Text(
                    notes[i],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
