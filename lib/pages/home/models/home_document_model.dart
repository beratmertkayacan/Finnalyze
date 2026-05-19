import 'package:flutter/material.dart';

class HomeDocumentModel {
  const HomeDocumentModel({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.amountLabel,
    this.icon = Icons.description_outlined,
  });

  final String id;
  final String title;
  final String dateLabel;
  final String amountLabel;
  final IconData icon;
}
