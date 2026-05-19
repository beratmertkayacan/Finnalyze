import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../models/transaction_model.dart';
import '../controllers/document_detail_controller.dart';
import '../widgets/ai_summary_card_widget.dart';
import '../widgets/category_chart_widget.dart';
import '../widgets/detail_header_card.dart';
import '../widgets/document_detail_format.dart';
import '../widgets/detail_ai_recommendations_tab.dart';
import '../widgets/detail_installments_tab.dart';
import '../widgets/insight_cards_widget.dart';
class DocumentDetailView extends GetView<DocumentDetailController> {
  const DocumentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError.value) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.onSurface,
            elevation: 0,
            leading: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingXl),
              child: Text(
                controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : 'doc_detail_not_found'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        );
      }

      return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            _headerTitle(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXs,
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            dividerHeight: 0,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              letterSpacing: 0.1,
            ),
            tabs: [
              Tab(text: 'doc_tab_ai'.tr),
              Tab(text: 'doc_tab_analysis'.tr),
              Tab(text: 'doc_tab_summary'.tr),
              Tab(text: 'doc_tab_installments'.tr),
              Tab(text: 'doc_tab_transactions'.tr),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AiTab(),
            _AnalysisTab(),
            _SummaryTab(),
            DetailInstallmentsTab(),
            _TransactionsTab(),
          ],
        ),
      ),
    );
    });
  }

  String _headerTitle() {
    final stored = controller.storedDocument;
    if (stored != null && stored.smartTitle.isNotEmpty) {
      return stored.smartTitle;
    }
    final model = controller.model;
    final label = model.cardLabel.isNotEmpty
        ? model.cardLabel
        : model.bankName.isNotEmpty
            ? model.bankName
            : '';
    if (label.isNotEmpty && model.period.isNotEmpty) {
      return label;
    }
    return model.documentTitle.isNotEmpty
        ? model.documentTitle
        : 'doc_detail_untitled'.tr;
  }
}

class _TransactionsTab extends GetView<DocumentDetailController> {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingSm,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'doc_detail_transactions_by_category'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSm),
          const _GroupedTransactionsList(),
        ],
      ),
    );
  }
}

class _GroupedTransactionsList extends GetView<DocumentDetailController> {
  const _GroupedTransactionsList();

  @override
  Widget build(BuildContext context) {
  return Obx(() {
      final selected = controller.selectedCategory.value;
      final grouped = controller.groupedExpenses;
      final keys = selected == DocumentDetailController.allCategoriesKey
          ? grouped.keys.toList()
          : grouped.keys
              .where((k) => k == selected)
              .toList();

      if (keys.isEmpty) {
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryFilterChips(),
          const SizedBox(height: AppConstants.paddingMd),
          for (var i = 0; i < keys.length; i++) ...[
            _CategoryGroupSection(categoryKey: keys[i]),
            if (i < keys.length - 1)
              const SizedBox(height: AppConstants.paddingMd),
          ],
        ],
      );
    });
  }
}

class _CategoryFilterChips extends GetView<DocumentDetailController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = controller.categories;
      return Wrap(
        spacing: AppConstants.paddingXs,
        runSpacing: AppConstants.paddingXs,
        children: categories.map((category) {
          final isSelected = controller.selectedCategory.value == category;
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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
    });
  }

  String _chipLabel(String category) {
    if (category == DocumentDetailController.allCategoriesKey) {
      return 'doc_detail_category_all'.tr;
    }
    return controller.categoryDisplayName(category);
  }
}

class _CategoryGroupSection extends GetView<DocumentDetailController> {
  const _CategoryGroupSection({required this.categoryKey});

  final String categoryKey;

  @override
  Widget build(BuildContext context) {
    final transactions = controller.groupedExpenses[categoryKey] ?? [];
    final emoji = controller.categoryEmojiFor(categoryKey);
    final name = controller.categoryDisplayName(categoryKey);
    final total = controller.categoryTotal(categoryKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingXs,
            bottom: AppConstants.paddingXs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$emoji $name',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              Text(
                DocumentDetailFormat.money(total),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.negative,
                    ),
              ),
            ],
          ),
        ),
        Container(
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
                _DetailTransactionRow(transaction: transactions[i]),
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
        ),
      ],
    );
  }
}

