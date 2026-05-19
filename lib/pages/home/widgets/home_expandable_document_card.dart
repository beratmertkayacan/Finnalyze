import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/utils/document_delete_helper.dart';
import '../../documents/models/stored_document_model.dart';
import '../controllers/home_controller.dart';

class HomeExpandableDocumentCard extends StatelessWidget {
  const HomeExpandableDocumentCard({
    super.key,
    required this.document,
  });

  final StoredDocumentModel document;

  static final _moneyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final analysis = document.analysis;
    final controller = Get.find<HomeController>();
    final icon = analysis.isCreditCard
        ? Icons.credit_card_rounded
        : Icons.account_balance_outlined;

    return Obx(() {
      final isExpanded = controller.expandedDocumentId.value == document.id;

      return Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: InkWell(
          onTap: () => controller.toggleDocumentExpanded(document.id),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: isExpanded
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Icon(icon, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppConstants.paddingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (analysis.period.isNotEmpty) ...[
                              const SizedBox(height: AppConstants.paddingXs),
                              Text(
                                analysis.period,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                            const SizedBox(height: AppConstants.paddingXs),
                            Text(
                              _moneyFormat.format(analysis.displayDebt),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.negative,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => DocumentDeleteHelper.confirmAndDelete(
                          documentId: document.id,
                          documentTitle: document.displayTitle,
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.negative,
                        ),
                        tooltip: 'doc_delete_title'.tr,
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                if (isExpanded) ...[
                  Divider(
                    height: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (analysis.isCreditCard) ..._creditCardDetails(),
                        Text(
                          'home_summary_preview'.tr,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppConstants.paddingXs),
                        Text(
                          analysis.summary.isNotEmpty
                              ? analysis.summary
                              : 'doc_detail_summary_empty'.tr,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurface,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: AppConstants.paddingMd),
                        FilledButton.icon(
                          onPressed: () => controller.openAnalysisForDocument(
                            document.id,
                            document.displayTitle,
                          ),
                          icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                          label: Text('home_open_analysis_tab'.tr),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSm),
                        OutlinedButton.icon(
                          onPressed: () =>
                              controller.openDocumentDetail(document),
                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                          label: Text('home_open_full_detail'.tr),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _creditCardDetails() {
    final analysis = document.analysis;
    final rows = <Widget>[];

    void addRow(String label, String value, {Color? color}) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingXs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color ?? AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (analysis.paymentDueDate.isNotEmpty) {
      addRow('home_credit_payment_due'.tr, analysis.paymentDueDate);
    }
    if (analysis.minimumPayment > 0) {
      addRow(
        'home_credit_minimum_payment'.tr,
        _moneyFormat.format(analysis.minimumPayment),
      );
    }

    if (rows.isEmpty) return const [];

    return [
      ...rows,
      const SizedBox(height: AppConstants.paddingSm),
    ];
  }
}
