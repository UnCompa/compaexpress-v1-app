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


/** This is an auto generated class representing the CajaMoneda type in your schema. */
class CajaMoneda extends amplify_core.Model {
  static const classType = const _CajaMonedaModelType();
  final String id;
  final String? _cajaID;
  final String? _negocioID;
  final String? _moneda;
  final double? _denominacion;
  final double? _monto;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CajaMonedaModelIdentifier get modelIdentifier {
      return CajaMonedaModelIdentifier(
        id: id
      );
  }
  
  String get cajaID {
    try {
      return _cajaID!;
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
  
  String get moneda {
    try {
      return _moneda!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get denominacion {
    try {
      return _denominacion!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get monto {
    try {
      return _monto!;
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
  
  const CajaMoneda._internal({required this.id, required cajaID, required negocioID, required moneda, required denominacion, required monto, required isDeleted, required createdAt, required updatedAt}): _cajaID = cajaID, _negocioID = negocioID, _moneda = moneda, _denominacion = denominacion, _monto = monto, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory CajaMoneda({String? id, required String cajaID, required String negocioID, required String moneda, required double denominacion, required double monto, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return CajaMoneda._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      cajaID: cajaID,
      negocioID: negocioID,
      moneda: moneda,
      denominacion: denominacion,
      monto: monto,
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
    return other is CajaMoneda &&
      id == other.id &&
      _cajaID == other._cajaID &&
      _negocioID == other._negocioID &&
      _moneda == other._moneda &&
      _denominacion == other._denominacion &&
      _monto == other._monto &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("CajaMoneda {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("cajaID=" + "$_cajaID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("moneda=" + "$_moneda" + ", ");
    buffer.write("denominacion=" + (_denominacion != null ? _denominacion.toString() : "null") + ", ");
    buffer.write("monto=" + (_monto != null ? _monto.toString() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CajaMoneda copyWith({String? cajaID, String? negocioID, String? moneda, double? denominacion, double? monto, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return CajaMoneda._internal(
      id: id,
      cajaID: cajaID ?? this.cajaID,
      negocioID: negocioID ?? this.negocioID,
      moneda: moneda ?? this.moneda,
      denominacion: denominacion ?? this.denominacion,
      monto: monto ?? this.monto,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  CajaMoneda copyWithModelFieldValues({
    ModelFieldValue<String>? cajaID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<String>? moneda,
    ModelFieldValue<double>? denominacion,
    ModelFieldValue<double>? monto,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return CajaMoneda._internal(
      id: id,
      cajaID: cajaID == null ? this.cajaID : cajaID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      moneda: moneda == null ? this.moneda : moneda.value,
      denominacion: denominacion == null ? this.denominacion : denominacion.value,
      monto: monto == null ? this.monto : monto.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  CajaMoneda.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _cajaID = json['cajaID'],
      _negocioID = json['negocioID'],
      _moneda = json['moneda'],
      _denominacion = (json['denominacion'] as num?)?.toDouble(),
      _monto = (json['monto'] as num?)?.toDouble(),
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'cajaID': _cajaID, 'negocioID': _negocioID, 'moneda': _moneda, 'denominacion': _denominacion, 'monto': _monto, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'cajaID': _cajaID,
    'negocioID': _negocioID,
    'moneda': _moneda,
    'denominacion': _denominacion,
    'monto': _monto,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CajaMonedaModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CajaMonedaModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CAJAID = amplify_core.QueryField(fieldName: "cajaID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final MONEDA = amplify_core.QueryField(fieldName: "moneda");
  static final DENOMINACION = amplify_core.QueryField(fieldName: "denominacion");
  static final MONTO = amplify_core.QueryField(fieldName: "monto");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CajaMoneda";
    modelSchemaDefinition.pluralName = "CajaMonedas";
    
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
      amplify_core.ModelIndex(fields: const ["cajaID"], name: "byCaja"),
      amplify_core.ModelIndex(fields: const ["negocioID"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.CAJAID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.MONEDA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.DENOMINACION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.MONTO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMoneda.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CajaMonedaModelType extends amplify_core.ModelType<CajaMoneda> {
  const _CajaMonedaModelType();
  
  @override
  CajaMoneda fromJson(Map<String, dynamic> jsonData) {
    return CajaMoneda.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CajaMoneda';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CajaMoneda] in your schema.
 */
class CajaMonedaModelIdentifier implements amplify_core.ModelIdentifier<CajaMoneda> {
  final String id;

  /** Create an instance of CajaMonedaModelIdentifier using [id] the primary key. */
  const CajaMonedaModelIdentifier({
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
  String toString() => 'CajaMonedaModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CajaMonedaModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}