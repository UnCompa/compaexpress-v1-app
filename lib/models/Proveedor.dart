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


/** This is an auto generated class representing the Proveedor type in your schema. */
class Proveedor extends amplify_core.Model {
  static const classType = const _ProveedorModelType();
  final String id;
  final String? _nombre;
  final String? _direccion;
  final String? _ciudad;
  final String? _pais;
  final int? _tiempoEntrega;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;
  final String? _negocioID;
  final List<Producto>? _productos;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ProveedorModelIdentifier get modelIdentifier {
      return ProveedorModelIdentifier(
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
  
  String get direccion {
    try {
      return _direccion!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get ciudad {
    try {
      return _ciudad!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get pais {
    try {
      return _pais!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get tiempoEntrega {
    try {
      return _tiempoEntrega!;
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
  
  List<Producto>? get productos {
    return _productos;
  }
  
  const Proveedor._internal({required this.id, required nombre, required direccion, required ciudad, required pais, required tiempoEntrega, required isDeleted, required createdAt, required updatedAt, required negocioID, productos}): _nombre = nombre, _direccion = direccion, _ciudad = ciudad, _pais = pais, _tiempoEntrega = tiempoEntrega, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt, _negocioID = negocioID, _productos = productos;
  
  factory Proveedor({String? id, required String nombre, required String direccion, required String ciudad, required String pais, required int tiempoEntrega, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt, required String negocioID, List<Producto>? productos}) {
    return Proveedor._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      nombre: nombre,
      direccion: direccion,
      ciudad: ciudad,
      pais: pais,
      tiempoEntrega: tiempoEntrega,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      negocioID: negocioID,
      productos: productos != null ? List<Producto>.unmodifiable(productos) : productos);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Proveedor &&
      id == other.id &&
      _nombre == other._nombre &&
      _direccion == other._direccion &&
      _ciudad == other._ciudad &&
      _pais == other._pais &&
      _tiempoEntrega == other._tiempoEntrega &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt &&
      _negocioID == other._negocioID &&
      DeepCollectionEquality().equals(_productos, other._productos);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Proveedor {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("nombre=" + "$_nombre" + ", ");
    buffer.write("direccion=" + "$_direccion" + ", ");
    buffer.write("ciudad=" + "$_ciudad" + ", ");
    buffer.write("pais=" + "$_pais" + ", ");
    buffer.write("tiempoEntrega=" + (_tiempoEntrega != null ? _tiempoEntrega.toString() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null") + ", ");
    buffer.write("negocioID=" + "$_negocioID");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Proveedor copyWith({String? nombre, String? direccion, String? ciudad, String? pais, int? tiempoEntrega, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt, String? negocioID, List<Producto>? productos}) {
    return Proveedor._internal(
      id: id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      pais: pais ?? this.pais,
      tiempoEntrega: tiempoEntrega ?? this.tiempoEntrega,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      negocioID: negocioID ?? this.negocioID,
      productos: productos ?? this.productos);
  }
  
  Proveedor copyWithModelFieldValues({
    ModelFieldValue<String>? nombre,
    ModelFieldValue<String>? direccion,
    ModelFieldValue<String>? ciudad,
    ModelFieldValue<String>? pais,
    ModelFieldValue<int>? tiempoEntrega,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<List<Producto>?>? productos
  }) {
    return Proveedor._internal(
      id: id,
      nombre: nombre == null ? this.nombre : nombre.value,
      direccion: direccion == null ? this.direccion : direccion.value,
      ciudad: ciudad == null ? this.ciudad : ciudad.value,
      pais: pais == null ? this.pais : pais.value,
      tiempoEntrega: tiempoEntrega == null ? this.tiempoEntrega : tiempoEntrega.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      productos: productos == null ? this.productos : productos.value
    );
  }
  
  Proveedor.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _nombre = json['nombre'],
      _direccion = json['direccion'],
      _ciudad = json['ciudad'],
      _pais = json['pais'],
      _tiempoEntrega = (json['tiempoEntrega'] as num?)?.toInt(),
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _negocioID = json['negocioID'],
      _productos = json['productos']  is Map
        ? (json['productos']['items'] is List
          ? (json['productos']['items'] as List)
              .where((e) => e != null)
              .map((e) => Producto.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['productos'] is List
          ? (json['productos'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => Producto.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null);
  
  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': _nombre, 'direccion': _direccion, 'ciudad': _ciudad, 'pais': _pais, 'tiempoEntrega': _tiempoEntrega, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'negocioID': _negocioID, 'productos': _productos?.map((Producto? e) => e?.toJson()).toList()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': _nombre,
    'direccion': _direccion,
    'ciudad': _ciudad,
    'pais': _pais,
    'tiempoEntrega': _tiempoEntrega,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
    'negocioID': _negocioID,
    'productos': _productos
  };

  static final amplify_core.QueryModelIdentifier<ProveedorModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ProveedorModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NOMBRE = amplify_core.QueryField(fieldName: "nombre");
  static final DIRECCION = amplify_core.QueryField(fieldName: "direccion");
  static final CIUDAD = amplify_core.QueryField(fieldName: "ciudad");
  static final PAIS = amplify_core.QueryField(fieldName: "pais");
  static final TIEMPOENTREGA = amplify_core.QueryField(fieldName: "tiempoEntrega");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final PRODUCTOS = amplify_core.QueryField(
    fieldName: "productos",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Producto'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Proveedor";
    modelSchemaDefinition.pluralName = "Proveedors";
    
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
      amplify_core.ModelIndex(fields: const ["negocioID", "nombre"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.NOMBRE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.DIRECCION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.CIUDAD,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.PAIS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.TIEMPOENTREGA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Proveedor.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Proveedor.PRODUCTOS,
      isRequired: false,
      ofModelName: 'Producto',
      associatedKey: Producto.PROVEEDORID
    ));
  });
}

class _ProveedorModelType extends amplify_core.ModelType<Proveedor> {
  const _ProveedorModelType();
  
  @override
  Proveedor fromJson(Map<String, dynamic> jsonData) {
    return Proveedor.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Proveedor';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Proveedor] in your schema.
 */
class ProveedorModelIdentifier implements amplify_core.ModelIdentifier<Proveedor> {
  final String id;

  /** Create an instance of ProveedorModelIdentifier using [id] the primary key. */
  const ProveedorModelIdentifier({
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
  String toString() => 'ProveedorModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ProveedorModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}