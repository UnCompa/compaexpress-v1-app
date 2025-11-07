/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'Auditoria.dart';
import 'Caja.dart';
import 'CajaMoneda.dart';
import 'CajaMovimiento.dart';
import 'Categoria.dart';
import 'CierreCaja.dart';
import 'CierreCajaHistorial.dart';
import 'CompraItem.dart';
import 'CompraProveedor.dart';
import 'HistorialPrecio.dart';
import 'Invoice.dart';
import 'InvoiceItem.dart';
import 'InvoicePayment.dart';
import 'Negocio.dart';
import 'Order.dart';
import 'OrderItem.dart';
import 'OrderPayment.dart';
import 'Producto.dart';
import 'ProductoPrecios.dart';
import 'Proveedor.dart';
import 'SesionDispositivo.dart';

export 'Auditoria.dart';
export 'Caja.dart';
export 'CajaMoneda.dart';
export 'CajaMovimiento.dart';
export 'Categoria.dart';
export 'CierreCaja.dart';
export 'CierreCajaHistorial.dart';
export 'CompraItem.dart';
export 'CompraProveedor.dart';
export 'HistorialPrecio.dart';
export 'Invoice.dart';
export 'InvoiceItem.dart';
export 'InvoicePayment.dart';
export 'Negocio.dart';
export 'Order.dart';
export 'OrderItem.dart';
export 'OrderPayment.dart';
export 'Producto.dart';
export 'ProductoPrecios.dart';
export 'Proveedor.dart';
export 'SesionDispositivo.dart';
export 'TiposPago.dart';

class ModelProvider implements amplify_core.ModelProviderInterface {
  @override
  String version = "576a6ade6e70ce5b456eac3337ad7af9";
  @override
  List<amplify_core.ModelSchema> modelSchemas = [Auditoria.schema, Caja.schema, CajaMoneda.schema, CajaMovimiento.schema, Categoria.schema, CierreCaja.schema, CierreCajaHistorial.schema, CompraItem.schema, CompraProveedor.schema, HistorialPrecio.schema, Invoice.schema, InvoiceItem.schema, InvoicePayment.schema, Negocio.schema, Order.schema, OrderItem.schema, OrderPayment.schema, Producto.schema, ProductoPrecios.schema, Proveedor.schema, SesionDispositivo.schema];
  @override
  List<amplify_core.ModelSchema> customTypeSchemas = [];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;
  
  amplify_core.ModelType getModelTypeByModelName(String modelName) {
    switch(modelName) {
      case "Auditoria":
        return Auditoria.classType;
      case "Caja":
        return Caja.classType;
      case "CajaMoneda":
        return CajaMoneda.classType;
      case "CajaMovimiento":
        return CajaMovimiento.classType;
      case "Categoria":
        return Categoria.classType;
      case "CierreCaja":
        return CierreCaja.classType;
      case "CierreCajaHistorial":
        return CierreCajaHistorial.classType;
      case "CompraItem":
        return CompraItem.classType;
      case "CompraProveedor":
        return CompraProveedor.classType;
      case "HistorialPrecio":
        return HistorialPrecio.classType;
      case "Invoice":
        return Invoice.classType;
      case "InvoiceItem":
        return InvoiceItem.classType;
      case "InvoicePayment":
        return InvoicePayment.classType;
      case "Negocio":
        return Negocio.classType;
      case "Order":
        return Order.classType;
      case "OrderItem":
        return OrderItem.classType;
      case "OrderPayment":
        return OrderPayment.classType;
      case "Producto":
        return Producto.classType;
      case "ProductoPrecios":
        return ProductoPrecios.classType;
      case "Proveedor":
        return Proveedor.classType;
      case "SesionDispositivo":
        return SesionDispositivo.classType;
      default:
        throw Exception("Failed to find model in model provider for model name: " + modelName);
    }
  }
}


class ModelFieldValue<T> {
  const ModelFieldValue.value(this.value);

  final T value;
}
