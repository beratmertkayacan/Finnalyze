import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

class UploadSourceSheet extends StatelessWidget {
  const UploadSourceSheet({
    super.key,
    required this.titleKey,
    this.showBrowse = true,
    this.onBrowse,
    required this.onCamera,
    required this.onGallery,
  });

  final String titleKey;
  final bool showBrowse;
  final VoidCallback? onBrowse;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingLg,
          AppConstants.paddingMd,
          AppConstants.paddingLg,
          AppConstants.paddingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Text(
              titleKey.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            if (showBrowse && onBrowse != null)
              _SheetOption(
                icon: Icons.folder_open_rounded,
                label: 'upload_source_browse'.tr,
                onTap: onBrowse!,
              ),
            if (showBrowse) const SizedBox(height: AppConstants.paddingSm),
            _SheetOption(
              icon: Icons.photo_camera_outlined,
              label: 'upload_source_scan_camera'.tr,
              onTap: onCamera,
            ),
            const SizedBox(height: AppConstants.paddingSm),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'upload_source_scan_gallery'.tr,
              onTap: onGallery,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
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
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMd,
            vertical: AppConstants.paddingMd,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppConstants.paddingMd),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
