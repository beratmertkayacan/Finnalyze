import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';

class DetailHeaderCard extends GetView<DocumentDetailController> {
  const DetailHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final model = controller.model;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingSm,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.documentTitle.isNotEmpty
                    ? model.documentTitle
                    : 'doc_detail_untitled'.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
              ),
              if (model.bankName.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingXs),
                Text(
                  model.bankName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
          if (model.period.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingSm),
            Text(
              model.period,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingMd),
          if (model.isCreditCard) ...[
            Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    label: 'doc_detail_gross_expense'.tr,
                    value: DocumentDetailFormat.money(model.totalExpense),
                    color: AppColors.negative,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Expanded(
                  child: _MetricChip(
                    label: 'doc_detail_min_payment'.tr,
                    value: DocumentDetailFormat.money(model.minimumPayment),
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Expanded(
                  child: _MetricChip(
                    label: 'home_credit_current_debt'.tr,
                    value: DocumentDetailFormat.money(model.displayDebt),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (model.paymentDueDate.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSm,
                  vertical: AppConstants.paddingXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.negative.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: AppConstants.iconSm,
                      color: AppColors.negative,
                    ),
                    const SizedBox(width: AppConstants.paddingXs),
                    Text(
                      '${'doc_detail_payment_due'.tr}: ${model.paymentDueDate}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.negative,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    label: 'doc_detail_total_income'.tr,
                    value: DocumentDetailFormat.money(controller.totalIncome),
                    color: AppColors.positive,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Expanded(
                  child: _MetricChip(
                    label: 'doc_detail_total_expense'.tr,
                    value: DocumentDetailFormat.money(controller.totalExpense),
                    color: AppColors.negative,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Expanded(
                  child: _MetricChip(
                    label: 'doc_detail_closing'.tr,
                    value: DocumentDetailFormat.money(controller.closingBalance),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
