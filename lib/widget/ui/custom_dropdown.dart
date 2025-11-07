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
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            constraints: BoxConstraints(minHeight: 24, minWidth: 24),
          ),
        ),
      );
    }

    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.blue),
        prefixIcon: Icon(prefixIcon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[900]!, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[600]!, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      hint: Text(hintText),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
