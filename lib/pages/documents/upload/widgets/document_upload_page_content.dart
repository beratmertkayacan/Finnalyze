import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import 'upload_drop_zone_widget.dart';
import 'upload_recent_scanned_section.dart';

class DocumentUploadPageContent extends StatelessWidget {
  const DocumentUploadPageContent({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: !embedded,
      bottom: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (embedded)
              const _DocumentsTabHeader()
            else
              const _UploadTabHeader(),
            const UploadDropZoneWidget(),
            const UploadRecentScannedSection(),
          ],
        ),
      ),
    );
  }
}

class _DocumentsTabHeader extends StatelessWidget {
  const _DocumentsTabHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'documents_tab_title'.tr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXs),
          Text(
            'documents_tab_subtitle'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _UploadTabHeader extends StatelessWidget {
  const _UploadTabHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLg,
        AppConstants.paddingSm,
        AppConstants.paddingLg,
        0,
      ),
      child: Column(
        children: [
          Text(
            'upload_title'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXs),
          Text(
            'upload_subtitle'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
