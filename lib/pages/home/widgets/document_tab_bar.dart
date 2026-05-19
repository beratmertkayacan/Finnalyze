import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../documents/models/stored_document_model.dart';

/// Horizontal document picker (white pill tabs) — used on the Analysis tab only.
class DocumentTabBar extends StatelessWidget {
  const DocumentTabBar({
    super.key,
    required this.docs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<StoredDocumentModel> docs;
  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(docs.length, (i) {
          final doc = docs[i];
          final isSelected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: i < docs.length - 1 ? AppConstants.paddingXs : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSm,
                  vertical: AppConstants.paddingXs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doc.smartTitle,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (doc.smartPeriodLabel.isNotEmpty)
                      Text(
                        doc.smartPeriodLabel,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? AppColors.onPrimary
                                          .withValues(alpha: 0.75)
                                      : AppColors.onSurfaceVariant,
                                ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
