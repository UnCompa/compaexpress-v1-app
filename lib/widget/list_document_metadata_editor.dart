import 'package:compaexpress/models/DocumentMetadata.dart';
import 'package:flutter/material.dart';

// Widget principal que gestiona la lista de metadatos
class ListDocumentMetadataEditor extends StatefulWidget {
  final List<DocumentMetadata>? initialMetadata;
  final ValueChanged<List<DocumentMetadata>> onChanged;

  const ListDocumentMetadataEditor({
    super.key,
    this.initialMetadata,
    required this.onChanged,
  });

  @override
  State<ListDocumentMetadataEditor> createState() =>
      _ListDocumentMetadataEditorState();
}

class _ListDocumentMetadataEditorState
    extends State<ListDocumentMetadataEditor> {
  // Lista de metadatos que se está editando
  late List<DocumentMetadata> _metadataList;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista con los datos iniciales o una lista vacía
    _metadataList =
        widget.initialMetadata?.where((m) => m.key.isNotEmpty).toList() ?? [];
    // Asegura que siempre haya al menos una fila vacía para empezar
    if (_metadataList.isEmpty) {
      _addMetadataItem();
    }
  }

  // Método para agregar un nuevo ítem a la lista
  void _addMetadataItem() {
    setState(() {
      _metadataList.add(DocumentMetadata(key: 'Campo Adicional', value: ''));
    });
    // Notifica el cambio (aunque sea vacío, puede ser útil para habilitar el botón de guardar)
    _notifyChanges();
  }

  // Método para eliminar un ítem de la lista
  void _removeMetadataItem(int index) {
    setState(() {
      _metadataList.removeAt(index);
    });
    // Si se elimina el último, se añade uno nuevo para evitar una UI vacía
    if (_metadataList.isEmpty) {
      _addMetadataItem();
    }
    _notifyChanges();
  }

  // Método para actualizar un valor (key o value)
  void _updateItem(int index, {String? key, String? value}) {
    if (key != null) {
      _metadataList[index] = _metadataList[index].copyWith(key: key);
    }
    if (value != null) {
      _metadataList[index] = _metadataList[index].copyWith(value: value);
    }
    _notifyChanges();
  }

  // Notifica al widget padre con la lista filtrada de elementos con clave no vacía
  void _notifyChanges() {
    // Filtra los elementos que tienen una clave para asegurar que solo se guarden datos útiles
    final validMetadata = _metadataList
        .where((m) => m.key.trim().isNotEmpty)
        .toList();
    widget.onChanged(validMetadata);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            'Metadatos/Campos Adicionales',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        // Lista de campos editables
        _buildMetadataList(theme),

        const SizedBox(height: 16),

        // Botón para agregar nueva línea
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addMetadataItem,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Agregar Campo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataList(ThemeData theme) {
    // Usamos ListView.builder dentro de una altura fija o Expanded,
    // o una columna envuelta en SingleChildScrollView para mantener el scroll del padre.
    // Usaré un Column dentro de un ListView.builder para eficiencia, pero debo asegurar que esté contenido.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _metadataList.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna 1: Clave (Key)
              Expanded(
                flex: 4,
                child: TextFormField(
                  initialValue: item.key,
                  decoration: InputDecoration(
                    labelText: 'Clave',
                    hintText: 'Ej. Referencia Cliente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (key) => _updateItem(index, key: key),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),

              // Columna 2: Valor (Value)
              Expanded(
                flex: 6,
                child: TextFormField(
                  initialValue: item.value,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Ej. 123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => _updateItem(index, value: value),
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              // Botón de eliminar
              SizedBox(
                width: 48, // Ajusta el ancho para el botón
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: _metadataList.length > 1
                      ? () => _removeMetadataItem(index)
                      : null,
                  tooltip: 'Eliminar campo',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
