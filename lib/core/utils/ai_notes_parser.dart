/// Splits Gemini plain-text responses into discrete note lines.
class AiNotesParser {
  AiNotesParser._();

  static List<String> parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];

    final lines = trimmed.split(RegExp(r'\r?\n'));
    final notes = <String>[];

    for (final line in lines) {
      var note = line.trim();
      if (note.isEmpty) continue;
      note = note.replaceFirst(RegExp(r'^[\-\*•]\s+'), '');
      note = note.replaceFirst(RegExp(r'^\d+[\.\):\-]\s*'), '');
      note = note.trim();
      if (note.isNotEmpty) notes.add(note);
    }

    if (notes.isNotEmpty) return notes;

    return [trimmed];
  }
}
