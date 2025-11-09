import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget reutilizable para campos de texto personalizados
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? hintText;
  final String? suffixText;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final String? helperText;
  final int? minLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.hintText,
    this.suffixText,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.helperText,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      autofocus: autofocus,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: enabled
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface.withOpacity(0.4),
        ),
        helperStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: enabled
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.4),
        ),
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        suffixStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: enabled
            ? theme.scaffoldBackgroundColor
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        counterText: maxLength != null ? null : '',
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withOpacity(0.4),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      cursorColor: colorScheme.primary,
      cursorWidth: 2.0,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
    );
  }
}
