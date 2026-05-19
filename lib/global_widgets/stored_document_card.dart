import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../pages/documents/models/stored_document_model.dart';

class StoredDocumentCard extends StatelessWidget {
  const StoredDocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onPreviewTap,
    this.onDelete,
    this.onEdit,
    this.selected = false,
  });

  final StoredDocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onPreviewTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final analysis = document.analysis;
    final icon = analysis.isCreditCard
        ? Icons.credit_card_rounded
        : Icons.picture_as_pdf_rounded;

    return Material(
      color: selected
          ? AppColors.secondaryContainer
          : AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.outlineVariant.withValues(alpha: 0.35),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Row(
            children: [
              Material(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: InkWell(
                  onTap: onPreviewTap,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(icon, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.smartTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingXs),
                    Text(
                      document.analysis.hasUsableAnalysis
                          ? document.smartPeriodLabel
                          : 'doc_analysis_incomplete'.tr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: document.analysis.hasUsableAnalysis
                                ? AppColors.onSurfaceVariant
                                : AppColors.neutral,
                            fontWeight: document.analysis.hasUsableAnalysis
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
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
              Icon(
                selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
