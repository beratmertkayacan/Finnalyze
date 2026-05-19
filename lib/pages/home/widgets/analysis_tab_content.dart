import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/utils/document_delete_helper.dart';
import '../../../core/utils/document_name_edit_helper.dart';
import '../../../global_widgets/stored_document_card.dart';
import '../../../routes/routes.dart';
import '../../../services/document_storage_service.dart';
import '../../documents/models/document_detail_args.dart';
import '../../documents/models/stored_document_model.dart';
import '../../documents/upload/controllers/document_upload_controller.dart';
import '../../documents/upload/models/upload_recent_item_model.dart';
import '../../documents/upload/utils/recent_document_display.dart';
import '../controllers/home_controller.dart';

class AnalysisTabContent extends StatelessWidget {
  const AnalysisTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final uploadController = Get.find<DocumentUploadController>();
    final storage = Get.find<DocumentStorageService>();

    return SafeArea(
      child: Obx(() {
        final entries = _buildEntries(uploadController, storage);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'nav_analysis'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingXs),
              Text(
                'analysis_select_document'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingLg),
              if (entries.isEmpty)
                _EmptyPickerCard()
              else
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingSm,
                    ),
                    child: _AnalysisEntryTile(
                      entry: entry,
                      progress: uploadController.analysisProgress.value,
                      isParsing: uploadController.isParsing.value,
                      onOpenActions: entry.stored != null
                          ? () => _showDocumentActionSheet(
                                context,
                                homeController,
                                entry.stored!,
                              )
                          : null,
                      onEdit: entry.stored != null
                          ? () => DocumentNameEditHelper.showEditSheet(
                                documentId: entry.id,
                              )
                          : null,
                      onDelete: entry.stored != null
                          ? () => DocumentDeleteHelper.confirmAndDelete(
                                documentId: entry.id,
                                documentTitle: entry.stored!.smartTitle,
                              )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  List<_AnalysisListEntry> _buildEntries(
    DocumentUploadController upload,
    DocumentStorageService storage,
  ) {
    // Touch observables so Obx rebuilds on list / progress changes.
    upload.isAnalyzing.value;
    upload.analysisProgress.value;
    final storageDocs = storage.documents.toList();
    final uploadDocs = upload.allDocuments.toList();

    final seen = <String>{};
    final entries = <_AnalysisListEntry>[];

    for (final item in uploadDocs) {
      seen.add(item.id);
      entries.add(
        _AnalysisListEntry(
          id: item.id,
          pending: item,
          stored: storage.findById(item.id),
        ),
      );
    }

    for (final doc in storageDocs) {
      if (seen.contains(doc.id)) continue;
      entries.add(
        _AnalysisListEntry(
          id: doc.id,
          stored: doc,
          pending: UploadRecentItemModel(
            id: doc.id,
            title: RecentDocumentDisplay.headlineForStored(doc),
            meta: RecentDocumentDisplay.fileNameSubtitle(doc),
            status: UploadScanStatus.complete,
            icon: doc.analysis.isCreditCard
                ? Icons.credit_card_outlined
                : Icons.picture_as_pdf_outlined,
            localPath: doc.localPath,
          ),
        ),
      );
    }

    entries.sort((a, b) {
      final statusA = a.pending?.status ?? UploadScanStatus.complete;
      final statusB = b.pending?.status ?? UploadScanStatus.complete;
      return DocumentUploadController.compareByStatus(
        UploadRecentItemModel(
          id: a.id,
          title: '',
          meta: '',
          status: statusA,
        ),
        UploadRecentItemModel(
          id: b.id,
          title: '',
          meta: '',
          status: statusB,
        ),
      );
    });

    return entries;
  }

  static void _showDocumentActionSheet(
    BuildContext context,
    HomeController homeController,
    StoredDocumentModel document,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMd,
          AppConstants.paddingSm,
          AppConstants.paddingMd,
          AppConstants.paddingLg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLg),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: AppConstants.paddingXl,
                  height: AppConstants.paddingXs / 2,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              Text(
                'analysis_action_title'.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingXs),
              Text(
                document.smartTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingMd),
              ListTile(
                leading: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  'analysis_open_ai'.tr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                tileColor: AppColors.surfaceContainerLow,
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.documentDetail,
                    arguments: DocumentDetailArgs(documentId: document.id),
                  );
                },
              ),
              const SizedBox(height: AppConstants.paddingXs),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'analysis_open_pdf'.tr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                tileColor: AppColors.surfaceContainerLow,
                onTap: () {
                  Get.back();
                  homeController.openPdfPreview(document.id);
                },
              ),
              if (!document.analysis.hasUsableAnalysis) ...[
                const SizedBox(height: AppConstants.paddingXs),
                ListTile(
                  leading: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.neutral,
                  ),
                  title: Text(
                    'doc_reanalyze_action'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    'doc_analysis_incomplete'.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  tileColor: AppColors.surfaceContainerLow,
                  onTap: () {
                    Get.back();
                    homeController.reanalyzeDocument(document.id);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _AnalysisListEntry {
  const _AnalysisListEntry({
    required this.id,
    this.pending,
    this.stored,
  });

  final String id;
  final UploadRecentItemModel? pending;
  final StoredDocumentModel? stored;
}

class _AnalysisEntryTile extends StatelessWidget {
  const _AnalysisEntryTile({
    required this.entry,
    required this.progress,
    required this.isParsing,
    this.onOpenActions,
    this.onEdit,
    this.onDelete,
  });

  final _AnalysisListEntry entry;
  final double progress;
  final bool isParsing;
  final VoidCallback? onOpenActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = entry.pending?.status;
    final stored = entry.stored;

    if (status == UploadScanStatus.analyzing) {
      return _AnalyzingEntryCard(
        title: entry.pending?.title ?? '',
        meta: entry.pending?.meta ?? '',
        progress: progress,
        isParsing: isParsing,
      );
    }

    if (status == UploadScanStatus.error) {
      return _ErrorEntryCard(
        title: entry.pending?.title ?? '',
        meta: 'upload_status_error'.tr,
      );
    }

    if (stored != null) {
      return StoredDocumentCard(
        document: stored,
        onTap: onOpenActions ?? () {},
        onPreviewTap: onOpenActions,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    return const SizedBox.shrink();
  }
}

class _AnalyzingEntryCard extends StatelessWidget {
  const _AnalyzingEntryCard({
    required this.title,
    required this.meta,
    required this.progress,
    required this.isParsing,
  });

  final String title;
  final String meta;
  final double progress;
  final bool isParsing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: AppConstants.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppConstants.paddingXs),
                    Text(
                      isParsing
                          ? 'upload_status_parsing'.tr
                          : 'upload_status_analyzing'.tr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingXs),
            Text(
              meta,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress.clamp(0.0, 1.0) : null,
              minHeight: 4,
              backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorEntryCard extends StatelessWidget {
  const _ErrorEntryCard({
    required this.title,
    required this.meta,
  });

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.negative.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.negative.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.negative),
          const SizedBox(width: AppConstants.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  meta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.negative,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file_rounded,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          Text(
            'analysis_empty'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMd),
          FilledButton(
            onPressed: Get.find<HomeController>().goToDocumentUpload,
            child: Text('home_credit_cards_upload'.tr),
          ),
        ],
      ),
    );
  }
}
