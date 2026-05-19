import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/utils/document_name_edit_helper.dart';
import '../../../../core/constants.dart';
import '../../../../core/utils/document_delete_helper.dart';
import '../controllers/document_upload_controller.dart';
import '../models/upload_recent_item_model.dart';

class UploadRecentScannedSection extends GetView<DocumentUploadController> {
  const UploadRecentScannedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMd,
        AppConstants.paddingLg,
        AppConstants.paddingMd,
        AppConstants.paddingXxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'upload_recent_scanned'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Obx(() {
                if (!controller.canExpandHistory) {
                  return const SizedBox.shrink();
                }
                return TextButton(
                  onPressed: controller.toggleShowAllHistory,
                  child: Text(
                    controller.showAllHistory.value
                        ? 'upload_view_less'.tr
                        : 'upload_view_all'.tr,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Obx(
            () {
              final docs = controller.visibleDocuments;
              if (docs.isEmpty) {
                return Text(
                  'upload_history_empty'.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                );
              }

              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  children: docs
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key < docs.length - 1
                                ? AppConstants.paddingMd
                                : 0,
                          ),
                          child: _RecentScanCard(
                            item: entry.value,
                            onPreview: () =>
                                controller.openPdfPreview(entry.value),
                            onOpenAnalysis: () =>
                                controller.openStoredDocumentDetail(
                              entry.value,
                            ),
                            onDelete:
                                entry.value.status != UploadScanStatus.analyzing
                                    ? () => DocumentDeleteHelper.confirmAndDelete(
                                          documentId: entry.value.id,
                                          documentTitle: entry.value.title,
                                        )
                                    : null,
                            onEdit: entry.value.status ==
                                    UploadScanStatus.complete
                                ? () => DocumentNameEditHelper.showEditSheet(
                                      documentId: entry.value.id,
                                    )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}

class _RecentScanCard extends StatelessWidget {
  const _RecentScanCard({
    required this.item,
    required this.onPreview,
    required this.onOpenAnalysis,
    this.onDelete,
    this.onEdit,
  });

  final UploadRecentItemModel item;
  final VoidCallback onPreview;
  final VoidCallback onOpenAnalysis;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isComplete = item.status == UploadScanStatus.complete;
    final isAnalyzing = item.status == UploadScanStatus.analyzing;
    final isError = item.status == UploadScanStatus.error;

    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: InkWell(
                onTap: isComplete ? onPreview : null,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    item.icon,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMd),
            Expanded(
              child: InkWell(
                onTap: isComplete ? onOpenAnalysis : null,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingXs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingXs),
                      Text(
                        isAnalyzing
                            ? 'upload_status_analyzing'.tr
                            : isError
                                ? 'upload_status_error'.tr
                                : item.meta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isError
                                  ? AppColors.negative
                                  : isAnalyzing
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                              fontWeight: isAnalyzing || isError
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isAnalyzing)
              const Padding(
                padding: EdgeInsets.only(left: AppConstants.paddingSm),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            else ...[
              if (isComplete && onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  tooltip: 'doc_edit_title'.tr,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.negative,
                  ),
                  tooltip: 'doc_delete_title'.tr,
                ),
              if (isComplete)
                IconButton(
                  onPressed: onOpenAnalysis,
                  icon: const Icon(
                    Icons.insights_outlined,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
