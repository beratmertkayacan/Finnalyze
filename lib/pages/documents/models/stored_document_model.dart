import 'document_analysis_model.dart';

class StoredDocumentModel {
  const StoredDocumentModel({
    required this.id,
    required this.analysis,
    required this.fileName,
    required this.uploadedAt,
    this.localPath,
    this.contentFingerprint = '',
    this.customTitle,
    this.customPeriod,
  });

  final String id;
  final DocumentAnalysisModel analysis;
  final String fileName;
  final DateTime uploadedAt;
  final String? localPath;
  final String contentFingerprint;
  final String? customTitle;
  final String? customPeriod;

  String get displayTitle => analysis.documentTitle.isNotEmpty
      ? analysis.documentTitle
      : fileName;

  String get smartTitle {
    if (customTitle != null && customTitle!.trim().isNotEmpty) {
      return customTitle!.trim();
    }

    final label = _resolveCardOrBankLabel();
    final month = _monthLabelFromPeriod();

    if (label.isNotEmpty && month.isNotEmpty) return '$label · $month';
    if (label.isNotEmpty) return label;

    final title = analysis.documentTitle.trim();
    if (title.contains(' · ')) {
      final parts = title.split(' · ');
      final extracted = parts.last.trim();
      if (extracted.isNotEmpty && month.isNotEmpty) {
        return '$extracted · $month';
      }
      if (extracted.isNotEmpty) return extracted;
    }

    return displayTitle;
  }

  String _resolveCardOrBankLabel() {
    if (analysis.cardLabel.trim().isNotEmpty) {
      return analysis.cardLabel.trim();
    }
    if (analysis.bankName.trim().isNotEmpty) {
      return analysis.bankName.trim();
    }
    return '';
  }

  String get smartPeriodLabel {
    if (customPeriod != null && customPeriod!.trim().isNotEmpty) {
      return customPeriod!.trim();
    }

    final raw = analysis.period;
    if (raw.isEmpty) return fileName;
    final parts = raw.split(RegExp(r'\s*[-–]\s*'));
    if (parts.length == 2) {
      final start = _formatShortDate(parts[0].trim());
      final end = _formatShortDate(parts[1].trim());
      if (start.isNotEmpty && end.isNotEmpty) return '$start – $end';
    }
    return raw;
  }

  String _monthLabelFromPeriod() {
    final period = analysis.period;
    if (period.isEmpty) return '';
    final dateStr = period.split(RegExp(r'\s*[-–]\s*')).first.trim();
    final parts = dateStr.split('.');
    if (parts.length < 3) return '';
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || year == null || month < 1 || month > 12) return '';
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${months[month - 1]} $year';
  }

  String _formatShortDate(String raw) {
    final parts = raw.split('.');
    if (parts.length < 3) return raw;
    final day = parts[0];
    final month = int.tryParse(parts[1]);
    final year = parts[2];
    if (month == null || month < 1 || month > 12) return raw;
    const short = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return '$day ${short[month - 1]} $year';
  }

  StoredDocumentModel copyWith({
    String? id,
    DocumentAnalysisModel? analysis,
    String? fileName,
    DateTime? uploadedAt,
    String? localPath,
    String? contentFingerprint,
    String? customTitle,
    String? customPeriod,
    bool clearCustomTitle = false,
    bool clearCustomPeriod = false,
  }) {
    return StoredDocumentModel(
      id: id ?? this.id,
      analysis: analysis ?? this.analysis,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      localPath: localPath ?? this.localPath,
      contentFingerprint: contentFingerprint ?? this.contentFingerprint,
      customTitle: clearCustomTitle ? null : (customTitle ?? this.customTitle),
      customPeriod:
          clearCustomPeriod ? null : (customPeriod ?? this.customPeriod),
    );
  }

  factory StoredDocumentModel.fromJson(Map<String, dynamic> json) {
    return StoredDocumentModel(
      id: json['id'] as String? ?? '',
      analysis: DocumentAnalysisModel.fromJson(
        json['analysis'] as Map<String, dynamic>? ?? const {},
      ),
      fileName: json['fileName'] as String? ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ??
          DateTime.now(),
      localPath: json['localPath'] as String?,
      contentFingerprint: json['contentFingerprint'] as String? ?? '',
      customTitle: json['customTitle'] as String?,
      customPeriod: json['customPeriod'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'analysis': analysis.toJson(),
        'fileName': fileName,
        'uploadedAt': uploadedAt.toIso8601String(),
        if (localPath != null) 'localPath': localPath,
        if (contentFingerprint.isNotEmpty)
          'contentFingerprint': contentFingerprint,
        if (customTitle != null) 'customTitle': customTitle,
        if (customPeriod != null) 'customPeriod': customPeriod,
      };
}
