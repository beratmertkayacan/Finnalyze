import 'package:flutter/material.dart';

enum UploadScanStatus { analyzing, complete, error }

class UploadRecentItemModel {
  const UploadRecentItemModel({
    required this.id,
    required this.title,
    required this.meta,
    required this.status,
    this.icon = Icons.description_outlined,
    this.isImage = false,
    this.localPath,
  });

  final String id;
  final String title;
  final String meta;
  final UploadScanStatus status;
  final IconData icon;
  final bool isImage;
  final String? localPath;

  UploadRecentItemModel copyWith({
    String? id,
    String? title,
    String? meta,
    UploadScanStatus? status,
    IconData? icon,
    bool? isImage,
    String? localPath,
  }) {
    return UploadRecentItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      meta: meta ?? this.meta,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      isImage: isImage ?? this.isImage,
      localPath: localPath ?? this.localPath,
    );
  }
}
