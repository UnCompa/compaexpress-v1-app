import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/page/admin/compras/admin_compras_create_page.dart';
import 'package:compaexpress/page/admin/compras/admin_compras_details_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminComprasListPage extends StatefulWidget {
  final String negocioID;

  const AdminComprasListPage({super.key, required this.negocioID});

  @override
  _AdminComprasListPageState createState() => _AdminComprasListPageState();
}

class _AdminComprasListPageState extends State<AdminComprasListPage> {
  List<CompraProveedor> _purchases = [];
  List<Proveedor> _proveedores = [];
  bool _isLoading = true;
  String? _selectedProveedorId;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProveedores();
    _fetchPurchases();
  }

  Future<void> _fetchProveedores() async {
    try {
      final request = ModelQueries.list(
        Proveedor.classType,
        where: Proveedor.NEGOCIOID
            .eq(widget.negocioID)
            .and(Proveedor.ISDELETED.eq(false)),
      );
      final response = await Amplify.API.query(request: request).response;
      final proveedores = response.data?.items ?? [];
      setState(() {
        _proveedores = proveedores.whereType<Proveedor>().toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar proveedores: $e')),
      );
    }
  }

  // OPCIÓN 2: Usando GraphQLRequest directamente (Para consultas más complejas)
  Future<void> _fetchPurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Construir el filtro GraphQL
      final filter = {
        'negocioID': {'eq': widget.negocioID},
        'isDeleted': {'eq': false},
        if (_selectedProveedorId != null)
          'proveedorID': {'eq': _selectedProveedorId},
        if (_selectedDate != null)
          'fechaCompra': {
            'between': [
              TemporalDateTime(
                DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                ),
              ).toString(),
              TemporalDateTime(
                DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                ).add(Duration(days: 1)),
              ).toString(),
            ],
          },
      };

      final request = GraphQLRequest<String>(
        document: '''
        query ListCompraProveedors(\$filter: ModelCompraProveedorFilterInput, \$limit: Int, \$nextToken: String) {
          listCompraProveedors(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
            items {
              id
              proveedorID
              negocioID
              fechaCompra
              totalCompra
              createdAt
              updatedAt
            }
            nextToken
          }
        }
      ''',
        variables: {'filter': filter, 'limit': 100},
      );

      final response = await Amplify.API.query(request: request).response;

      // Parsear la respuesta JSON manualmente
      final jsonData = json.decode(response.data ?? '{}');
      final items =
          jsonData['listCompraProveedors']?['items'] as List<dynamic>? ?? [];

      final purchases = items
          .map((item) => CompraProveedor.fromJson(item))
          .toList();

      setState(() {
        _purchases = purchases
          ..sort(
            (a, b) => b.fechaCompra.getDateTimeInUtc().compareTo(
              a.fechaCompra.getDateTimeInUtc(),
            ),
          );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar compras: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchPurchases();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Compras'),
        backgroundColor: Colors.blue[800], // Azul oscuro
        foregroundColor: Colors.white, // Texto blanco para contraste
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AdminComprasCreatePage(negocioID: widget.negocioID),
            ),
          );
          if (result) {
            _fetchPurchases();
          }
        },
        backgroundColor: Colors.blue[600], // Azul medio
        foregroundColor: Colors.white,
        tooltip: 'Nueva Compra',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue[50], // Fondo azul claro
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Seleccionar Proveedor'),
                    value: _selectedProveedorId,
                    isExpanded: true,
                    dropdownColor:
                        Colors.white, // Fondo blanco para el dropdown
                    style: const TextStyle(
                      color: Colors.black87,
                    ), // Texto oscuro
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los Proveedores'),
                      ),
                      ..._proveedores.map(
                        (proveedor) => DropdownMenuItem(
                          value: proveedor.id,
                          child: Text(proveedor.nombre),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProveedorId = value;
                      });
                      _fetchPurchases();
                    },
                    underline: Container(
                      height: 2,
                      color: Colors.blue[300], // Línea azul clara
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () => _selectDate(context),
                  tooltip: _selectedDate == null
                      ? 'Filtrar por fecha'
                      : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      _fetchPurchases();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                : _purchases.isEmpty
                ? const Center(
                    child: Text(
                      'No hay compras registradas',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = _purchases[index];
                      final proveedor = _proveedores.firstWhere(
                        (p) => p.id == purchase.proveedorID,
                        orElse: () => Proveedor(
                          id: '',
                          nombre: 'Desconocido',
                          direccion: '',
                          ciudad: '',
                          pais: '',
                          tiempoEntrega: 0,
                          isDeleted: false,
                          createdAt: TemporalDateTime.now(),
                          updatedAt: TemporalDateTime.now(),
                          negocioID: widget.negocioID,
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue[100]!,
                          ), // Borde azul claro
                        ),
                        color: Colors.white, // Fondo blanco para contraste
                        child: ListTile(
                          title: Text(
                            proveedor.nombre,
                            style: TextStyle(
                              color: Colors
                                  .blue[900], // Azul oscuro para el título
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(purchase.fechaCompra.getDateTimeInUtc())} '
                            'Total: \$${purchase.totalCompra.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.blueGrey[600]),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: Colors.blue[600], // Azul medio para el ícono
                          ),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdminCompraDetailPage(
                                  compraID: purchase.id,
                                ),
                              ),
                            );
                            if (result) {
                              _fetchPurchases();
                            }
                          },
                        ),
                      );
                    },
                  ),
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
