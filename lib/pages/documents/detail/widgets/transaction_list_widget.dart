import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../models/transaction_model.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';

class TransactionListWidget extends GetView<DocumentDetailController> {
  const TransactionListWidget({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text(
            'doc_detail_transactions_title'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
        ],
        Obx(() {
          final categories = controller.categories;
          return Wrap(
            spacing: AppConstants.paddingXs,
            runSpacing: AppConstants.paddingXs,
            children: categories.map((category) {
              final isSelected =
                  controller.selectedCategory.value == category;
              final label = _chipLabel(category);
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => controller.selectCategory(category),
                selectedColor: AppColors.secondaryContainer,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
                backgroundColor: AppColors.surfaceContainerLowest,
              );
            }).toList(),
          );
        }),
        const SizedBox(height: AppConstants.paddingMd),
        const _CategorySummaryBanner(),
        const SizedBox(height: AppConstants.paddingSm),
        Obx(() {
          final transactions = controller.filteredTransactions;
          if (transactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'doc_detail_transactions_empty'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  TransactionRow(
                    transaction: transactions[i],
                    categoryKey: controller.normalizedCategoryFor(
                      transactions[i],
                    ),
                  ),
                  if (i < transactions.length - 1)
                    Divider(
                      height: 1,
                      indent: AppConstants.paddingMd,
                      endIndent: AppConstants.paddingMd,
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  String _chipLabel(String category) {
    final name = controller.categoryLabel(category);
    if (category == DocumentDetailController.allCategoriesKey) {
      final total = controller.totalExpenseFromTransactions;
      if (total <= 0) return name;
      return '$name · ${DocumentDetailFormat.money(total)}';
    }
    final total = controller.categoryExpenseTotal(category);
    return '$name · ${DocumentDetailFormat.money(total)}';
  }
}

class _CategorySummaryBanner extends StatelessWidget {
  const _CategorySummaryBanner();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentDetailController>();
    return Obx(() {
      final selected = controller.selectedCategory.value;
      final isAll = selected == DocumentDetailController.allCategoriesKey;

      if (isAll && controller.expenseCategoryKeys.isEmpty) {
        return const SizedBox.shrink();
      }

      final title = controller.categoryLabel(selected);
      final expenseTotal = controller.selectedCategoryExpenseTotal;
      final txCount = controller.categoryTransactionCount(selected);

      return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                ),
                Text(
                  'doc_detail_category_summary'.trParams({
                    'count': txCount.toString(),
                    'amount': DocumentDetailFormat.money(expenseTotal),
                  }),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (!isAll)
            Text(
              '${controller.selectedCategoryPercent.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
        ],
      ),
    );
    });
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.categoryKey,
  });

  final TransactionModel transaction;
  final String categoryKey;

  bool get _isIncome => transaction.type == 'income';

  @override
  Widget build(BuildContext context) {
    final color = _isIncome ? AppColors.positive : AppColors.negative;
    final icon =
        _isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final prefix = _isIncome ? '+' : '-';
    final amountText =
        '$prefix${DocumentDetailFormat.money(transaction.amount)}';
    final categoryLabel = ExpenseCategoryUtils.label(categoryKey);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(icon, color: color, size: AppConstants.iconSm),
          ),
          const SizedBox(width: AppConstants.paddingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : '—',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingXs / 2),
                Row(
                  children: [
                    if (transaction.date.isNotEmpty)
                      Text(
                        transaction.date,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                      ),
                    if (transaction.date.isNotEmpty &&
                        transaction.type == 'expense')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingXs,
                        ),
                        child: Text(
                          '·',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    if (transaction.type == 'expense')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingXs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          categoryLabel,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (transaction.isInstallment) ...[
            const SizedBox(width: AppConstants.paddingXs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingXs,
                vertical: AppConstants.paddingXs / 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Text(
                transaction.installmentLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
          const SizedBox(width: AppConstants.paddingXs),
          Text(
            amountText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
