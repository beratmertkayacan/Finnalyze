import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../global_widgets/shimmer_box.dart';
import '../../documents/models/stored_document_model.dart';
import '../controllers/home_controller.dart';

class HomeCreditCardsSection extends GetView<HomeController> {
  const HomeCreditCardsSection({super.key});

  static final _moneyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        0,
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerBox(
            width: double.infinity,
            height: AppConstants.homeMarketCardHeight,
            borderRadius: AppConstants.radiusLg,
          );
        }

        final cards = controller.creditCardStatements;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'home_credit_cards_title'.tr,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                  ),
                ),
                const Icon(
                  Icons.credit_card_rounded,
                  color: AppColors.primary,
                  size: AppConstants.iconMd,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMd),
            if (cards.isEmpty)
              _EmptyCreditCardsCard(onUpload: controller.goToDocumentUpload)
            else
              ...cards.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
                  child: _CreditCardStatementTile(
                    document: doc,
                    onTap: () => controller.onCreditCardTap(doc),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  static String formatMoney(double amount) => _moneyFormat.format(amount);
}

class _EmptyCreditCardsCard extends StatelessWidget {
  const _EmptyCreditCardsCard({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home_credit_cards_empty'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          TextButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text('home_credit_cards_upload'.tr),
          ),
        ],
      ),
    );
  }
}

class _CreditCardStatementTile extends StatelessWidget {
  const _CreditCardStatementTile({
    required this.document,
    required this.onTap,
  });

  final StoredDocumentModel document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final analysis = document.analysis;
    final subtitle = _buildSubtitle(analysis.bankName, analysis.cardLabel);

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    child: const Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.documentTitle.isNotEmpty
                              ? analysis.documentTitle
                              : document.fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.paddingXs / 2),
                          Text(
                            subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMd),
              _InfoRow(
                label: 'home_credit_current_debt'.tr,
                value: HomeCreditCardsSection.formatMoney(analysis.displayDebt),
                valueColor: AppColors.negative,
                emphasized: true,
              ),
              if (analysis.paymentDueDate.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingXs),
                _InfoRow(
                  label: 'home_credit_payment_due'.tr,
                  value: analysis.paymentDueDate,
                ),
              ],
              if (analysis.minimumPayment > 0) ...[
                const SizedBox(height: AppConstants.paddingXs),
                _InfoRow(
                  label: 'home_credit_minimum_payment'.tr,
                  value: HomeCreditCardsSection.formatMoney(
                    analysis.minimumPayment,
                  ),
                ),
              ],
              if (analysis.lastPaymentDate.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingXs),
                _InfoRow(
                  label: 'home_credit_last_payment'.tr,
                  value: analysis.lastPaymentDate,
                ),
              ],
              if (analysis.period.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingXs),
                _InfoRow(
                  label: 'home_credit_statement_period'.tr,
                  value: analysis.period,
                ),
              ],
              if (analysis.cardLimit > 0) ...[
                const SizedBox(height: AppConstants.paddingXs),
                _InfoRow(
                  label: 'home_credit_card_limit'.tr,
                  value: HomeCreditCardsSection.formatMoney(analysis.cardLimit),
                ),
              ],
              if (analysis.availableLimit > 0) ...[
                const SizedBox(height: AppConstants.paddingXs),
                _InfoRow(
                  label: 'home_credit_available_limit'.tr,
                  value:
                      HomeCreditCardsSection.formatMoney(analysis.availableLimit),
                  valueColor: AppColors.positive,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(String bankName, String cardLabel) {
    final parts = <String>[];
    if (bankName.isNotEmpty) parts.add(bankName);
    if (cardLabel.isNotEmpty) parts.add(cardLabel);
    final analysis = document.analysis;
    if (analysis.cardLastFour.isNotEmpty) {
      parts.add('•••• ${analysis.cardLastFour}');
    }
    return parts.join(' · ');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final valueStyle = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              color: valueColor ?? AppColors.onSurface,
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppColors.onSurface,
              fontWeight: FontWeight.w600,
            );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}
