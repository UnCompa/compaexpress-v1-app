import 'dart:convert';

import 'package:compaexpress/entities/invoice_item_data.dart';
import 'package:compaexpress/models/Invoice.dart';
import 'package:compaexpress/models/Negocio.dart';
import 'package:compaexpress/utils/get_token.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PdfService {
  static Future<String?> generatePDF(
    List<InvoiceItemData> invoiceItems,
    Invoice invoice,
    Negocio negocio,
  ) async {
    try {
      final invoiceItemsData = invoiceItems
          .map(
            (item) => ({
              'productoNombre': item.producto.nombre,
              'quantity': item.quantity,
              'subtotal': item.subtotal,
              'total': item.total,
            }),
          )
          .toList();

      final lambdaInput = {
        'invoice': {
          'id': invoice.id,
          'invoiceNumber': invoice.invoiceNumber,
          'invoiceDate': invoice.invoiceDate.toString(),
          'invoiceTotal': invoice.invoiceReceivedTotal - invoice.invoiceReturnedTotal,
        },
        'invoiceItems': invoiceItemsData,
        'negocio': {
          'nombre': negocio.nombre,
          'ruc': negocio.ruc,
          'telefono': negocio.telefono,
          'direccion': negocio.direccion,
        },
      };
      final token = await GetToken.getIdTokenSimple();
      if (token == null) {
        print('No se pudo obtener el token');
        return null;
      }
      final lambdaResponse = await http.post(
        Uri.parse(
          'https://hwmfv41ks4.execute-api.us-east-1.amazonaws.com/dev/generate-invoice-pdf',
        ),
        body: Uint8List.fromList(jsonEncode(lambdaInput).codeUnits),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token.raw,
        },
      );
      return jsonDecode(lambdaResponse.body)['pdfUrl'];
    } catch (e) {
      print('Error al generar PDF: $e');
      return null;
    }
  }
}
