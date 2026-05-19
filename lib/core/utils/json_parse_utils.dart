import 'dart:convert';

/// Shared JSON helpers for Gemini responses.
class JsonParseUtils {
  JsonParseUtils._();

  static Map<String, dynamic> asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }
    throw FormatException('Expected JSON object, got ${value.runtimeType}');
  }

  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is! List) return const [];
    final result = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map) {
        result.add(asStringKeyedMap(item));
      }
    }
    return result;
  }

  static double parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is! String) return 0;

    var s = value
        .trim()
        .replaceAll(RegExp(r'[₺TRYtl\s]', caseSensitive: false), '')
        .replaceAll('+', '');

    if (s.isEmpty) return 0;

    // Turkish: 1.234,56
    if (s.contains(',') && s.contains('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      s = s.replaceAll(',', '.');
    }

    return double.tryParse(s) ?? 0;
  }

  static String readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') continue;
      return text;
    }
    return '';
  }

  static Map<String, dynamic> decodeJsonObject(String raw) {
    final cleaned = _repairJson(stripMarkdownFences(raw.trim()));
    try {
      return _decodeMap(cleaned);
    } catch (_) {
      // Fall through to regex extraction / truncation repair.
    }

    final match = RegExp(r'\{[\s\S]*').firstMatch(cleaned);
    if (match == null) {
      throw const FormatException('No JSON object found in response');
    }

    final extracted = _repairJson(match.group(0)!);
    try {
      return _decodeMap(extracted);
    } catch (_) {
      return _decodeMap(_closeTruncatedJson(extracted));
    }
  }

  /// Closes unterminated arrays/objects when Gemini hits MAX_TOKENS.
  static String _closeTruncatedJson(String value) {
    var result = value.trim();
    result = result.replaceAll(RegExp(r',\s*$'), '');

    final lastCompleteObject = result.lastIndexOf('}');
    if (lastCompleteObject > 0) {
      final tail = result.substring(lastCompleteObject + 1).trim();
      if (tail.isNotEmpty && !tail.startsWith(']') && !tail.startsWith('}')) {
        result = result.substring(0, lastCompleteObject + 1);
      }
    }

    var openBraces = 0;
    var openBrackets = 0;
    for (final char in result.runes) {
      final c = String.fromCharCode(char);
      if (c == '{') openBraces++;
      if (c == '}') openBraces--;
      if (c == '[') openBrackets++;
      if (c == ']') openBrackets--;
    }

    for (var i = 0; i < openBrackets; i++) {
      result += ']';
    }
    for (var i = 0; i < openBraces; i++) {
      result += '}';
    }

    return _repairJson(result);
  }

  static Map<String, dynamic> _decodeMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return asStringKeyedMap(decoded);
    throw const FormatException('Decoded JSON is not an object');
  }

  static String _repairJson(String value) {
    var result = value;
    result = result.replaceAll(RegExp(r',\s*}'), '}');
    result = result.replaceAll(RegExp(r',\s*]'), ']');
    return result;
  }

  static String stripMarkdownFences(String value) {
    var result = value;
    if (result.startsWith('```')) {
      result = result.replaceFirst(
        RegExp(r'^```(?:json)?\s*', multiLine: true),
        '',
      );
      result = result.replaceFirst(
        RegExp(r'\s*```\s*$', multiLine: true),
        '',
      );
    }
    return result.trim();
  }
}
