import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/colors.dart';
import '../../../../core/constants.dart';
import '../../../../global_widgets/plain_text_field.dart';

/// Shown after successful PDF analysis or to edit an existing document name/period.
class DocumentNameSheet extends StatefulWidget {
  const DocumentNameSheet({
    super.key,
    required this.initialTitle,
    required this.initialPeriod,
    required this.onSave,
    this.isEditMode = false,
  });

  final String initialTitle;
  final String initialPeriod;
  final Future<void> Function(String title, String period) onSave;
  final bool isEditMode;

  @override
  State<DocumentNameSheet> createState() => _DocumentNameSheetState();
}

class _DocumentNameSheetState extends State<DocumentNameSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _periodController;
  late final FocusNode _titleFocus;
  late final FocusNode _periodFocus;
  final ScrollController _scrollController = ScrollController();
  bool _isSaving = false;

  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _periodKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _periodController = TextEditingController(text: widget.initialPeriod);
    _titleFocus = FocusNode()
      ..addListener(() {
        if (_titleFocus.hasFocus) _scrollToFocused(_titleKey);
      });
    _periodFocus = FocusNode()
      ..addListener(() {
        if (_periodFocus.hasFocus) _scrollToFocused(_periodKey);
      });
  }

  void _scrollToFocused(GlobalKey key) {
    if (!mounted) return;
    // Small delay so the keyboard inset is already applied before we scroll.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final target = key.currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.5,
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _periodController.dispose();
    _titleFocus.dispose();
    _periodFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _closeSheet() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    _isSaving = true;

    final title = _titleController.text;
    final period = _periodController.text;

    await _closeSheet();
    await widget.onSave(title, period);
  }

  @override
  Widget build(BuildContext context) {
    final sheetTitle = widget.isEditMode
        ? 'doc_edit_sheet_title'.tr
        : 'upload_name_sheet_title'.tr;
    final sheetSubtitle = 'upload_name_sheet_subtitle'.tr;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          AppConstants.paddingMd,
          AppConstants.paddingMd,
          AppConstants.paddingMd,
          AppConstants.paddingXl + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            Row(
              children: [
                Icon(
                  widget.isEditMode
                      ? Icons.edit_outlined
                      : Icons.check_circle_rounded,
                  color:
                      widget.isEditMode ? AppColors.primary : AppColors.positive,
                  size: 22,
                ),
                const SizedBox(width: AppConstants.paddingXs),
                Expanded(
                  child: Text(
                    sheetTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXs),
            Text(
              sheetSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            PlainTextField(
              key: _titleKey,
              controller: _titleController,
              focusNode: _titleFocus,
              enabled: !_isSaving,
              decoration: InputDecoration(
                labelText: 'upload_name_sheet_label_title'.tr,
                hintText: 'upload_name_sheet_hint_title'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMd),
            PlainTextField(
              key: _periodKey,
              controller: _periodController,
              focusNode: _periodFocus,
              enabled: !_isSaving,
              decoration: InputDecoration(
                labelText: 'upload_name_sheet_label_period'.tr,
                hintText: 'upload_name_sheet_hint_period'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _closeSheet,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingSm,
                      ),
                    ),
                    child: Text('upload_name_sheet_skip'.tr),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingSm,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Text('upload_name_sheet_save'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Edit existing document name/period from list or analysis tab.
class EditDocumentNameSheet extends StatelessWidget {
  const EditDocumentNameSheet({
    super.key,
    required this.initialTitle,
    required this.initialPeriod,
    required this.onSave,
  });

  final String initialTitle;
  final String initialPeriod;
  final Future<void> Function(String title, String period) onSave;

  @override
  Widget build(BuildContext context) {
    return DocumentNameSheet(
      initialTitle: initialTitle,
      initialPeriod: initialPeriod,
      onSave: onSave,
      isEditMode: true,
    );
  }
}
