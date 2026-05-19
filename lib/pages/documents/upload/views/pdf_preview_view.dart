import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/colors.dart';

class PdfPreviewView extends StatefulWidget {
  const PdfPreviewView({
    super.key,
    required this.filePath,
    required this.title,
  });

  final String filePath;
  final String title;

  @override
  State<PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> {
  PdfControllerPinch? _controller;

  @override
  void initState() {
    super.initState();
    if (File(widget.filePath).existsSync()) {
      _controller = PdfControllerPinch(
        document: PdfDocument.openFile(widget.filePath),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onSurface,
      appBar: AppBar(
        backgroundColor: AppColors.onSurface,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: _controller == null
          ? Center(
              child: Text(
                'doc_preview_unavailable'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onPrimary,
                    ),
              ),
            )
          : PdfViewPinch(controller: _controller!),
    );
  }
}
