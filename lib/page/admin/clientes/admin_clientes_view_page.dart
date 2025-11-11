// Asumiendo que Client es tu modelo generado
import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/clients_provider.dart';
import 'package:compaexpress/utils/navigation_utils.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:toastification/toastification.dart';

// ==================== PANTALLA PRINCIPAL - LISTA DE CLIENTES ====================
class AdminClientesViewPage extends ConsumerStatefulWidget {
  final String negocioID;

  const AdminClientesViewPage({super.key, required this.negocioID});

  @override
  ConsumerState<AdminClientesViewPage> createState() =>
      _AdminClientesViewPageState();
}

class _AdminClientesViewPageState extends ConsumerState<AdminClientesViewPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Cargar clientes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientsProvider.notifier).fetchClients(widget.negocioID);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Client> _filterClients(List<Client> clients) {
    if (_searchQuery.isEmpty) return clients;

    return clients.where((client) {
      final fullName = '${client.nombres} ${client.apellidos}'.toLowerCase();
      final identificacion = client.identificacion?.toLowerCase() ?? '';
      final email = client.email?.toLowerCase() ?? '';
      final phone = client.phone?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return fullName.contains(query) ||
          identificacion.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  void _showClientDetail(Client client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ClientDetailBottomSheet(client: client, negocioID: widget.negocioID),
    );
  }

  void _navigateToCreateClient() async {
    await pushWrapped(context, ClientFormPage(negocioID: widget.negocioID));
  }

  /* void _navigateToEditClient(Client client) {
    Navigator.push(
      context,
      CustomWrapperPage(
        builder: (context) =>
            ClientFormPage(negocioID: widget.negocioID, client: client),
      ),
    );
  } */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientsState = ref.watch(clientsProvider);
    final filteredClients = _filterClients(clientsState.clients);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Clientes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(clientsProvider.notifier).fetchClients(widget.negocioID);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Estado de carga o error
          if (clientsState.isLoading && clientsState.clients.isEmpty)
            const Expanded(child: Center(child: AppLoadingIndicator()))
          else if (clientsState.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar clientes',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        clientsState.error!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(clientsProvider.notifier)
                            .fetchClients(widget.negocioID);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredClients.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty
                          ? Icons.people_outline
                          : Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No hay clientes'
                          : 'No se encontraron clientes',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Agrega tu primer cliente'
                          : 'Intenta con otra búsqueda',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Lista de clientes
            Expanded(
              child: AnimationLimiter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(clientsProvider.notifier)
                        .fetchClients(widget.negocioID);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: ClientListItem(
                              client: client,
                              onTap: () => _showClientDetail(client),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateClient,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }
}

// ==================== ITEM DE LISTA ====================
class ClientListItem extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;

  const ClientListItem({super.key, required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  client.nombres.isNotEmpty
                      ? client.nombres[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${client.nombres} ${client.apellidos}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (client.identificacion != null)
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            client.identificacion!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (client.phone != null)
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            client.phone!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== BOTTOM SHEET DE DETALLE ====================
class ClientDetailBottomSheet extends ConsumerWidget {
  final Client client;
  final String negocioID;

  const ClientDetailBottomSheet({
    super.key,
    required this.client,
    required this.negocioID,
  });

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${client.nombres} ${client.apellidos}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Cerrar diálogo
              Navigator.pop(context); // Cerrar bottom sheet

              final success = await ref
                  .read(clientsProvider.notifier)
                  .deleteClient(client);

              if (context.mounted) {
                toastification.show(
                  context: context,
                  type: success
                      ? ToastificationType.success
                      : ToastificationType.error,
                  style: ToastificationStyle.flatColored,
                  title: Text(
                    success ? 'Cliente eliminado' : 'Error al eliminar cliente',
                  ),
                  autoCloseDuration: const Duration(seconds: 3),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    Navigator.pop(context); // Cerrar bottom sheet
    await pushWrapped(context, ClientFormPage(negocioID: negocioID, client: client));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    client.nombres.isNotEmpty
                        ? client.nombres[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${client.nombres} ${client.apellidos}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (client.identificacion != null)
                        Text(
                          client.identificacion!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Detalles
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (client.email != null) ...[
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: client.email!,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                ],
                if (client.phone != null) ...[
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: client.phone!,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                ],
                if (client.identificacion != null) ...[
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Identificación',
                    value: client.identificacion!,
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Acciones
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _navigateToEdit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Padding inferior seguro
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== FORMULARIO DE CREACIÓN/EDICIÓN ====================
class ClientFormPage extends ConsumerStatefulWidget {
  final String negocioID;
  final Client? client; // null = crear, non-null = editar

  const ClientFormPage({super.key, required this.negocioID, this.client});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _identificacionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombresController.text = widget.client!.nombres;
      _apellidosController.text = widget.client!.apellidos;
      _identificacionController.text = widget.client!.identificacion ?? '';
      _emailController.text = widget.client!.email ?? '';
      _phoneController.text = widget.client!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _identificacionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Actualizar
        final updatedClient = widget.client!.copyWith(
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          identificacion: _identificacionController.text.trim().isEmpty
              ? null
              : _identificacionController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        final result = await ref
            .read(clientsProvider.notifier)
            .updateClient(updatedClient);

        if (mounted) {
          if (result != null) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: const Text('Cliente actualizado'),
              autoCloseDuration: const Duration(seconds: 3),
            );
            Navigator.pop(context);
          } else {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text('Error al actualizar cliente'),
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        }
      } else {
        // Crear
        final result = await ref
            .read(clientsProvider.notifier)
            .createClient(
              negocioID: widget.negocioID,
              nombres: _nombresController.text.trim(),
              apellidos: _apellidosController.text.trim(),
              identificacion: _identificacionController.text.trim().isEmpty
                  ? null
                  : _identificacionController.text.trim(),
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            );

        if (mounted) {
          if (result != null) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: const Text('Cliente creado'),
              autoCloseDuration: const Duration(seconds: 3),
            );
            Navigator.pop(context);
          } else {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text('Error al crear cliente'),
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nombres
            TextFormField(
              controller: _nombresController,
              decoration: InputDecoration(
                labelText: 'Nombres *',
                hintText: 'Ingrese los nombres',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los nombres son requeridos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Apellidos
            TextFormField(
              controller: _apellidosController,
              decoration: InputDecoration(
                labelText: 'Apellidos *',
                hintText: 'Ingrese los apellidos',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los apellidos son requeridos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Identificación
            TextFormField(
              controller: _identificacionController,
              decoration: InputDecoration(
                labelText: 'Identificación',
                hintText: 'Cédula, RUC, pasaporte, etc.',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'correo@ejemplo.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Email inválido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                hintText: '0999999999',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Nota
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '* Campos requeridos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón de guardar
            FilledButton(
              onPressed: _isLoading ? null : _saveClient,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: AppLoadingIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEditing ? 'Actualizar Cliente' : 'Crear Cliente',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
