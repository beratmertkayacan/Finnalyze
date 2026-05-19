import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../pages/documents/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    this.currency = 'TRY',
  });

  final TransactionModel transaction;
  final String currency;

  bool get _isIncome => transaction.type == 'income';

  @override
  Widget build(BuildContext context) {
    final amountColor = _isIncome ? AppColors.positive : AppColors.negative;
    final prefix = _isIncome ? '+' : '-';
    final amountText =
        '$prefix${_formatAmount(transaction.amount, currency)}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.date.isNotEmpty)
                  Text(
                    transaction.date,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                if (transaction.date.isNotEmpty)
                  const SizedBox(height: AppConstants.paddingXs),
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : '—',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingSm),
          Text(
            amountText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String currencyCode) {
    final symbol = currencyCode == 'TRY' ? '₺' : currencyCode;
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
