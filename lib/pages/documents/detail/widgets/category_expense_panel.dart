import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_detail_controller.dart';
import 'document_detail_format.dart';
import 'transaction_list_widget.dart';

/// Category chips + filtered expense list (used under Harcama Dağılımı).
class CategoryExpensePanel extends GetView<DocumentDetailController> {
  const CategoryExpensePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'doc_detail_category_tabs_title'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSm),
        Obx(() {
          final selected = controller.selectedCategory.value;
          final categories = controller.categories;
          return Wrap(
            spacing: AppConstants.paddingXs,
            runSpacing: AppConstants.paddingXs,
            children: categories.map((category) {
              final isSelected = selected == category;
              return FilterChip(
                label: Text(_chipLabel(category)),
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
        Obx(() {
          final selected = controller.selectedCategory.value;
          final title = controller.categoryLabel(selected);
          final total = controller.selectedCategoryExpenseTotal;
          final count = controller.categoryFilteredExpenseCount;
          final percent = controller.selectedCategoryPercent;

          return Container(
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'doc_detail_category_expense_summary'.trParams({
                      'category': title,
                      'count': count.toString(),
                      'amount': DocumentDetailFormat.money(total),
                    }),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (selected != DocumentDetailController.allCategoriesKey)
                  Text(
                    '${percent.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppConstants.paddingSm),
        Obx(() {
          final expenses = controller.categoryFilteredExpenses;
          if (expenses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingMd,
              ),
              child: Text(
                'doc_detail_category_expenses_empty'.tr,
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
                for (var i = 0; i < expenses.length; i++) ...[
                  TransactionRow(
                    transaction: expenses[i],
                    categoryKey: controller.normalizedCategoryFor(expenses[i]),
                  ),
                  if (i < expenses.length - 1)
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
    final total = controller.categoryExpenseTotal(category);
    return '$name · ${DocumentDetailFormat.money(total)}';
  }
}
