import 'dart:convert';

import 'package:compaexpress/routes/routes.dart';
import 'package:compaexpress/utils/get_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Modelo para el usuario
class User {
  final String id;
  final String username;
  final bool enabled;
  final String status;
  final DateTime createdAt;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.enabled,
    required this.status,
    required this.createdAt,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      enabled: json['enabled'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      email: json['email'],
    );
  }
}

// Respuesta de la API
class UsersResponse {
  final List<User> users;

  UsersResponse({required this.users});

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    var usersJson = json['users'] as List;
    List<User> usersList = usersJson
        .map((userJson) => User.fromJson(userJson))
        .toList();

    return UsersResponse(users: usersList);
  }
}

class UserListSuperadminPage extends StatefulWidget {
  const UserListSuperadminPage({super.key});

  @override
  State<UserListSuperadminPage> createState() => _UserListSuperadminPageState();
}

class _UserListSuperadminPageState extends State<UserListSuperadminPage> {
  List<User> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      var token = await GetToken.getIdTokenSimple();
      if (token == null) {
        print('No se pudo obtener el token');
        return;
      }
      final String apiUrl = dotenv.env['API_URL'] ?? 'URL no encontrada';
      final response = await http.get(
        Uri.parse('$apiUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": token.raw,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final usersResponse = UsersResponse.fromJson(jsonData);

        setState(() {
          users = usersResponse.users;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al cargar usuarios: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'DISABLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: fetchUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).pushNamed(Routes.superAdminHomeUserCrear);
          if (result == true) {
            fetchUsers();
          }
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total de Usuarios',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  users.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando usuarios...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchUsers,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay usuarios disponibles'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Text(
                  user.email[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${user.username}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Creado: ${_formatDate(user.createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(user.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(user.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          user.status,
                          style: TextStyle(
                            color: _getStatusColor(user.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.enabled
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: user.enabled ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          user.enabled ? 'ACTIVO' : 'INACTIVO',
                          style: TextStyle(
                            color: user.enabled ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
              onTap: () {
                // Aquí puedes agregar navegación a detalle del usuario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario seleccionado: ${user.email}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
