import 'package:compaexpress/models/ModelProvider.dart';
import 'package:compaexpress/providers/clients_provider.dart';
import 'package:compaexpress/widget/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searchfield/searchfield.dart';

class ClientSelector extends ConsumerStatefulWidget {
  final String negocioID;
  final Client? initialClient;
  final ValueChanged<Client?> onClientSelected;
  final String? hintText;
  final bool enabled;

  const ClientSelector({
    super.key,
    required this.negocioID,
    required this.onClientSelected,
    this.initialClient,
    this.hintText,
    this.enabled = true,
  });

  @override
  ConsumerState<ClientSelector> createState() => _ClientSelectorState();
}

class _ClientSelectorState extends ConsumerState<ClientSelector> {
  final TextEditingController _searchController = TextEditingController();
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.initialClient;
    if (_selectedClient != null) {
      _searchController.text =
          '${_selectedClient!.nombres} ${_selectedClient!.apellidos}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateClientDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateClientDialog(
        negocioID: widget.negocioID,
        onClientCreated: (client) {
          setState(() {
            _selectedClient = client;
            _searchController.text = '${client.nombres} ${client.apellidos}';
          });
          widget.onClientSelected(client);
          // Recargar lista de clientes
          ref.read(clientsProvider.notifier).fetchClients(widget.negocioID);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientsState = ref.watch(clientsProvider);

    // Filtrar clientes por negocio
    final clients = clientsState.clients
        .where((c) => c.negocioID == widget.negocioID)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SearchField<Client>(
                controller: _searchController,
                enabled: widget.enabled,
                hint: widget.hintText ?? 'Buscar cliente...',
                searchStyle: theme.textTheme.bodyMedium,
                suggestionStyle: theme.textTheme.bodyMedium,
                searchInputDecoration: InputDecoration(
                  hintText: widget.hintText ?? 'Buscar cliente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxSuggestionsInViewPort: 6,
                itemHeight: 72,
                onSuggestionTap: (suggestion) {
                  setState(() {
                    _selectedClient = suggestion.item;
                  });
                  widget.onClientSelected(suggestion.item);
                },
                suggestions: clients
                    .map(
                      (client) => SearchFieldListItem<Client>(
                        '${client.nombres} ${client.apellidos}',
                        item: client,
                        child: Container(
                          height: 72,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${client.nombres} ${client.apellidos}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (client.identificacion != null)
                                Text(
                                  'ID: ${client.identificacion}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (client.phone != null || client.email != null)
                                Text(
                                  [
                                    if (client.phone != null) client.phone,
                                    if (client.email != null) client.email,
                                  ].join(' • '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: widget.enabled ? _showCreateClientDialog : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
        if (clientsState.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        if (clientsState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              clientsState.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class CreateClientDialog extends ConsumerStatefulWidget {
  final String negocioID;
  final ValueChanged<Client> onClientCreated;

  const CreateClientDialog({
    super.key,
    required this.negocioID,
    required this.onClientCreated,
  });

  @override
  ConsumerState<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends ConsumerState<CreateClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _identificacionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _identificacionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    final client = await ref
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

    setState(() => _isCreating = false);

    if (client != null && mounted) {
      widget.onClientCreated(client);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Nuevo Cliente',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nombresController,
                        decoration: InputDecoration(
                          labelText: 'Nombres *',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo requerido';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apellidosController,
                        decoration: InputDecoration(
                          labelText: 'Apellidos *',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo requerido';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _identificacionController,
                        decoration: InputDecoration(
                          labelText: 'Identificación',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              !value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isCreating
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _isCreating ? null : _createClient,
                            child: _isCreating
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: AppLoadingIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text('Crear Cliente'),
                          ),
                        ],
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
