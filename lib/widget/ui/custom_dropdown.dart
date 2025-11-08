import 'package:flutter/material.dart';

/// Widget reutilizable para dropdowns personalizados
class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final IconData prefixIcon;
  final String hintText;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isLoading;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.labelText,
    required this.prefixIcon,
    required this.hintText,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.validator,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
          ),
        ),
      );
    }

    return DropdownButtonFormField<T>(
      value: value,
      menuMaxHeight: 300,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: onChanged != null
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface.withOpacity(0.4),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: onChanged != null
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.4),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
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
      ),
      hint: Text(
        hintText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      icon: Icon(
        Icons.arrow_drop_down,
        color: onChanged != null
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withOpacity(0.4),
      ),
      dropdownColor: colorScheme.surface,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
