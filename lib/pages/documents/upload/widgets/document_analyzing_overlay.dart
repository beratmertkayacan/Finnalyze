import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../controllers/document_upload_controller.dart';
import 'document_analyzing_card.dart';

/// Full-screen overlay — yalnızca bağımsız upload rotasında (home dışı) kullanılır.
class DocumentAnalyzingOverlay extends GetView<DocumentUploadController> {
  const DocumentAnalyzingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isAnalyzing.value) return const SizedBox.shrink();

      final doc = controller.activeAnalysisDocument.value;

      return PopScope(
        canPop: false,
        child: Material(
          color: AppColors.onSurface.withValues(alpha: 0.55),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMd),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppColors.onPrimary,
                      ),
                      const SizedBox(width: AppConstants.paddingSm),
                      Text(
                        'upload_analyzing_header'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLg),
                      child: DocumentAnalyzingCard(
                        document: doc,
                        fullScreen: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
