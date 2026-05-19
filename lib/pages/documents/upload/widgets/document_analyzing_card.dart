import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_upload_controller.dart';
import '../models/upload_recent_item_model.dart';

class DocumentAnalyzingCard extends StatelessWidget {
  const DocumentAnalyzingCard({
    super.key,
    this.document,
    this.fullScreen = false,
  });

  final UploadRecentItemModel? document;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final uploadController = Get.find<DocumentUploadController>();

    return Obx(() {
      final progress = uploadController.analysisProgress.value;
      final isParsing = uploadController.isParsing.value;
      final fileName = document?.title ?? uploadController.selectedFileName.value ?? '';

      final card = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingXl),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DocumentScanIllustration(),
            const SizedBox(height: AppConstants.paddingLg),
            if (fileName.isNotEmpty) ...[
              Text(
                fileName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingSm),
            ],
            Text(
              'upload_analyzing_title'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingXs),
            Text(
              'upload_analyzing_subtitle'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainer,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            Row(
              children: [
                Expanded(
                  child: _StatusChip(
                    icon: Icons.check_circle_rounded,
                    label: 'upload_status_upload_done'.tr,
                    color: AppColors.positive,
                    active: true,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMd),
                Expanded(
                  child: _StatusChip(
                    icon: Icons.sync_rounded,
                    label: 'upload_status_parsing'.tr,
                    color: AppColors.primary,
                    active: isParsing,
                    showSpinner: isParsing,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (fullScreen) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card,
            const SizedBox(height: AppConstants.paddingXl),
            Text(
              'upload_powered_by'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        );
      }

      return card;
    });
  }
}

class _DocumentScanIllustration extends StatelessWidget {
  const _DocumentScanIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.uploadAnalyzingIconSize * 1.6,
      height: AppConstants.uploadAnalyzingIconSize * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: AppConstants.uploadAnalyzingIconSize * 1.4,
            height: AppConstants.uploadAnalyzingIconSize * 1.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
            ),
          ),
          Icon(
            Icons.description_outlined,
            size: AppConstants.uploadAnalyzingIconSize,
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                gradient: AppColors.aiGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    this.showSpinner = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSpinner)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color,
            ),
          )
        else
          Icon(
            icon,
            size: 16,
            color: active ? color : AppColors.onSurfaceVariant,
          ),
        const SizedBox(width: AppConstants.paddingXs),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active ? color : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
