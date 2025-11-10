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

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Producto type in your schema. */
class Producto extends amplify_core.Model {
  static const classType = const _ProductoModelType();
  final String id;
  final String? _nombre;
  final String? _descripcion;
  final int? _stock;
  final String? _barCode;
  final List<String>? _productoImages;
  final String? _negocioID;
  final String? _categoriaID;
  final String? _proveedorID;
  final double? _precioCompra;
  final String? _tipo;
  final bool? _favorito;
  final List<ProductoPrecios>? _productoPrecios;
  final String? _estado;
  final List<InvoiceItem>? _invoiceItems;
  final List<OrderItem>? _orderItems;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ProductoModelIdentifier get modelIdentifier {
      return ProductoModelIdentifier(
        id: id
      );
  }
  
  String get nombre {
    try {
      return _nombre!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get descripcion {
    try {
      return _descripcion!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get stock {
    try {
      return _stock!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get barCode {
    try {
      return _barCode!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String>? get productoImages {
    return _productoImages;
  }
  
  String get negocioID {
    try {
      return _negocioID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get categoriaID {
    try {
      return _categoriaID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get proveedorID {
    try {
      return _proveedorID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get precioCompra {
    try {
      return _precioCompra!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get tipo {
    try {
      return _tipo!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get favorito {
    try {
      return _favorito!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<ProductoPrecios>? get productoPrecios {
    return _productoPrecios;
  }
  
  String? get estado {
    return _estado;
  }
  
  List<InvoiceItem>? get invoiceItems {
    return _invoiceItems;
  }
  
  List<OrderItem>? get orderItems {
    return _orderItems;
  }
  
  bool get isDeleted {
    try {
      return _isDeleted!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get updatedAt {
    try {
      return _updatedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const Producto._internal({required this.id, required nombre, required descripcion, required stock, required barCode, productoImages, required negocioID, required categoriaID, required proveedorID, required precioCompra, required tipo, required favorito, productoPrecios, estado, invoiceItems, orderItems, required isDeleted, required createdAt, required updatedAt}): _nombre = nombre, _descripcion = descripcion, _stock = stock, _barCode = barCode, _productoImages = productoImages, _negocioID = negocioID, _categoriaID = categoriaID, _proveedorID = proveedorID, _precioCompra = precioCompra, _tipo = tipo, _favorito = favorito, _productoPrecios = productoPrecios, _estado = estado, _invoiceItems = invoiceItems, _orderItems = orderItems, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Producto({String? id, required String nombre, required String descripcion, required int stock, required String barCode, List<String>? productoImages, required String negocioID, required String categoriaID, required String proveedorID, required double precioCompra, required String tipo, required bool favorito, List<ProductoPrecios>? productoPrecios, String? estado, List<InvoiceItem>? invoiceItems, List<OrderItem>? orderItems, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Producto._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      nombre: nombre,
      descripcion: descripcion,
      stock: stock,
      barCode: barCode,
      productoImages: productoImages != null ? List<String>.unmodifiable(productoImages) : productoImages,
      negocioID: negocioID,
      categoriaID: categoriaID,
      proveedorID: proveedorID,
      precioCompra: precioCompra,
      tipo: tipo,
      favorito: favorito,
      productoPrecios: productoPrecios != null ? List<ProductoPrecios>.unmodifiable(productoPrecios) : productoPrecios,
      estado: estado,
      invoiceItems: invoiceItems != null ? List<InvoiceItem>.unmodifiable(invoiceItems) : invoiceItems,
      orderItems: orderItems != null ? List<OrderItem>.unmodifiable(orderItems) : orderItems,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Producto &&
      id == other.id &&
      _nombre == other._nombre &&
      _descripcion == other._descripcion &&
      _stock == other._stock &&
      _barCode == other._barCode &&
      DeepCollectionEquality().equals(_productoImages, other._productoImages) &&
      _negocioID == other._negocioID &&
      _categoriaID == other._categoriaID &&
      _proveedorID == other._proveedorID &&
      _precioCompra == other._precioCompra &&
      _tipo == other._tipo &&
      _favorito == other._favorito &&
      DeepCollectionEquality().equals(_productoPrecios, other._productoPrecios) &&
      _estado == other._estado &&
      DeepCollectionEquality().equals(_invoiceItems, other._invoiceItems) &&
      DeepCollectionEquality().equals(_orderItems, other._orderItems) &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Producto {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("nombre=" + "$_nombre" + ", ");
    buffer.write("descripcion=" + "$_descripcion" + ", ");
    buffer.write("stock=" + (_stock != null ? _stock!.toString() : "null") + ", ");
    buffer.write("barCode=" + "$_barCode" + ", ");
    buffer.write("productoImages=" + (_productoImages != null ? _productoImages!.toString() : "null") + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("categoriaID=" + "$_categoriaID" + ", ");
    buffer.write("proveedorID=" + "$_proveedorID" + ", ");
    buffer.write("precioCompra=" + (_precioCompra != null ? _precioCompra!.toString() : "null") + ", ");
    buffer.write("tipo=" + "$_tipo" + ", ");
    buffer.write("favorito=" + (_favorito != null ? _favorito!.toString() : "null") + ", ");
    buffer.write("estado=" + "$_estado" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Producto copyWith({String? nombre, String? descripcion, int? stock, String? barCode, List<String>? productoImages, String? negocioID, String? categoriaID, String? proveedorID, double? precioCompra, String? tipo, bool? favorito, List<ProductoPrecios>? productoPrecios, String? estado, List<InvoiceItem>? invoiceItems, List<OrderItem>? orderItems, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Producto._internal(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      stock: stock ?? this.stock,
      barCode: barCode ?? this.barCode,
      productoImages: productoImages ?? this.productoImages,
      negocioID: negocioID ?? this.negocioID,
      categoriaID: categoriaID ?? this.categoriaID,
      proveedorID: proveedorID ?? this.proveedorID,
      precioCompra: precioCompra ?? this.precioCompra,
      tipo: tipo ?? this.tipo,
      favorito: favorito ?? this.favorito,
      productoPrecios: productoPrecios ?? this.productoPrecios,
      estado: estado ?? this.estado,
      invoiceItems: invoiceItems ?? this.invoiceItems,
      orderItems: orderItems ?? this.orderItems,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Producto copyWithModelFieldValues({
    ModelFieldValue<String>? nombre,
    ModelFieldValue<String>? descripcion,
    ModelFieldValue<int>? stock,
    ModelFieldValue<String>? barCode,
    ModelFieldValue<List<String>?>? productoImages,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<String>? categoriaID,
    ModelFieldValue<String>? proveedorID,
    ModelFieldValue<double>? precioCompra,
    ModelFieldValue<String>? tipo,
    ModelFieldValue<bool>? favorito,
    ModelFieldValue<List<ProductoPrecios>?>? productoPrecios,
    ModelFieldValue<String?>? estado,
    ModelFieldValue<List<InvoiceItem>?>? invoiceItems,
    ModelFieldValue<List<OrderItem>?>? orderItems,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Producto._internal(
      id: id,
      nombre: nombre == null ? this.nombre : nombre.value,
      descripcion: descripcion == null ? this.descripcion : descripcion.value,
      stock: stock == null ? this.stock : stock.value,
      barCode: barCode == null ? this.barCode : barCode.value,
      productoImages: productoImages == null ? this.productoImages : productoImages.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      categoriaID: categoriaID == null ? this.categoriaID : categoriaID.value,
      proveedorID: proveedorID == null ? this.proveedorID : proveedorID.value,
      precioCompra: precioCompra == null ? this.precioCompra : precioCompra.value,
      tipo: tipo == null ? this.tipo : tipo.value,
      favorito: favorito == null ? this.favorito : favorito.value,
      productoPrecios: productoPrecios == null ? this.productoPrecios : productoPrecios.value,
      estado: estado == null ? this.estado : estado.value,
      invoiceItems: invoiceItems == null ? this.invoiceItems : invoiceItems.value,
      orderItems: orderItems == null ? this.orderItems : orderItems.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Producto.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _nombre = json['nombre'],
      _descripcion = json['descripcion'],
      _stock = (json['stock'] as num?)?.toInt(),
      _barCode = json['barCode'],
      _productoImages = json['productoImages']?.cast<String>(),
      _negocioID = json['negocioID'],
      _categoriaID = json['categoriaID'],
      _proveedorID = json['proveedorID'],
      _precioCompra = (json['precioCompra'] as num?)?.toDouble(),
      _tipo = json['tipo'],
      _favorito = json['favorito'],
      _productoPrecios = json['productoPrecios']  is Map
        ? (json['productoPrecios']['items'] is List
          ? (json['productoPrecios']['items'] as List)
              .where((e) => e != null)
              .map((e) => ProductoPrecios.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['productoPrecios'] is List
          ? (json['productoPrecios'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => ProductoPrecios.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _estado = json['estado'],
      _invoiceItems = json['invoiceItems']  is Map
        ? (json['invoiceItems']['items'] is List
          ? (json['invoiceItems']['items'] as List)
              .where((e) => e != null)
              .map((e) => InvoiceItem.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['invoiceItems'] is List
          ? (json['invoiceItems'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => InvoiceItem.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _orderItems = json['orderItems']  is Map
        ? (json['orderItems']['items'] is List
          ? (json['orderItems']['items'] as List)
              .where((e) => e != null)
              .map((e) => OrderItem.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['orderItems'] is List
          ? (json['orderItems'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => OrderItem.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': _nombre, 'descripcion': _descripcion, 'stock': _stock, 'barCode': _barCode, 'productoImages': _productoImages, 'negocioID': _negocioID, 'categoriaID': _categoriaID, 'proveedorID': _proveedorID, 'precioCompra': _precioCompra, 'tipo': _tipo, 'favorito': _favorito, 'productoPrecios': _productoPrecios?.map((ProductoPrecios? e) => e?.toJson()).toList(), 'estado': _estado, 'invoiceItems': _invoiceItems?.map((InvoiceItem? e) => e?.toJson()).toList(), 'orderItems': _orderItems?.map((OrderItem? e) => e?.toJson()).toList(), 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': _nombre,
    'descripcion': _descripcion,
    'stock': _stock,
    'barCode': _barCode,
    'productoImages': _productoImages,
    'negocioID': _negocioID,
    'categoriaID': _categoriaID,
    'proveedorID': _proveedorID,
    'precioCompra': _precioCompra,
    'tipo': _tipo,
    'favorito': _favorito,
    'productoPrecios': _productoPrecios,
    'estado': _estado,
    'invoiceItems': _invoiceItems,
    'orderItems': _orderItems,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ProductoModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ProductoModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NOMBRE = amplify_core.QueryField(fieldName: "nombre");
  static final DESCRIPCION = amplify_core.QueryField(fieldName: "descripcion");
  static final STOCK = amplify_core.QueryField(fieldName: "stock");
  static final BARCODE = amplify_core.QueryField(fieldName: "barCode");
  static final PRODUCTOIMAGES = amplify_core.QueryField(fieldName: "productoImages");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final CATEGORIAID = amplify_core.QueryField(fieldName: "categoriaID");
  static final PROVEEDORID = amplify_core.QueryField(fieldName: "proveedorID");
  static final PRECIOCOMPRA = amplify_core.QueryField(fieldName: "precioCompra");
  static final TIPO = amplify_core.QueryField(fieldName: "tipo");
  static final FAVORITO = amplify_core.QueryField(fieldName: "favorito");
  static final PRODUCTOPRECIOS = amplify_core.QueryField(
    fieldName: "productoPrecios",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'ProductoPrecios'));
  static final ESTADO = amplify_core.QueryField(fieldName: "estado");
  static final INVOICEITEMS = amplify_core.QueryField(
    fieldName: "invoiceItems",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'InvoiceItem'));
  static final ORDERITEMS = amplify_core.QueryField(
    fieldName: "orderItems",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'OrderItem'));
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Producto";
    modelSchemaDefinition.pluralName = "Productos";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "admin", "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["negocioID", "nombre"], name: "byNegocio"),
      amplify_core.ModelIndex(fields: const ["categoriaID"], name: "byCategoria"),
      amplify_core.ModelIndex(fields: const ["proveedorID"], name: "byProveedor")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.NOMBRE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.DESCRIPCION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.STOCK,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.BARCODE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.PRODUCTOIMAGES,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.CATEGORIAID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.PROVEEDORID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.PRECIOCOMPRA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.TIPO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.FAVORITO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Producto.PRODUCTOPRECIOS,
      isRequired: false,
      ofModelName: 'ProductoPrecios',
      associatedKey: ProductoPrecios.PRODUCTOID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.ESTADO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Producto.INVOICEITEMS,
      isRequired: false,
      ofModelName: 'InvoiceItem',
      associatedKey: InvoiceItem.PRODUCTOID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Producto.ORDERITEMS,
      isRequired: false,
      ofModelName: 'OrderItem',
      associatedKey: OrderItem.PRODUCTOID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Producto.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ProductoModelType extends amplify_core.ModelType<Producto> {
  const _ProductoModelType();
  
  @override
  Producto fromJson(Map<String, dynamic> jsonData) {
    return Producto.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Producto';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Producto] in your schema.
 */
class ProductoModelIdentifier implements amplify_core.ModelIdentifier<Producto> {
  final String id;

  /** Create an instance of ProductoModelIdentifier using [id] the primary key. */
  const ProductoModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'ProductoModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ProductoModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}