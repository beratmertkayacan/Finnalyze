import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_upload_controller.dart';

/// Always shows the upload prompt; completed picks appear in [UploadRecentScannedSection].
class UploadDropZoneWidget extends GetView<DocumentUploadController> {
  const UploadDropZoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMd),
      child: Obx(() {
        final isBusy = controller.isAnalyzing.value;

        return Material(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            side: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppConstants.uploadDropZoneMinHeight,
            ),
            padding: const EdgeInsets.all(AppConstants.paddingLg),
            child: _EmptyDropBody(isBusy: isBusy),
          ),
        );
      }),
    );
  }
}

class _EmptyDropBody extends StatelessWidget {
  const _EmptyDropBody({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final uploadController = Get.find<DocumentUploadController>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_upload_rounded,
            color: AppColors.onPrimary,
            size: AppConstants.iconMd,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMd),
        Text(
          'upload_drop_analysis_hint'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
        ),
        const SizedBox(height: AppConstants.paddingXs),
        Text(
          'upload_drop_subtitle'.trParams({
            'max': AppConstants.uploadMaxFileSizeMb.toString(),
          }),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingLg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : uploadController.onScanTap,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text('upload_scan'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize:
                      const Size.fromHeight(AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusXl),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMd),
            Expanded(
              child: FilledButton.icon(
                onPressed: isBusy ? null : uploadController.onBrowseTap,
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: Text('upload_browse'.tr),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize:
                      const Size.fromHeight(AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusXl),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
