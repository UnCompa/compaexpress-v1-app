import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enum para tipos de filtro
enum FilterType { text, dropdown, dateRange, numberRange, singleDate, boolean }

// Clase para definir un campo de filtro
class FilterField {
  final String key;
  final String label;
  final FilterType type;
  final List<String>? options; // Para dropdown
  final String? hintText;
  final IconData? icon;
  final bool isRequired;

  const FilterField({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.hintText,
    this.icon,
    this.isRequired = false,
  });
}

// Clase para almacenar valores de filtros
class FilterValues {
  final Map<String, dynamic> _values = {};

  dynamic getValue(String key) => _values[key];

  void setValue(String key, dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  void clearValue(String key) => _values.remove(key);

  void clearAll() => _values.clear();

  bool get hasActiveFilters => _values.isNotEmpty;

  Map<String, dynamic> get values => Map.unmodifiable(_values);

  FilterValues copyWith(Map<String, dynamic>? newValues) {
    final copy = FilterValues();
    copy._values.addAll(_values);
    if (newValues != null) {
      copy._values.addAll(newValues);
    }
    return copy;
  }
}

// Widget genérico de filtros
class GenericFilterWidget<T> extends StatefulWidget {
  final List<FilterField> filterFields;
  final FilterValues filterValues;
  final Function(FilterValues) onFiltersChanged;
  final VoidCallback? onClearFilters;
  final String title;
  final bool initiallyExpanded;

  const GenericFilterWidget({
    super.key,
    required this.filterFields,
    required this.filterValues,
    required this.onFiltersChanged,
    this.onClearFilters,
    this.title = 'Filtros',
    this.initiallyExpanded = false,
  });

  @override
  State<GenericFilterWidget<T>> createState() => _GenericFilterWidgetState<T>();
}

class _GenericFilterWidgetState<T> extends State<GenericFilterWidget<T>> {
  late Map<String, TextEditingController> _controllers;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _initializeControllers();
  }

