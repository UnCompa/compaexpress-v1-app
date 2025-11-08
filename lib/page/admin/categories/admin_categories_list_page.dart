import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/page/admin/categories/admin_categories_form_page.dart';
import 'package:compaexpress/services/negocio_service.dart';
import 'package:compaexpress/views/pagination.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/Categoria.dart'; // Importa tu modelo real

class AdminCategoriesListPage extends StatefulWidget {
  const AdminCategoriesListPage({super.key});

  @override
  State<AdminCategoriesListPage> createState() =>
      _AdminCategoriesListPageState();
}

class _AdminCategoriesListPageState extends State<AdminCategoriesListPage> {
  List<Categoria> categorias = [];
  List<Categoria> paginatedCategorias = [];
  bool isLoading = true;
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  void _updatePageItems() {
    paginatedCategorias = PaginationWidget.paginateList(
      categorias,
      currentPage,
      itemsPerPage,
    );
  }

  void _onPageChanged(int newPage) {
    if (newPage < 1 ||
        newPage > (categorias.length / itemsPerPage).ceil() ||
        isLoading) {
      return; // Evita cambios de página inválidos o mientras carga
    }

    setState(() {
      isLoading =
          true; // Opcional: para indicar que está "cargando" la nueva página
    });

    // Simular una pequeña demora para ver el efecto de carga
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        currentPage = newPage;
        _updatePageItems();
        isLoading = false;
      });
    });
  }

  Future<void> _loadCategorias() async {
    setState(() {
      isLoading = true;
    });

    try {
      final negocio = await NegocioService.getCurrentUserInfo();
      final request = ModelQueries.list(
        Categoria.classType,
        where:
            Categoria.NEGOCIOID.eq(negocio.negocioId) &
            Categoria.ISDELETED.eq(false),
      );
      final response = await Amplify.API.query(request: request).response;
      safePrint('response: $response');
      final categories = response.data?.items;
      if (categories == null) {
        safePrint('errors: ${response.errors}');
      }
      setState(() {
        categorias =
            response.data?.items
                    .where((item) => item != null)
                    .cast<Categoria>()
                    .toList()
                as List<Categoria>;
      });
      _updatePageItems();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar categorías: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Categoria> get filteredCategorias {
    if (searchQuery.isEmpty) return categorias;
    return categorias
        .where(
          (cat) => cat.nombre.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categorías',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategorias,
          ),
        ],
      ),
      body: Column(
        children: [
          PaginationWidget(
            currentPage: currentPage,
            totalItems: categorias.length,
            itemsPerPage: itemsPerPage,
            onPageChanged: _onPageChanged,
            isLoading: isLoading,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar categorías...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Lista de categorías
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : paginatedCategorias.isEmpty
                ? const Center(
                    child: Text(
                      'No hay categorías disponibles',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCategorias,
                    child: ListView.builder(
                      itemCount: paginatedCategorias.length,
                      itemBuilder: (context, index) {
                        return _buildCategoriaItem(paginatedCategorias[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoriaItem(Categoria categoria) {
    // Obtener subcategorías si tu modelo las maneja de manera diferente
    final subCategorias = _getSubcategorias(categoria);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.category),
        title: Text(
          categoria.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: subCategorias.isNotEmpty
            ? Text('${subCategorias.length} subcategorías')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToForm(categoria: categoria),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(categoria),
            ),
          ],
        ),
        children: subCategorias
            .map((subCat) => _buildSubCategoriaItem(subCat))
            .toList(),
      ),
    );
  }

  List<Categoria> _getSubcategorias(Categoria categoria) {
    // Ajusta esta lógica según cómo tu modelo maneja las subcategorías
    // Si tienes una propiedad subCategorias en tu modelo:
    // return categoria.subCategorias ?? [];

    // Si necesitas buscar en la lista principal por parentCategoriaID:
    return categorias
        .where((cat) => cat.parentCategoriaID == categoria.id)
        .toList();
  }

  Widget _buildSubCategoriaItem(Categoria subCategoria) {
    return ListTile(
      leading: const SizedBox(width: 20),
      title: Row(
        children: [
          const Icon(Icons.subdirectory_arrow_right, size: 16),
          const SizedBox(width: 8),
          Text(subCategoria.nombre),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
            onPressed: () => _navigateToForm(categoria: subCategoria),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () => _showDeleteDialog(subCategoria),
          ),
        ],
      ),
    );
  }

  void _navigateToForm({Categoria? categoria}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCategoriesFormPage(
          categoria: categoria,
          categoriasDisponibles: categorias,
        ),
      ),
    ).then((result) {
      if (result) {
        _loadCategorias(); // Recargar la lista si hubo cambios
      }
    });
  }

  void _showDeleteDialog(Categoria categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${categoria.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategoria(categoria);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategoria(Categoria categoria) async {
    try {
      // Aquí harías la llamada a GraphQL para eliminar
      final categoriaDelete = categoria.copyWith(isDeleted: true);
      final request = ModelMutations.update(categoriaDelete);
      await Amplify.API.mutate(request: request).response;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría eliminada correctamente')),
      );

      _loadCategorias();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }
}
