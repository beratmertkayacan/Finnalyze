import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Persists uploaded PDF bytes so previews work after the picker temp path expires.
class PdfFileService {
  PdfFileService._();

  static String? _documentsFolder;

  static Future<void> init() async {
    if (_documentsFolder != null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/finnalyze_documents');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      _documentsFolder = folder.path;
    } catch (_) {
      _documentsFolder = null;
    }
  }

  static Future<String?> persistPdf(String documentId, Uint8List bytes) async {
    try {
      await init();
      if (_documentsFolder == null) return null;
      final file = File('$_documentsFolder/$documentId.pdf');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static String? canonicalPath(String documentId) {
    if (_documentsFolder == null) return null;
    final file = File('$_documentsFolder/$documentId.pdf');
    return file.existsSync() ? file.path : null;
  }

  /// Picker temp paths expire; always prefer persisted copy by [documentId].
  static Future<String?> resolvePath(
    String documentId,
    String? storedPath,
  ) async {
    await init();
    if (existsAt(storedPath)) return storedPath;
    return canonicalPath(documentId);
  }

  static Future<Uint8List?> readBytes(String documentId, String? storedPath) async {
    final path = await resolvePath(documentId, storedPath);
    if (path == null) return null;
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static bool existsAt(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  static Future<void> deleteAt(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort file cleanup.
    }
  }

  static Future<void> deleteForDocument(String documentId, String? storedPath) async {
    await deleteAt(storedPath);
    final canonical = canonicalPath(documentId);
    if (canonical != null && canonical != storedPath) {
      await deleteAt(canonical);
    }
  }
}
