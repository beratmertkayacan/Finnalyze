import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import 'transaction_list_widget.dart';

class DetailTransactionsTab extends StatelessWidget {
  const DetailTransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        0,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: TransactionListWidget(showTitle: false),
    );
  }
}
