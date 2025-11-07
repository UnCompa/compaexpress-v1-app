import 'package:compaexpress/providers/invoice_design_provider.dart';
import 'package:compaexpress/utils/invoice_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceDesignSelector extends ConsumerWidget {
  const InvoiceDesignSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDesign = ref.watch(invoiceDesignProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.print, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Diseño de Factura',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona el estilo de impresión para tus facturas',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...InvoiceDesign.values.map((design) {
              final isSelected = currentDesign == design;
              return _DesignOptionTile(
                design: design,
                isSelected: isSelected,
                onTap: () =>
                    ref.read(invoiceDesignProvider.notifier).setDesign(design),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DesignOptionTile extends StatelessWidget {
  final InvoiceDesign design;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesignOptionTile({
    required this.design,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getDesignIcon() {
    switch (design) {
      case InvoiceDesign.classic:
        return Icons.description;
      case InvoiceDesign.compact:
        return Icons.compress;
      case InvoiceDesign.detailed:
        return Icons.article;
      case InvoiceDesign.modern:
        return Icons.auto_awesome;
      case InvoiceDesign.simple:
        return Icons.receipt;
    }
  }

  Color _getDesignColor() {
    switch (design) {
      case InvoiceDesign.classic:
        return Colors.blue;
      case InvoiceDesign.compact:
        return Colors.green;
      case InvoiceDesign.detailed:
        return Colors.purple;
      case InvoiceDesign.modern:
        return Colors.orange;
      case InvoiceDesign.simple:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDesignColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getDesignIcon(), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      design.nombre,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                    Text(
                      design.descripcion,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 28)
              else
                Icon(Icons.circle_outlined, color: Colors.grey[400], size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog para seleccionar diseño de factura
class InvoiceDesignDialog extends ConsumerWidget {
  const InvoiceDesignDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const InvoiceDesignDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diseño de Factura',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const InvoiceDesignSelector(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón compacto para abrir el selector
class InvoiceDesignButton extends ConsumerWidget {
  final bool compact;

  const InvoiceDesignButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDesign = ref.watch(invoiceDesignProvider);

    if (compact) {
      return IconButton.outlined(
        icon: const Icon(Icons.print),
        tooltip: 'Diseño: ${currentDesign.nombre}',
        onPressed: () => InvoiceDesignDialog.show(context),
      );
    }

    return OutlinedButton.icon(
      icon: const Icon(Icons.print),
      label: Text(
        'Diseño: ${currentDesign.nombre}',
        style: GoogleFonts.poppins(fontSize: 14),
      ),
      onPressed: () => InvoiceDesignDialog.show(context),
    );
  }
}
