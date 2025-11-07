import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/Categoria.dart'; // Importa tu modelo real

class AdminCategoriesFormPage extends StatefulWidget {
  final Categoria? categoria; // null para crear, con datos para editar
  final List<Categoria> categoriasDisponibles;

  const AdminCategoriesFormPage({
    super.key,
    this.categoria,
    required this.categoriasDisponibles,
  });

  @override
  State<AdminCategoriesFormPage> createState()=>
      _AdminCategoriesFormPageState();
}

class _AdminCategoriesFormPageState extends State<AdminCategoriesFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  String? _selectedParentId;
  bool _isLoading = false;

  bool get isEditing => widget.categoria != null;

  @override
  void initState(){
    super.initState();
    if (isEditing){
      _nombreController.text = widget.categoria!.nombre;
      _selectedParentId = widget.categoria!.parentCategoriaID;
    }
  }

  @override
  void dispose(){
    _nombreController.dispose();
    super.dispose();
  }

  List<Categoria> get categoriasParaPadre {
    if (!isEditing)return widget.categoriasDisponibles;

    // Al editar, excluir la categoría actual para evitar ciclos
    return widget.categoriasDisponibles
        .where((cat)=> cat.id != widget.categoria!.id)
        .toList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Categoría' : 'Nueva Categoría',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de la categoría actual (solo al editar)
              if (isEditing)...[
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editando:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.categoria!.nombre,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (widget.categoria!.parentCategoriaID != null)
                          Text(
                            'Subcategoría de: ${_getParentName()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Campo nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría *',
                  hintText: 'Ingrese el nombre de la categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value){
                  if (value == null || value.trim().isEmpty){
                    return 'El nombre es obligatorio';
                  }
                  if (value.trim().length < 2){
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 20),

              // Selector de categoría padre
              const Text(
                'Categoría Padre (Opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    // Opción "Sin categoría padre"
                    RadioListTile<String?>(
                      title: const Text('Categoría principal'),
                      subtitle: const Text('Esta será una categoría raíz'),
                      value: null,
                      groupValue: _selectedParentId,
                      onChanged: (value){
                        setState((){
                          _selectedParentId = value;
                        });
                      },
                    ),

                    const Divider(height: 1),

                    // Lista de categorías disponibles como padre
                    ...categoriasParaPadre.map((categoria){
                      return RadioListTile<String>(
                        title: Text(categoria.nombre),
                        subtitle: Text(
                          'Será subcategoría de ${categoria.nombre}',
                        ),
                        value: categoria.id,
                        groupValue: _selectedParentId,
                        onChanged: (value){
                          setState((){
                            _selectedParentId = value;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Vista previa
              if (_nombreController.text.isNotEmpty)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vista previa:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.category, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              _nombreController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (_selectedParentId != null)...[
                          const SizedBox(height: 4),
                          Text(
                            'Subcategoría de: ${_getSelectedParentName()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : ()=> Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategoria,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
)
                          : Text(isEditing ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getParentName(){
    if (widget.categoria?.parentCategoriaID == null)return '';

    try {
      final parent = widget.categoriasDisponibles.firstWhere(
        (cat)=> cat.id == widget.categoria!.parentCategoriaID,
      );
      return parent.nombre;
    } catch (e){
      return 'Categoría no encontrada';
    }
  }

  String _getSelectedParentName(){
    if (_selectedParentId == null)return '';

    try {
      final parent = categoriasParaPadre.firstWhere(
        (cat)=> cat.id == _selectedParentId,
      );
      return parent.nombre;
    } catch (e){
      return 'Categoría no encontrada';
    }
  }

  Future<void> _saveCategoria()async {
    if (!_formKey.currentState!.validate())return;

    setState((){
      _isLoading = true;
    });

    try {
      final negocio = await NegocioService.getCurrentUserInfo();
      final nombre = _nombreController.text.trim();

      // Aquí harías la llamada a GraphQL para crear/actualizar
      if (isEditing){
        final request = ModelMutations.update(
          widget.categoria!.copyWith(
            nombre: nombre,
            parentCategoriaID: _selectedParentId,
            negocioID: negocio.negocioId,
          ),
        );
        await Amplify.API.mutate(request: request).response;

        debugPrint('Actualizando categoría: $nombre, padre: $_selectedParentId');
      } else {
        final newCategoria = Categoria(
          nombre: nombre,
          parentCategoriaID: _selectedParentId,
          negocioID: negocio.negocioId,
          isDeleted: false,
          createdAt: TemporalDateTime.now(),
          updatedAt: TemporalDateTime.now(),
        );
        final request = ModelMutations.create(newCategoria);
        await Amplify.API.mutate(request: request).response;

        debugPrint('Creando categoría: $nombre, padre: $_selectedParentId');
      }

      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Categoría actualizada correctamente'
                  : 'Categoría creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // true indica que hubo cambios
      }
    } catch (e){
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted){
        setState((){
          _isLoading = false;
        });
      }
    }
  }
}
