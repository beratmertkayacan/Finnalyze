import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_upload_controller.dart';

class UploadActionButtons extends GetView<DocumentUploadController> {
  const UploadActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        AppConstants.paddingMd,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.photo_camera_outlined,
              label: 'upload_scan'.tr,
              onTap: controller.onScanTap,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: _ActionButton(
              icon: Icons.folder_open_outlined,
              label: 'upload_browse'.tr,
              onTap: controller.onBrowseTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: SizedBox(
          height: AppConstants.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: AppConstants.iconSm),
              const SizedBox(width: AppConstants.paddingSm),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
