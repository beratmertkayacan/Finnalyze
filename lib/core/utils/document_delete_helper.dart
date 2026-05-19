import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/documents/upload/controllers/document_upload_controller.dart';
import '../../pages/home/controllers/home_controller.dart';
import '../../services/document_storage_service.dart';
import '../colors.dart';
import '../constants.dart';

/// Confirms and deletes a stored document across storage and controllers.
class DocumentDeleteHelper {
  DocumentDeleteHelper._();

  static Future<void> confirmAndDelete({
    required String documentId,
    required String documentTitle,
  }) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('doc_delete_title'.tr),
        content: Text(
          'doc_delete_confirm'.trParams({'title': documentTitle}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('doc_delete_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: Text('doc_delete_confirm_action'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final storage = Get.find<DocumentStorageService>();
    if (storage.findById(documentId) != null) {
      await storage.deleteDocument(documentId);
    }

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().onDocumentDeleted(documentId);
    }
    if (Get.isRegistered<DocumentUploadController>()) {
      Get.find<DocumentUploadController>().onDocumentDeleted(documentId);
    }

    Get.snackbar(
      'upload_title'.tr,
      'doc_delete_success'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppConstants.paddingMd),
    );
  }
}
