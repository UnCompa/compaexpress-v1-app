import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_text_field.dart';

/// Widget para la sección de precios del producto
class PriceSectionWidget extends StatelessWidget {
  final List<Map<String, TextEditingController>> preciosControllers;
  final VoidCallback onAddPrice;
  final Function(int) onDeletePrice;

  const PriceSectionWidget({
    super.key,
    required this.preciosControllers,
    required this.onAddPrice,
    required this.onDeletePrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Precios del Producto *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...preciosControllers.asMap().entries.map((entry) {
              return _PriceItemWidget(
                index: entry.key,
                controllers: entry.value,
                canDelete: preciosControllers.length > 1,
                onDelete: () => onDeletePrice(entry.key),
              );
            }),
            ElevatedButton.icon(
              onPressed: onAddPrice,
              icon: const Icon(Icons.add),
              label: const Text('Agregar otro precio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceItemWidget extends StatelessWidget {
  final int index;
  final Map<String, TextEditingController> controllers;
  final bool canDelete;
  final VoidCallback onDelete;

  const _PriceItemWidget({
    required this.index,
    required this.controllers,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        CustomTextField(
          controller: controllers['nombre']!,
          labelText: 'Nombre del Precio',
          hintText: 'Ej: Público',
          prefixIcon: Icons.label,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [LengthLimitingTextInputFormatter(20)],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controllers['precio']!,
                labelText: 'Precio',
                hintText: 'Ej: 999.99',
                prefixIcon: Icons.attach_money,
                suffixText: 'USD',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Ingresa un precio válido mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: controllers['cantidad']!,
                labelText: 'Cantidad',
                hintText: 'Ej: 1',
                prefixIcon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La cantidad es obligatoria';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'Ingresa una cantidad válida mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canDelete ? onDelete : null,
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomTextField(
              controller: controllers['nombre']!,
              labelText: 'Nombre del Precio',
              hintText: 'Ej: Público',
              prefixIcon: Icons.label,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: CustomTextField(
              controller: controllers['precio']!,
              labelText: 'Precio',
              hintText: 'Ej: 999.99',
              prefixIcon: Icons.attach_money,
              suffixText: 'USD',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio es obligatorio';
                }
                final precio = double.tryParse(value);
                if (precio == null || precio <= 0) {
                  return 'Ingresa un precio válido mayor a 0';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomTextField(
              controller: controllers['cantidad']!,
              labelText: 'Cantidad',
              hintText: 'Ej: 1',
              prefixIcon: Icons.numbers_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad es obligatoria';
                }
                final cantidad = int.tryParse(value);
                if (cantidad == null || cantidad <= 0) {
                  return 'Ingresa una cantidad válida mayor a 0';
                }
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: canDelete ? onDelete : null,
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
