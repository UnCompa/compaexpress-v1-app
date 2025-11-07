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


/** This is an auto generated class representing the CierreCajaHistorial type in your schema. */
class CierreCajaHistorial extends amplify_core.Model {
  static const classType = const _CierreCajaHistorialModelType();
  final String id;
  final String? _cierreCajaID;
  final amplify_core.TemporalDateTime? _fechaCierre;
  final String? _usuarioID;
  final String? _negocioID;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CierreCajaHistorialModelIdentifier get modelIdentifier {
      return CierreCajaHistorialModelIdentifier(
        id: id
      );
  }
  
  String get cierreCajaID {
    try {
      return _cierreCajaID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get fechaCierre {
    try {
      return _fechaCierre!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get usuarioID {
    try {
      return _usuarioID!;
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
  
  const CierreCajaHistorial._internal({required this.id, required cierreCajaID, required fechaCierre, required usuarioID, required negocioID, required isDeleted, required createdAt, required updatedAt}): _cierreCajaID = cierreCajaID, _fechaCierre = fechaCierre, _usuarioID = usuarioID, _negocioID = negocioID, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory CierreCajaHistorial({String? id, required String cierreCajaID, required amplify_core.TemporalDateTime fechaCierre, required String usuarioID, required String negocioID, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return CierreCajaHistorial._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      cierreCajaID: cierreCajaID,
      fechaCierre: fechaCierre,
      usuarioID: usuarioID,
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
    return other is CierreCajaHistorial &&
      id == other.id &&
      _cierreCajaID == other._cierreCajaID &&
      _fechaCierre == other._fechaCierre &&
      _usuarioID == other._usuarioID &&
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
    
    buffer.write("CierreCajaHistorial {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("cierreCajaID=" + "$_cierreCajaID" + ", ");
    buffer.write("fechaCierre=" + (_fechaCierre != null ? _fechaCierre.format() : "null") + ", ");
    buffer.write("usuarioID=" + "$_usuarioID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CierreCajaHistorial copyWith({String? cierreCajaID, amplify_core.TemporalDateTime? fechaCierre, String? usuarioID, String? negocioID, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return CierreCajaHistorial._internal(
      id: id,
      cierreCajaID: cierreCajaID ?? this.cierreCajaID,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      usuarioID: usuarioID ?? this.usuarioID,
      negocioID: negocioID ?? this.negocioID,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  CierreCajaHistorial copyWithModelFieldValues({
    ModelFieldValue<String>? cierreCajaID,
    ModelFieldValue<amplify_core.TemporalDateTime>? fechaCierre,
    ModelFieldValue<String>? usuarioID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return CierreCajaHistorial._internal(
      id: id,
      cierreCajaID: cierreCajaID == null ? this.cierreCajaID : cierreCajaID.value,
      fechaCierre: fechaCierre == null ? this.fechaCierre : fechaCierre.value,
      usuarioID: usuarioID == null ? this.usuarioID : usuarioID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  CierreCajaHistorial.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _cierreCajaID = json['cierreCajaID'],
      _fechaCierre = json['fechaCierre'] != null ? amplify_core.TemporalDateTime.fromString(json['fechaCierre']) : null,
      _usuarioID = json['usuarioID'],
      _negocioID = json['negocioID'],
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'cierreCajaID': _cierreCajaID, 'fechaCierre': _fechaCierre?.format(), 'usuarioID': _usuarioID, 'negocioID': _negocioID, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'cierreCajaID': _cierreCajaID,
    'fechaCierre': _fechaCierre,
    'usuarioID': _usuarioID,
    'negocioID': _negocioID,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CierreCajaHistorialModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CierreCajaHistorialModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CIERRECAJAID = amplify_core.QueryField(fieldName: "cierreCajaID");
  static final FECHACIERRE = amplify_core.QueryField(fieldName: "fechaCierre");
  static final USUARIOID = amplify_core.QueryField(fieldName: "usuarioID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CierreCajaHistorial";
    modelSchemaDefinition.pluralName = "CierreCajaHistorials";
    
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
      amplify_core.ModelIndex(fields: const ["cierreCajaID"], name: "byCierreCaja"),
      amplify_core.ModelIndex(fields: const ["negocioID"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.CIERRECAJAID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.FECHACIERRE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.USUARIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCajaHistorial.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CierreCajaHistorialModelType extends amplify_core.ModelType<CierreCajaHistorial> {
  const _CierreCajaHistorialModelType();
  
  @override
  CierreCajaHistorial fromJson(Map<String, dynamic> jsonData) {
    return CierreCajaHistorial.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CierreCajaHistorial';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CierreCajaHistorial] in your schema.
 */
class CierreCajaHistorialModelIdentifier implements amplify_core.ModelIdentifier<CierreCajaHistorial> {
  final String id;

  /** Create an instance of CierreCajaHistorialModelIdentifier using [id] the primary key. */
  const CierreCajaHistorialModelIdentifier({
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
  String toString() => 'CierreCajaHistorialModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CierreCajaHistorialModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}