class _DetailTransactionRow extends StatelessWidget {
  const _DetailTransactionRow({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? AppColors.positive : AppColors.negative;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final prefix = isIncome ? '+' : '-';
    final amountText =
        '$prefix${DocumentDetailFormat.money(transaction.amount)}';

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
                if (transaction.date.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingXs / 2),
                  Text(
                    transaction.date,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
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

class _IncompleteAnalysisBanner extends GetView<DocumentDetailController> {
  const _IncompleteAnalysisBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.neutral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.neutral,
            size: AppConstants.iconSm,
          ),
          const SizedBox(width: AppConstants.paddingSm),
          Expanded(
            child: Text(
              'doc_analysis_incomplete'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisTab extends GetView<DocumentDetailController> {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingSm,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.hasIncompleteAnalysis) ...[
            const _IncompleteAnalysisBanner(),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          if (controller.hasCarryover) ...[
            const _CarryoverCard(),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          if (controller.canShowDebtCalculator) ...[
            const _DebtPayoffCard(),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          const CategoryChartWidget(),
          if (controller.installmentTransactions.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMd),
            const _InstallmentSummaryCard(),
          ],
        ],
      ),
    );
  }
}

class _CarryoverCard extends GetView<DocumentDetailController> {
  const _CarryoverCard();

  @override
  Widget build(BuildContext context) {
    final carry = controller.model.previousPeriodBalance;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.onPrimary,
            size: AppConstants.iconMd,
          ),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'doc_carryover_label'.tr,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.7),
                      ),
                ),
                Text(
                  DocumentDetailFormat.money(carry.abs()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'doc_net_debt_label'.tr,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                DocumentDetailFormat.money(controller.netDebt),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstallmentSummaryCard extends GetView<DocumentDetailController> {
  const _InstallmentSummaryCard();

  @override
  Widget build(BuildContext context) {
    final installments = controller.installmentTransactions;

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
            '📅 ${'doc_installments_title'.tr}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          ...installments.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.description.isNotEmpty ? t.description : '—',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingXs,
                      vertical: AppConstants.paddingXs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      t.installmentLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSm),
                  Text(
                    DocumentDetailFormat.money(t.amount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.negative,
                          fontWeight: FontWeight.w700,
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

class _SummaryTab extends GetView<DocumentDetailController> {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingSm,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DetailHeaderCard(),
          if (controller.hasIncompleteAnalysis) ...[
            const SizedBox(height: AppConstants.paddingSm),
            const _IncompleteAnalysisBanner(),
          ],
          const SizedBox(height: AppConstants.paddingMd),
          if (controller.hasFutureDates) ...[
            const _FuturePeriodCard(),
            const SizedBox(height: AppConstants.paddingMd),
          ],
          const InsightCardsWidget(),
        ],
      ),
    );
  }
}

class _AiTab extends GetView<DocumentDetailController> {
  const _AiTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingXxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AiSummaryCardWidget(),
          const SizedBox(height: AppConstants.paddingLg),
          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppConstants.paddingLg),
          const DetailAiRecommendationsTab(),
        ],
      ),
    );
  }
}

class _FuturePeriodCard extends GetView<DocumentDetailController> {
  const _FuturePeriodCard();

  @override
  Widget build(BuildContext context) {
    final model = controller.model;

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
            '📅 ${'doc_future_period_title'.tr}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          if (model.nextStatementDate.isNotEmpty)
            _FuturePeriodRow(
              label: 'doc_next_statement'.tr,
              value: model.nextStatementDate,
            ),
          if (model.nextStatementDate.isNotEmpty &&
              model.nextPaymentDueDate.isNotEmpty)
            const SizedBox(height: AppConstants.paddingSm),
          if (model.nextPaymentDueDate.isNotEmpty)
            _FuturePeriodRow(
              label: 'doc_next_payment_due'.tr,
              value: model.nextPaymentDueDate,
            ),
        ],
      ),
    );
  }
}

class _FuturePeriodRow extends StatelessWidget {
  const _FuturePeriodRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ── Borç Hesaplayıcı ─────────────────────────────────────────────────────────

class _DebtPayoffCard extends GetView<DocumentDetailController> {
  const _DebtPayoffCard();

  @override
  Widget build(BuildContext context) {
    final debt = controller.model.displayDebt;
    final minPay = controller.model.minimumPayment;
    final months = controller.debtPayoffMonths;
    final totalInterest = controller.totalInterestIfMinimum;
    final totalPaid = controller.totalPaidIfMinimum;

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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.negative.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.negative,
                  size: AppConstants.iconSm,
                ),
              ),
              const SizedBox(width: AppConstants.paddingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'doc_debt_calc_title'.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMd),

          // Current debt + minimum payment row
          Row(
            children: [
              Expanded(
                child: _DebtStatChip(
                  label: 'doc_debt_calc_current_debt'.tr,
                  value: DocumentDetailFormat.money(debt),
                  valueColor: AppColors.negative,
                ),
              ),
              const SizedBox(width: AppConstants.paddingSm),
              Expanded(
                child: _DebtStatChip(
                  label: 'doc_debt_calc_min_payment'.tr,
                  value: DocumentDetailFormat.money(minPay),
                  valueColor: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMd),

          Divider(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppConstants.paddingMd),

          // Scenario 1 — minimum payment
          _DebtScenarioRow(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.negative,
            label: 'doc_debt_calc_min_scenario'
                .trParams({'months': months.toString()}),
            detail: 'doc_debt_calc_min_detail'.trParams({
              'total': DocumentDetailFormat.money(totalPaid),
              'interest': DocumentDetailFormat.money(totalInterest),
            }),
          ),
          const SizedBox(height: AppConstants.paddingMd),

          // Scenario 2 — pay full now
          _DebtScenarioRow(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.positive,
            label: 'doc_debt_calc_full_scenario'.tr,
            detail: 'doc_debt_calc_full_detail'.trParams({
              'savings': DocumentDetailFormat.money(totalInterest),
            }),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _DebtStatChip extends StatelessWidget {
  const _DebtStatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _DebtScenarioRow extends StatelessWidget {
  const _DebtScenarioRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.detail,
    this.highlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String detail;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSm),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.positive.withValues(alpha: 0.07)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: highlight
            ? Border.all(color: AppColors.positive.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: AppConstants.iconSm),
          const SizedBox(width: AppConstants.paddingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: highlight
                            ? AppColors.positive
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            highlight ? FontWeight.w600 : FontWeight.w400,
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
