import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/documents/upload/controllers/document_upload_controller.dart';
import '../../pages/documents/upload/widgets/document_name_sheet.dart';
import '../../pages/home/controllers/home_controller.dart';
import '../../services/document_storage_service.dart';

/// Opens bottom sheet to edit custom document title and period.
class DocumentNameEditHelper {
  DocumentNameEditHelper._();

  static Future<void> showEditSheet({required String documentId}) async {
    final storage = Get.find<DocumentStorageService>();
    final stored = storage.findById(documentId);
    if (stored == null) return;

    await Get.bottomSheet<void>(
      EditDocumentNameSheet(
        initialTitle: stored.smartTitle,
        initialPeriod: stored.smartPeriodLabel,
        onSave: (title, period) => _persistEdit(
          documentId: documentId,
          title: title,
          period: period,
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  static Future<void> _persistEdit({
    required String documentId,
    required String title,
    required String period,
  }) async {
    final storage = Get.find<DocumentStorageService>();
    await storage.updateDocument(
      id: documentId,
      customTitle: title.trim().isEmpty ? null : title.trim(),
      customPeriod: period.trim().isEmpty ? null : period.trim(),
    );

    if (Get.isRegistered<DocumentUploadController>()) {
      await Get.find<DocumentUploadController>().refreshDocumentList();
    }
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refresh();
    }
  }
}
