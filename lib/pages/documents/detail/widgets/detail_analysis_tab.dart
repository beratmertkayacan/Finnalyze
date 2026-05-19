import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import 'category_chart_widget.dart';
import 'category_expense_panel.dart';
import 'detail_recurring_payments_section.dart';
import 'insight_cards_widget.dart';

class DetailAnalysisTab extends StatelessWidget {
  const DetailAnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        0,
        AppConstants.paddingMd,
        AppConstants.paddingXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CategoryChartWidget(),
          SizedBox(height: AppConstants.paddingMd),
          CategoryExpensePanel(),
          SizedBox(height: AppConstants.paddingMd),
          InsightCardsWidget(),
          SizedBox(height: AppConstants.paddingMd),
          DetailRecurringPaymentsSection(),
        ],
      ),
    );
  }
}
