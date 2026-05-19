import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../controllers/document_upload_controller.dart';
import '../widgets/document_analyzing_overlay.dart';
import '../widgets/document_upload_page_content.dart';

class DocumentUploadView extends GetView<DocumentUploadController> {
  const DocumentUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.isAnalyzing.value,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              onPressed: controller.onBackTap,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurface,
              ),
            ),
            title: Text(
              'app_name'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            centerTitle: true,
          ),
          body: const Stack(
            children: [
              DocumentUploadPageContent(),
              DocumentAnalyzingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
