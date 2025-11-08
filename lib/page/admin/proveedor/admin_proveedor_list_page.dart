import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/proveedor/admin_proveedor_create_page.dart';
import 'package:compaexpress/services/negocio/negocio_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProveedorListPage extends StatefulWidget {
  const AdminProveedorListPage({super.key});

  @override
  State<AdminProveedorListPage> createState() => _AdminProveedorListPageState();
}

class _AdminProveedorListPageState extends State<AdminProveedorListPage> {
  List<Proveedor> proveedores = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Paleta de colores azules
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color backgroundBlue = Color(0xFFF3F8FF);
  static const Color cardBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _loadProveedorList();
  }

  Future<void> _loadProveedorList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final negocio = await NegocioController.getUserInfo();
      final request = ModelQueries.list(
        Proveedor.classType,
        where:
            Proveedor.NEGOCIOID.eq(negocio.negocioId) &
            Proveedor.ISDELETED.eq(false),
      );
      final response = await Amplify.API.query(request: request).response;
      if (response.data != null) {
        setState(() {
          proveedores = response.data!.items.whereType<Proveedor>().toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Proveedor> get filteredProveedores {
    if (searchQuery.isEmpty) return proveedores;
    return proveedores
        .where(
          (proveedor) =>
              proveedor.nombre.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ??
              false,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        "Gestión de Proveedores",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadProveedorList,
          tooltip: 'Actualizar información',
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar proveedores...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: lightBlue),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          icon: Icons.business_rounded,
          label: 'Total',
          value: proveedores.length.toString(),
        ),
        _buildStatCard(
          icon: Icons.search_rounded,
          label: 'Filtrados',
          value: filteredProveedores.length.toString(),
        ),
        /* _buildStatCard(
          icon: Icons.verified_rounded,
          label: 'Activos',
          value: proveedores.where((p) => p.activo == true).length.toString(),
        ), */
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (filteredProveedores.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProveedorList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(lightBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando proveedores...',
            style: GoogleFonts.poppins(
              color: primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar proveedores',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Error desconocido',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProveedorList,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_center_outlined, size: 64, color: lightBlue),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay proveedores registrados'
                  : 'No se encontraron proveedores',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty
                  ? 'Comienza agregando tu primer proveedor'
                  : 'Intenta con otros términos de búsqueda',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedorList() {
    return RefreshIndicator(
      onRefresh: _loadProveedorList,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProveedores.length,
        itemBuilder: (context, index) {
          final proveedor = filteredProveedores[index];
          return _buildProveedorCard(proveedor);
        },
      ),
    );
  }

  Widget _buildProveedorCard(Proveedor proveedor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showProveedorDetails(proveedor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proveedor.nombre ?? 'Sin nombre',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          /*  if (proveedor.email != null)
                            Text(
                              proveedor.email!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ), */
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      /* decoration: BoxDecoration(
                        color: (proveedor.activo ?? false)
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ), */
                      /* child: Text(
                        (proveedor.activo ?? false) ? 'Activo' : 'Inactivo',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: (proveedor.activo ?? false)
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ), */
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    /* if (proveedor.telefono != null) ...[
                      Icon(Icons.phone_rounded, size: 16, color: lightBlue),
                      const SizedBox(width: 4),
                      Text(
                        proveedor.telefono!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ], */
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: lightBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Registrado: ${_formatDate(proveedor.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editProveedor(proveedor),
                      icon: Icon(Icons.edit_rounded, size: 16),
                      label: Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: accentBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteProveedor(proveedor),
                      icon: Icon(Icons.delete_outline_rounded, size: 16),
                      label: Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _addNewProveedor,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Nuevo Proveedor',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(TemporalDateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final date = dateTime.getDateTimeInUtc();
    final hour = date.hour;
    final minute = date.minute;
    final formattedDate = '${date.day}/${date.month}/${date.year} $hour:$minute';
    return formattedDate;
  }

  void _showProveedorDetails(Proveedor proveedor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProveedorDetailsSheet(proveedor),
    );
  }

  Widget _buildProveedorDetailsSheet(Proveedor proveedor) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business_rounded,
                    color: primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proveedor.nombre ?? 'Sin nombre',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      /* Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (proveedor.activo ?? false)
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (proveedor.activo ?? false) ? 'Activo' : 'Inactivo',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (proveedor.activo ?? false)
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ), */
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildDetailRow(
              Icons.location_city,
              'Ciudad',
              proveedor.ciudad,
            ),
            _buildDetailRow(
              Icons.location_on_rounded,
              'Dirección',
              proveedor.direccion,
            ),
            _buildDetailRow(
              Icons.calendar_today_rounded,
              'Fecha de registro',
              _formatDate(proveedor.createdAt),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editProveedor(proveedor);
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteProveedor(proveedor);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: lightBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewProveedor() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ProveedorFormPage()),
    );

    // Si se creó un proveedor, recargar la lista
    if (result == true) {
      _loadProveedorList();
    }
  }

  void _editProveedor(Proveedor proveedor) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProveedorFormPage(proveedor: proveedor),
      ),
    );
    if (result) {
      _loadProveedorList();
    }
  }

  void _deleteProveedor(Proveedor proveedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Confirmar eliminación',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: darkBlue,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar el proveedor "${proveedor.nombre}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final model = proveedor.copyWith(isDeleted: true);
              final request = ModelMutations.update(model);
              await Amplify.API.mutate(request: request).response;
              Navigator.pop(context);
              _loadProveedorList();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Proveedor eliminado: ${proveedor.nombre}'),
                  backgroundColor: Colors.red[600],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
