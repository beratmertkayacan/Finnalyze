import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../models/transaction_model.dart';
import '../controllers/document_detail_controller.dart';

class DetailInstallmentsTab extends GetView<DocumentDetailController> {
  const DetailInstallmentsTab({super.key});

  static final _money = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final items = controller.installmentTransactions;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 52,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              Text(
                'doc_installments_empty'.tr,
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

    final totalMonthly = items.fold<double>(0, (s, t) => s + t.amount);
    final totalRemaining = items.fold<double>(
      0,
      (s, t) => s + t.amount * (t.installmentTotal - t.installmentCurrent),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            decoration: BoxDecoration(
              gradient: AppColors.aiGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCol(
                    label: 'doc_installments_monthly'.tr,
                    value: _money.format(totalMonthly),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.onPrimary.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _SummaryCol(
                    label: 'doc_installments_remaining_total'.tr,
                    value: _money.format(totalRemaining),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.onPrimary.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _SummaryCol(
                    label: 'doc_installments_count'.tr,
                    value: '${items.length}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Text(
            'doc_installments_title'.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
              child: _InstallmentCard(transaction: t, money: _money),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  const _SummaryCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _InstallmentCard extends StatelessWidget {
  const _InstallmentCard({
    required this.transaction,
    required this.money,
  });

  final TransactionModel transaction;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final current = transaction.installmentCurrent;
    final total = transaction.installmentTotal;
    final remaining = total - current;
    final paidAmount = transaction.amount * current;
    final remainingAmount = transaction.amount * remaining;
    final progress = total > 0 ? current / total : 0.0;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : '—',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSm,
                  vertical: AppConstants.paddingXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                ),
                child: Text(
                  '$current/$total',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingXs),
          if (transaction.date.isNotEmpty)
            Text(
              transaction.date,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          const SizedBox(height: AppConstants.paddingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Row(
            children: [
              _MiniStat(
                label: 'doc_installments_this_month'.tr,
                value: money.format(transaction.amount),
                color: AppColors.negative,
              ),
              const SizedBox(width: AppConstants.paddingMd),
              _MiniStat(
                label: 'doc_installments_paid'.tr,
                value: money.format(paidAmount),
                color: AppColors.positive,
              ),
              const SizedBox(width: AppConstants.paddingMd),
              _MiniStat(
                label: 'doc_installments_left_count'.tr,
                value: '$remaining ${'doc_installments_installment'.tr}',
                color: AppColors.onSurface,
              ),
              const SizedBox(width: AppConstants.paddingMd),
              _MiniStat(
                label: 'doc_installments_remaining_amount'.tr,
                value: money.format(remainingAmount),
                color: AppColors.neutral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXs / 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
