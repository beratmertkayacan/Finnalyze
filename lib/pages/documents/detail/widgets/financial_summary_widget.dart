import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';

class FinancialSummaryWidget extends StatelessWidget {
  const FinancialSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentDetailController>();
    final model = controller.model;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'doc_detail_financial_title'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Row(
            children: [
              Expanded(
                child: _FinancialColumn(
                  label: 'doc_detail_total_income'.tr,
                  value: DocumentDetailFormat.money(controller.totalIncome),
                  color: AppColors.positive,
                ),
              ),
              Expanded(
                child: _FinancialColumn(
                  label: 'doc_detail_total_expense'.tr,
                  value: DocumentDetailFormat.money(controller.totalExpense),
                  color: AppColors.negative,
                ),
              ),
              Expanded(
                child: _FinancialColumn(
                  label: model.isCreditCard
                      ? 'home_credit_current_debt'.tr
                      : 'doc_detail_closing'.tr,
                  value: DocumentDetailFormat.money(
                    model.isCreditCard
                        ? model.displayDebt
                        : controller.closingBalance,
                  ),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (model.period.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMd),
            Text(
              model.period,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinancialColumn extends StatelessWidget {
  const _FinancialColumn({
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
