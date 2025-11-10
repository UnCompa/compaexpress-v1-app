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


/** This is an auto generated class representing the CompraProveedor type in your schema. */
class CompraProveedor extends amplify_core.Model {
  static const classType = const _CompraProveedorModelType();
  final String id;
  final String? _proveedorID;
  final String? _negocioID;
  final amplify_core.TemporalDateTime? _fechaCompra;
  final double? _totalCompra;
  final bool? _isDeleted;
  final List<CompraItem>? _productos;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CompraProveedorModelIdentifier get modelIdentifier {
      return CompraProveedorModelIdentifier(
        id: id
      );
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
  
  amplify_core.TemporalDateTime get fechaCompra {
    try {
      return _fechaCompra!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get totalCompra {
    try {
      return _totalCompra!;
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
  
  List<CompraItem>? get productos {
    return _productos;
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
  
  const CompraProveedor._internal({required this.id, required proveedorID, required negocioID, required fechaCompra, required totalCompra, required isDeleted, productos, required createdAt, required updatedAt}): _proveedorID = proveedorID, _negocioID = negocioID, _fechaCompra = fechaCompra, _totalCompra = totalCompra, _isDeleted = isDeleted, _productos = productos, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory CompraProveedor({String? id, required String proveedorID, required String negocioID, required amplify_core.TemporalDateTime fechaCompra, required double totalCompra, required bool isDeleted, List<CompraItem>? productos, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return CompraProveedor._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      proveedorID: proveedorID,
      negocioID: negocioID,
      fechaCompra: fechaCompra,
      totalCompra: totalCompra,
      isDeleted: isDeleted,
      productos: productos != null ? List<CompraItem>.unmodifiable(productos) : productos,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompraProveedor &&
      id == other.id &&
      _proveedorID == other._proveedorID &&
      _negocioID == other._negocioID &&
      _fechaCompra == other._fechaCompra &&
      _totalCompra == other._totalCompra &&
      _isDeleted == other._isDeleted &&
      DeepCollectionEquality().equals(_productos, other._productos) &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("CompraProveedor {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("proveedorID=" + "$_proveedorID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("fechaCompra=" + (_fechaCompra != null ? _fechaCompra!.format() : "null") + ", ");
    buffer.write("totalCompra=" + (_totalCompra != null ? _totalCompra!.toString() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CompraProveedor copyWith({String? proveedorID, String? negocioID, amplify_core.TemporalDateTime? fechaCompra, double? totalCompra, bool? isDeleted, List<CompraItem>? productos, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return CompraProveedor._internal(
      id: id,
      proveedorID: proveedorID ?? this.proveedorID,
      negocioID: negocioID ?? this.negocioID,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      totalCompra: totalCompra ?? this.totalCompra,
      isDeleted: isDeleted ?? this.isDeleted,
      productos: productos ?? this.productos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  CompraProveedor copyWithModelFieldValues({
    ModelFieldValue<String>? proveedorID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<amplify_core.TemporalDateTime>? fechaCompra,
    ModelFieldValue<double>? totalCompra,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<List<CompraItem>?>? productos,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return CompraProveedor._internal(
      id: id,
      proveedorID: proveedorID == null ? this.proveedorID : proveedorID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      fechaCompra: fechaCompra == null ? this.fechaCompra : fechaCompra.value,
      totalCompra: totalCompra == null ? this.totalCompra : totalCompra.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      productos: productos == null ? this.productos : productos.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  CompraProveedor.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _proveedorID = json['proveedorID'],
      _negocioID = json['negocioID'],
      _fechaCompra = json['fechaCompra'] != null ? amplify_core.TemporalDateTime.fromString(json['fechaCompra']) : null,
      _totalCompra = (json['totalCompra'] as num?)?.toDouble(),
      _isDeleted = json['isDeleted'],
      _productos = json['productos']  is Map
        ? (json['productos']['items'] is List
          ? (json['productos']['items'] as List)
              .where((e) => e != null)
              .map((e) => CompraItem.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['productos'] is List
          ? (json['productos'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => CompraItem.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'proveedorID': _proveedorID, 'negocioID': _negocioID, 'fechaCompra': _fechaCompra?.format(), 'totalCompra': _totalCompra, 'isDeleted': _isDeleted, 'productos': _productos?.map((CompraItem? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'proveedorID': _proveedorID,
    'negocioID': _negocioID,
    'fechaCompra': _fechaCompra,
    'totalCompra': _totalCompra,
    'isDeleted': _isDeleted,
    'productos': _productos,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CompraProveedorModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CompraProveedorModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final PROVEEDORID = amplify_core.QueryField(fieldName: "proveedorID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final FECHACOMPRA = amplify_core.QueryField(fieldName: "fechaCompra");
  static final TOTALCOMPRA = amplify_core.QueryField(fieldName: "totalCompra");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final PRODUCTOS = amplify_core.QueryField(
    fieldName: "productos",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'CompraItem'));
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CompraProveedor";
    modelSchemaDefinition.pluralName = "CompraProveedors";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "admin", "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["proveedorID"], name: "byProveedor"),
      amplify_core.ModelIndex(fields: const ["negocioID"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.PROVEEDORID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.FECHACOMPRA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.TOTALCOMPRA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: CompraProveedor.PRODUCTOS,
      isRequired: false,
      ofModelName: 'CompraItem',
      associatedKey: CompraItem.COMPRAID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraProveedor.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CompraProveedorModelType extends amplify_core.ModelType<CompraProveedor> {
  const _CompraProveedorModelType();
  
  @override
  CompraProveedor fromJson(Map<String, dynamic> jsonData) {
    return CompraProveedor.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CompraProveedor';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CompraProveedor] in your schema.
 */
class CompraProveedorModelIdentifier implements amplify_core.ModelIdentifier<CompraProveedor> {
  final String id;

  /** Create an instance of CompraProveedorModelIdentifier using [id] the primary key. */
  const CompraProveedorModelIdentifier({
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
  String toString() => 'CompraProveedorModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CompraProveedorModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}