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


/** This is an auto generated class representing the ProductoPrecios type in your schema. */
class ProductoPrecios extends amplify_core.Model {
  static const classType = const _ProductoPreciosModelType();
  final String id;
  final String? _nombre;
  final double? _precio;
  final int? _quantity;
  final String? _productoID;
  final String? _negocioID;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ProductoPreciosModelIdentifier get modelIdentifier {
      return ProductoPreciosModelIdentifier(
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
  
  double get precio {
    try {
      return _precio!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get quantity {
    try {
      return _quantity!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get productoID {
    try {
      return _productoID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  const ProductoPrecios._internal({required this.id, required nombre, required precio, required quantity, required productoID, required negocioID, required isDeleted, required createdAt, required updatedAt}): _nombre = nombre, _precio = precio, _quantity = quantity, _productoID = productoID, _negocioID = negocioID, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ProductoPrecios({String? id, required String nombre, required double precio, required int quantity, required String productoID, required String negocioID, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return ProductoPrecios._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      nombre: nombre,
      precio: precio,
      quantity: quantity,
      productoID: productoID,
      negocioID: negocioID,
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
    return other is ProductoPrecios &&
      id == other.id &&
      _nombre == other._nombre &&
      _precio == other._precio &&
      _quantity == other._quantity &&
      _productoID == other._productoID &&
      _negocioID == other._negocioID &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ProductoPrecios {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("nombre=" + "$_nombre" + ", ");
    buffer.write("precio=" + (_precio != null ? _precio.toString() : "null") + ", ");
    buffer.write("quantity=" + (_quantity != null ? _quantity.toString() : "null") + ", ");
    buffer.write("productoID=" + "$_productoID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ProductoPrecios copyWith({String? nombre, double? precio, int? quantity, String? productoID, String? negocioID, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return ProductoPrecios._internal(
      id: id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      quantity: quantity ?? this.quantity,
      productoID: productoID ?? this.productoID,
      negocioID: negocioID ?? this.negocioID,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  ProductoPrecios copyWithModelFieldValues({
    ModelFieldValue<String>? nombre,
    ModelFieldValue<double>? precio,
    ModelFieldValue<int>? quantity,
    ModelFieldValue<String>? productoID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return ProductoPrecios._internal(
      id: id,
      nombre: nombre == null ? this.nombre : nombre.value,
      precio: precio == null ? this.precio : precio.value,
      quantity: quantity == null ? this.quantity : quantity.value,
      productoID: productoID == null ? this.productoID : productoID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  ProductoPrecios.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _nombre = json['nombre'],
      _precio = (json['precio'] as num?)?.toDouble(),
      _quantity = (json['quantity'] as num?)?.toInt(),
      _productoID = json['productoID'],
      _negocioID = json['negocioID'],
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': _nombre, 'precio': _precio, 'quantity': _quantity, 'productoID': _productoID, 'negocioID': _negocioID, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': _nombre,
    'precio': _precio,
    'quantity': _quantity,
    'productoID': _productoID,
    'negocioID': _negocioID,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ProductoPreciosModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ProductoPreciosModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NOMBRE = amplify_core.QueryField(fieldName: "nombre");
  static final PRECIO = amplify_core.QueryField(fieldName: "precio");
  static final QUANTITY = amplify_core.QueryField(fieldName: "quantity");
  static final PRODUCTOID = amplify_core.QueryField(fieldName: "productoID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ProductoPrecios";
    modelSchemaDefinition.pluralName = "ProductoPrecios";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "admin" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.CREATE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["productoID"], name: "byProducto"),
      amplify_core.ModelIndex(fields: const ["negocioID", "nombre"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.NOMBRE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.PRECIO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.QUANTITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.PRODUCTOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ProductoPrecios.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ProductoPreciosModelType extends amplify_core.ModelType<ProductoPrecios> {
  const _ProductoPreciosModelType();
  
  @override
  ProductoPrecios fromJson(Map<String, dynamic> jsonData) {
    return ProductoPrecios.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ProductoPrecios';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ProductoPrecios] in your schema.
 */
class ProductoPreciosModelIdentifier implements amplify_core.ModelIdentifier<ProductoPrecios> {
  final String id;

  /** Create an instance of ProductoPreciosModelIdentifier using [id] the primary key. */
  const ProductoPreciosModelIdentifier({
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
  String toString() => 'ProductoPreciosModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ProductoPreciosModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}