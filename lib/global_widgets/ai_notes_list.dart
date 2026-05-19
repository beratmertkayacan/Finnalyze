import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../core/utils/ai_notes_parser.dart';

class AiNotesList extends StatelessWidget {
  const AiNotesList({
    super.key,
    required this.text,
    this.textColor = AppColors.onPrimary,
    this.bulletColor = AppColors.onPrimary,
    this.noteBackgroundColor,
  });

  final String text;
  final Color textColor;
  final Color bulletColor;
  final Color? noteBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final notes = AiNotesParser.parse(text);
    if (notes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < notes.length; i++) ...[
          if (i > 0) const SizedBox(height: AppConstants.paddingSm),
          _NoteTile(
            note: notes[i],
            textColor: textColor,
            bulletColor: bulletColor,
            backgroundColor: noteBackgroundColor,
          ),
        ],
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.textColor,
    required this.bulletColor,
    this.backgroundColor,
  });

  final String note;
  final Color textColor;
  final Color bulletColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingXs,
      ),
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: 16,
              color: bulletColor.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSm),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
