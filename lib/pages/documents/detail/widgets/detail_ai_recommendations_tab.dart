import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../../../core/utils/ai_notes_parser.dart';
import '../../../../global_widgets/shimmer_box.dart';
import '../controllers/document_detail_controller.dart';
import 'ai_section_label.dart';

class DetailAiRecommendationsTab extends GetView<DocumentDetailController> {
  const DetailAiRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.aiRecommendationsStatus.value) {
        case 'loading':
          return const _LoadingBody();
        case 'done':
          return _DoneBody(text: controller.aiRecommendationsText.value);
        case 'error':
          return _ErrorBody(onRetry: controller.loadAiRecommendations);
        default:
          return const _LoadingBody();
      }
    });
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiSectionLabel(labelKey: 'doc_ai_section_recommendations'),
        const SizedBox(height: AppConstants.paddingSm),
        Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.paddingXs),
            Text(
              'doc_detail_ai_rec_loading'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMd),
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: AppConstants.paddingSm),
          const ShimmerBox(
            width: double.infinity,
            height: 72,
            borderRadius: AppConstants.radiusMd,
          ),
        ],
      ],
    );
  }
}

class _DoneBody extends StatelessWidget {
  const _DoneBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final items = AiNotesParser.parse(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiSectionLabel(labelKey: 'doc_ai_section_recommendations'),
        const SizedBox(height: AppConstants.paddingSm),
        if (items.isEmpty)
          Text(
            text.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.65,
                ),
          )
        else
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppConstants.paddingSm),
            _RecommendationCard(index: i + 1, text: items[i]),
          ],
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiSectionLabel(labelKey: 'doc_ai_section_recommendations'),
        const SizedBox(height: AppConstants.paddingMd),
        Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppColors.negative,
            ),
            const SizedBox(width: AppConstants.paddingXs),
            Expanded(
              child: Text(
                'doc_detail_ai_rec_error'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('doc_detail_ai_rec_retry'.tr),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}