  // Se añadió didUpdateWidget para manejar cambios en filterValues o filterFields desde el padre
  @override
  void didUpdateWidget(covariant GenericFilterWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterValues != oldWidget.filterValues ||
        widget.filterFields != oldWidget.filterFields) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _controllers = {};
    for (final field in widget.filterFields) {
      if (field.type == FilterType.text) {
        final value = widget.filterValues.getValue(field.key);
        _controllers[field.key] = TextEditingController(
          text: value?.toString() ?? '',
        );
      } else if (field.type == FilterType.numberRange) {
        final value = widget.filterValues.getValue(field.key);
        final minValue = value is Map ? value['min']?.toString() ?? '' : '';
        final maxValue = value is Map ? value['max']?.toString() ?? '' : '';
        _controllers['${field.key}_min'] = TextEditingController(
          text: minValue,
        );
        _controllers['${field.key}_max'] = TextEditingController(
          text: maxValue,
        );
      }
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Helper para el InputDecoration común
  InputDecoration _commonInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
      prefixText: prefixText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Column(
        children: [
          // Header del filtro
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.filterValues.hasActiveFilters) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '●', // Un punto para indicar filtros activos
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (widget.filterValues.hasActiveFilters)
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: Text(
                            'Limpiar',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Contenido expandible
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFilterFieldsResponsive(),
            ),
          ],
        ],
      ),
    );
  }

  // **NUEVO: Método para construir campos de filtro responsive usando Wrap**
  Widget _buildFilterFieldsResponsive() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define el ancho mínimo para que un campo ocupe la mitad de la pantalla
        final double minWidthForTwoColumns = 500; // Puedes ajustar este valor
        final bool isTwoColumnLayout =
            constraints.maxWidth > minWidthForTwoColumns;

        return Wrap(
          spacing: 16.0, // Espacio horizontal entre los campos
          runSpacing: 16.0, // Espacio vertical entre las líneas de campos
          alignment: WrapAlignment.start,
          children: widget.filterFields.map((field) {
            // Envuelve cada campo en un SizedBox para controlar el ancho en un layout de dos columnas
            // Si el layout es de dos columnas, cada campo ocupa aproximadamente la mitad del ancho disponible.
            // Si es de una columna (pantalla pequeña), ocupa todo el ancho disponible.
            return SizedBox(
              width: isTwoColumnLayout
                  ? (constraints.maxWidth / 2) -
                        8 // -8 para compensar el spacing
                  : constraints.maxWidth,
              child: _buildFilterField(field),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFilterField(FilterField field) {
    switch (field.type) {
      case FilterType.text:
        return _buildTextField(field);
      case FilterType.dropdown:
        return _buildDropdownField(field);
      case FilterType.dateRange:
        return _buildDateRangeField(field);
      case FilterType.singleDate:
        return _buildSingleDateField(field);
      case FilterType.numberRange:
        return _buildNumberRangeField(field);
      case FilterType.boolean:
        return _buildBooleanField(field);
    }
  }

  Widget _buildTextField(FilterField field) {
    return TextFormField(
      controller: _controllers[field.key],
      decoration: _commonInputDecoration(
        labelText: field.label,
        hintText: field.hintText,
        prefixIcon: field.icon,
      ),
      onChanged: (value) {
        widget.filterValues.setValue(field.key, value.isEmpty ? null : value);
        widget.onFiltersChanged(widget.filterValues);
      },
    );
  }

  Widget _buildDropdownField(FilterField field) {
    final options = ['Todos', ...?field.options];
    final currentValue = widget.filterValues.getValue(field.key) ?? 'Todos';

    return DropdownButtonFormField<String>(
      value: options.contains(currentValue) ? currentValue : 'Todos',
      decoration: _commonInputDecoration(
        labelText: field.label,
        prefixIcon: field.icon,
      ),
      items: options.map((option) {
        return DropdownMenuItem(value: option, child: Text(option));
      }).toList(),
      onChanged: (value) {
        widget.filterValues.setValue(
          field.key,
          value == 'Todos' ? null : value,
        );
        widget.onFiltersChanged(widget.filterValues);
      },
    );
  }

  Widget _buildSingleDateField(FilterField field) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final value = widget.filterValues.getValue(field.key) as DateTime?;

    return TextFormField(
      readOnly: true,
      decoration: _commonInputDecoration(
        labelText: field.label,
        prefixIcon: field.icon,
        suffixIcon: Icons.calendar_today,
      ),
      controller: TextEditingController(
        text: value != null ? dateFormat.format(value) : '',
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null) {
          widget.filterValues.setValue(field.key, pickedDate);
          widget.onFiltersChanged(widget.filterValues);
        }
      },
    );
  }

  Widget _buildDateRangeField(FilterField field) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final value =
        widget.filterValues.getValue(field.key) as Map<String, DateTime>?;
    final startDate = value?['start'];
    final endDate = value?['end'];

    return Column(
      // Usar Column para que los campos de fecha de un rango se apilen en pantallas pequeñas
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: true,
          decoration: _commonInputDecoration(
            labelText: '${field.label} (Desde)',
            suffixIcon: Icons.calendar_today,
          ),
          controller: TextEditingController(
            text: startDate != null ? dateFormat.format(startDate) : '',
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              final currentValue =
                  widget.filterValues.getValue(field.key)
                      as Map<String, DateTime>? ??
                  {};
              currentValue['start'] = pickedDate;
              widget.filterValues.setValue(field.key, currentValue);
              widget.onFiltersChanged(widget.filterValues);
            }
          },
        ),
        const SizedBox(height: 8), // Espacio entre "Desde" y "Hasta"
        TextFormField(
          readOnly: true,
          decoration: _commonInputDecoration(
            labelText: '${field.label} (Hasta)',
            suffixIcon: Icons.calendar_today,
          ),
          controller: TextEditingController(
            text: endDate != null ? dateFormat.format(endDate) : '',
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              final currentValue =
                  widget.filterValues.getValue(field.key)
                      as Map<String, DateTime>? ??
                  {};
              currentValue['end'] = pickedDate;
              widget.filterValues.setValue(field.key, currentValue);
              widget.onFiltersChanged(widget.filterValues);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNumberRangeField(FilterField field) {
    return Column(
      // Usar Column para que los campos de número de un rango se apilen en pantallas pequeñas
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controllers['${field.key}_min'],
          keyboardType: TextInputType.number,
          decoration: _commonInputDecoration(
            labelText: '${field.label} (Min)',
            prefixText: '\$ ',
          ),
          onChanged: (value) {
            final currentValue =
                widget.filterValues.getValue(field.key)
                    as Map<String, double>? ??
                {};
            final minValue = double.tryParse(value);
            if (minValue != null) {
              currentValue['min'] = minValue;
            } else {
              currentValue.remove('min');
            }
            widget.filterValues.setValue(
              field.key,
              currentValue.isEmpty ? null : currentValue,
            );
            widget.onFiltersChanged(widget.filterValues);
          },
        ),
        const SizedBox(height: 8), // Espacio entre "Min" y "Max"
        TextFormField(
          controller: _controllers['${field.key}_max'],
          keyboardType: TextInputType.number,
          decoration: _commonInputDecoration(
            labelText: '${field.label} (Max)',
            prefixText: '\$ ',
          ),
          onChanged: (value) {
            final currentValue =
                widget.filterValues.getValue(field.key)
                    as Map<String, double>? ??
                {};
            final maxValue = double.tryParse(value);
            if (maxValue != null) {
              currentValue['max'] = maxValue;
            } else {
              currentValue.remove('max');
            }
            widget.filterValues.setValue(
              field.key,
              currentValue.isEmpty ? null : currentValue,
            );
            widget.onFiltersChanged(widget.filterValues);
          },
        ),
      ],
    );
  }

  Widget _buildBooleanField(FilterField field) {
    final value = widget.filterValues.getValue(field.key) as bool?;

    return CheckboxListTile(
      title: Text(field.label),
      value: value ?? false,
      onChanged: (newValue) {
        widget.filterValues.setValue(field.key, newValue);
        widget.onFiltersChanged(widget.filterValues);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _clearAllFilters() {
    _disposeControllers(); // Disponer y reiniciar controladores para limpiar texto
    widget.filterValues.clearAll();
    widget.onFiltersChanged(widget.filterValues);
    _initializeControllers(); // Re-inicializar para reflejar los valores limpios

    if (widget.onClearFilters != null) {
      widget.onClearFilters!();
    }
  }
}

// Clase auxiliar para crear filtros fácilmente
class FilterBuilder {
  static FilterField text({
    required String key,
    required String label,
    String? hintText,
    IconData? icon,
    bool isRequired = false,
  }) {
    return FilterField(
      key: key,
      label: label,
      type: FilterType.text,
      hintText: hintText,
      icon: icon,
      isRequired: isRequired,
    );
  }

  static FilterField dropdown({
    required String key,
    required String label,
    required List<String> options,
    IconData? icon,
    bool isRequired = false,
  }) {
    return FilterField(
      key: key,
      label: label,
      type: FilterType.dropdown,
      options: options,
      icon: icon,
      isRequired: isRequired,
    );
  }

  static FilterField dateRange({
    required String key,
    required String label,
    IconData? icon,
    bool isRequired = false,
  }) {
    return FilterField(
      key: key,
      label: label,
      type: FilterType.dateRange,
      icon: icon,
      isRequired: isRequired,
    );
  }

  static FilterField singleDate({
    required String key,
    required String label,
    IconData? icon,
    bool isRequired = false,
  }) {
    return FilterField(
      key: key,
      label: label,
      type: FilterType.singleDate,
      icon: icon,
      isRequired: isRequired,
    );
  }

  static FilterField numberRange({
    required String key,
    required String label,
    IconData? icon,
    bool isRequired = false,
  }) {
    return FilterField(
      key: key,
      label: label,
      type: FilterType.numberRange,
      icon: icon,
      isRequired: isRequired,
    );
  }

  static FilterField boolean({
    required String key,
    required String label,
    IconData? icon,
    bool isRequired = false,
  }) {
    return FilterField(
      key: key,
      label: label,
      type: FilterType.boolean,
      icon: icon,
      isRequired: isRequired,
    );
  }
}
