import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:compaexpress/models/Negocio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Asegúrate de importar tu modelo Negocio
// import 'package:tu_app/models/ModelProvider.dart';

class CreateUserSuperadminPage extends StatefulWidget {
  const CreateUserSuperadminPage({super.key});

  @override
  State<CreateUserSuperadminPage> createState() =>
      _CreateUserSuperadminPageState();
}

class _CreateUserSuperadminPageState extends State<CreateUserSuperadminPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;
  String? _selectedNegocioId;
  bool _isLoading = false;
  bool _isLoadingNegocios = false;
  bool _obscurePassword = true;

  final List<String> _roles = ['superadmin', 'admin', 'vendedor'];
  List<Negocio> _negociosList = [];

  @override
  void initState() {
    super.initState();
    _loadNegocios();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadNegocios() async {
    setState(() {
      _isLoadingNegocios = true;
    });

    try {
      final request = ModelQueries.list(Negocio.classType);
      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        safePrint('Errores en la respuesta: ${response.errors}');
        throw Exception('Error al obtener los negocios');
      }

      final negociosItems = response.data?.items;

      final negociosList =
          negociosItems
              ?.where((item) => item != null)
              .map((item) => item!)
              .toList() ??
          [];

      setState(() {
        _negociosList = negociosList;
      });
    } catch (e) {
      safePrint('Error cargando negocios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar negocios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingNegocios = false;
      });
    }
  }

  Future<void> signUpUser({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
    required String role,
    String? negocioId,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userAttributes = <AuthUserAttributeKey, String>{
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          AuthUserAttributeKey.phoneNumber: phoneNumber,
        CognitoUserAttributeKey.custom('role'): role,
        if (negocioId != null && negocioId.isNotEmpty)
          CognitoUserAttributeKey.custom('negocioid'): negocioId,
        if (username.isNotEmpty) CognitoUserAttributeKey.name: username,
        CognitoUserAttributeKey.nickname: username,
      };
      debugPrint("CREATING USER");
      debugPrint(userAttributes.toString());
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      await assignUserToGroup(email, role);
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      safePrint('Error signing up user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar usuario: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<JsonWebToken?> getIdTokenSimple() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      if (session.isSignedIn) {
        final cognitoSession = session as CognitoAuthSession;
        final tokens = cognitoSession.userPoolTokensResult.value;
        return tokens.idToken;
      }
      return null;
    } catch (e) {
      print('Error al obtener ID token: $e');
      return null;
    }
  }

  Future<void> assignUserToGroup(String email, String group) async {
    var idToken = await getIdTokenSimple();
    debugPrint("ID TOKEN: $idToken");
    if (idToken == null) {
      print('No se pudo obtener el token');
      return;
    }
    final String apiUrl = dotenv.env['API_URL'] ?? 'URL no encontrada';
    final uri = Uri.parse("$apiUrl/admin-assign");
    print(idToken.raw);
    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        'Authorization': idToken.raw,
      },
      body: jsonEncode({"username": email, "groupName": group}),
    );

    if (response.statusCode == 200) {
      print("Usuario asignado correctamente");
    } else {
      print("Error al asignar usuario: ${response.body}");
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        if (mounted) {
          Navigator.of(context).pop(true);
        }
        break;
      case AuthSignUpStep.done:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        }
        break;
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    setState(() {
      _selectedRole = null;
      _selectedNegocioId = null;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validación adicional para roles que requieren negocio
      if ((_selectedRole == 'admin' || _selectedRole == 'vendedor') &&
          (_selectedNegocioId == null || _selectedNegocioId!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Los roles admin y vendedor requieren seleccionar un negocio',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await signUpUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _selectedRole!,
        negocioId: _selectedNegocioId,
      );
    }
  }

  bool _shouldShowNegocioSelector() {
    return _selectedRole == 'admin' || _selectedRole == 'vendedor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingNegocios ? null : _loadNegocios,
            tooltip: 'Actualizar negocios',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Crear Nuevo Usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24), // Email
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  if (value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.trim())) {
                      return 'Formato de teléfono inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rol
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role[0].toUpperCase() + role.substring(1)),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Rol del usuario *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.supervised_user_circle),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                    // Limpiar selección de negocio si no es necesaria
                    if (!_shouldShowNegocioSelector()) {
                      _selectedNegocioId = null;
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Debe seleccionar un rol' : null,
              ),
              const SizedBox(height: 16),

              // Selector de Negocio (condicional)
              if (_shouldShowNegocioSelector()) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selección de Negocio Requerida',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los usuarios con rol $_selectedRole deben estar asociados a un negocio específico.',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoadingNegocios)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Cargando negocios...'),
                        ],
                      ),
                    ),
                  )
                else if (_negociosList.isEmpty)
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No hay negocios disponibles',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Debe crear al menos un negocio antes de asignar usuarios con este rol.',
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedNegocioId,
                    items: _negociosList.map((negocio) {
                      return DropdownMenuItem(
                        value: negocio.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              negocio.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (negocio.ruc.isNotEmpty)
                              Text(
                                'RUC: ${negocio.ruc}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Negocio *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                      helperText:
                          'Selecciona el negocio al que pertenecerá el usuario',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedNegocioId = value;
                      });
                    },
                    validator: (value) {
                      if (_shouldShowNegocioSelector() &&
                          (value == null || value.isEmpty)) {
                        return 'Debe seleccionar un negocio para este rol';
                      }
                      return null;
                    },
                    isExpanded: true,
                    menuMaxHeight: 300,
                  ),
                const SizedBox(height: 16),
              ],

              // Información seleccionada
              if (_selectedNegocioId != null &&
                  _shouldShowNegocioSelector()) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Negocio Seleccionado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_negociosList.isNotEmpty) ...[
                          () {
                            final selectedNegocio = _negociosList.firstWhere(
                              (n) => n.id == _selectedNegocioId,
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre: ${selectedNegocio.nombre}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (selectedNegocio.ruc.isNotEmpty)
                                  Text('RUC: ${selectedNegocio.ruc}'),
                                if (selectedNegocio.direccion != null &&
                                    selectedNegocio.direccion!.isNotEmpty)
                                  Text(
                                    'Dirección: ${selectedNegocio.direccion}',
                                  ),
                              ],
                            );
                          }(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botones
              ElevatedButton(
                onPressed: _isLoading || _isLoadingNegocios
                    ? null
                    : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Registrando...'),
                        ],
                      )
                    : const Text(
                        'Registrar Usuario',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: _isLoading ? null : _clearForm,
                child: const Text('Limpiar Formulario'),
              ),

              const SizedBox(height: 16),

              // Información adicional
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Información sobre Roles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Superadmin: Acceso completo al sistema\n'
                        '• Admin: Gestión de un negocio específico\n'
                        '• Vendedor: Operaciones de venta en un negocio',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
