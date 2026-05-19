import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Stable content hash for duplicate PDF detection.
class DocumentFingerprint {
  DocumentFingerprint._();

  static String fromPdfBytes(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }
}
