import 'package:flutter/material.dart';

/// Shared input settings that prevent iOS/Android from forcing capitalization.
abstract final class PlainTextInput {
  static const textCapitalization = TextCapitalization.none;
  static const autocorrect = false;
  static const enableSuggestions = false;
  static const spellCheckConfiguration = SpellCheckConfiguration.disabled();
  static const smartDashesType = SmartDashesType.disabled;
  static const smartQuotesType = SmartQuotesType.disabled;

  /// [TextInputType.visiblePassword] iOS ve Android OEM klavyelerde
  /// (Samsung One UI dahil) sistem auto-capitalization'ını devre dışı bırakır.
  /// TextInputType.text bu klavyelerde TextCapitalization.none'ı ezebilir.
  /// Email alanları için çağrı yerinde TextInputType.emailAddress kullan.
  static const keyboardType = TextInputType.visiblePassword;

  static bool _isEmailAutofill(Iterable<String>? autofillHints) {
    if (autofillHints == null) return false;
    for (final hint in autofillHints) {
      if (hint == AutofillHints.email ||
          hint == AutofillHints.username ||
          hint == AutofillHints.newUsername) {
        return true;
      }
    }
    return false;
  }

  /// Picks the keyboard type least likely to force capitalization on OEM skins.
  static TextInputType resolveKeyboardType({
    TextInputType? override,
    bool obscureText = false,
    Iterable<String>? autofillHints,
  }) {
    if (override != null) return override;
    if (obscureText) return TextInputType.visiblePassword;
    if (_isEmailAutofill(autofillHints)) return TextInputType.emailAddress;
    return keyboardType;
  }
}

/// [TextFormField] without auto-capitalization (login, register, etc.).
class PlainTextFormField extends StatelessWidget {
  const PlainTextFormField({
    super.key,
    required this.controller,
    this.validator,
    this.decoration,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.style,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextStyle? style;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: decoration,
      obscureText: obscureText,
      keyboardType: PlainTextInput.resolveKeyboardType(
        override: keyboardType,
        obscureText: obscureText,
        autofillHints: autofillHints,
      ),
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      style: style,
      onFieldSubmitted: onFieldSubmitted,
      textCapitalization: PlainTextInput.textCapitalization,
      autocorrect: PlainTextInput.autocorrect,
      enableSuggestions: PlainTextInput.enableSuggestions,
      spellCheckConfiguration: PlainTextInput.spellCheckConfiguration,
      smartDashesType: PlainTextInput.smartDashesType,
      smartQuotesType: PlainTextInput.smartQuotesType,
    );
  }
}

/// [TextField] without auto-capitalization (bottom sheets, dialogs).
class PlainTextField extends StatelessWidget {
  const PlainTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.decoration,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      enabled: enabled,
      keyboardType: PlainTextInput.resolveKeyboardType(
        override: keyboardType,
      ),
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      textCapitalization: PlainTextInput.textCapitalization,
      autocorrect: PlainTextInput.autocorrect,
      enableSuggestions: PlainTextInput.enableSuggestions,
      spellCheckConfiguration: PlainTextInput.spellCheckConfiguration,
      smartDashesType: PlainTextInput.smartDashesType,
      smartQuotesType: PlainTextInput.smartQuotesType,
    );
  }
}
