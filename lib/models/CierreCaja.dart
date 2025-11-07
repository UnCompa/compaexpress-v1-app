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


/** This is an auto generated class representing the CierreCaja type in your schema. */
class CierreCaja extends amplify_core.Model {
  static const classType = const _CierreCajaModelType();
  final String id;
  final String? _cajaID;
  final String? _negocioID;
  final double? _saldoFinal;
  final double? _diferencia;
  final String? _observaciones;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CierreCajaModelIdentifier get modelIdentifier {
      return CierreCajaModelIdentifier(
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
  
  double get saldoFinal {
    try {
      return _saldoFinal!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get diferencia {
    try {
      return _diferencia!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get observaciones {
    return _observaciones;
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
  
  const CierreCaja._internal({required this.id, required cajaID, required negocioID, required saldoFinal, required diferencia, observaciones, required isDeleted, required createdAt, required updatedAt}): _cajaID = cajaID, _negocioID = negocioID, _saldoFinal = saldoFinal, _diferencia = diferencia, _observaciones = observaciones, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory CierreCaja({String? id, required String cajaID, required String negocioID, required double saldoFinal, required double diferencia, String? observaciones, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return CierreCaja._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      cajaID: cajaID,
      negocioID: negocioID,
      saldoFinal: saldoFinal,
      diferencia: diferencia,
      observaciones: observaciones,
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
    return other is CierreCaja &&
      id == other.id &&
      _cajaID == other._cajaID &&
      _negocioID == other._negocioID &&
      _saldoFinal == other._saldoFinal &&
      _diferencia == other._diferencia &&
      _observaciones == other._observaciones &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("CierreCaja {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("cajaID=" + "$_cajaID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("saldoFinal=" + (_saldoFinal != null ? _saldoFinal.toString() : "null") + ", ");
    buffer.write("diferencia=" + (_diferencia != null ? _diferencia.toString() : "null") + ", ");
    buffer.write("observaciones=" + "$_observaciones" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CierreCaja copyWith({String? cajaID, String? negocioID, double? saldoFinal, double? diferencia, String? observaciones, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return CierreCaja._internal(
      id: id,
      cajaID: cajaID ?? this.cajaID,
      negocioID: negocioID ?? this.negocioID,
      saldoFinal: saldoFinal ?? this.saldoFinal,
      diferencia: diferencia ?? this.diferencia,
      observaciones: observaciones ?? this.observaciones,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  CierreCaja copyWithModelFieldValues({
    ModelFieldValue<String>? cajaID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<double>? saldoFinal,
    ModelFieldValue<double>? diferencia,
    ModelFieldValue<String?>? observaciones,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return CierreCaja._internal(
      id: id,
      cajaID: cajaID == null ? this.cajaID : cajaID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      saldoFinal: saldoFinal == null ? this.saldoFinal : saldoFinal.value,
      diferencia: diferencia == null ? this.diferencia : diferencia.value,
      observaciones: observaciones == null ? this.observaciones : observaciones.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  CierreCaja.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _cajaID = json['cajaID'],
      _negocioID = json['negocioID'],
      _saldoFinal = (json['saldoFinal'] as num?)?.toDouble(),
      _diferencia = (json['diferencia'] as num?)?.toDouble(),
      _observaciones = json['observaciones'],
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'cajaID': _cajaID, 'negocioID': _negocioID, 'saldoFinal': _saldoFinal, 'diferencia': _diferencia, 'observaciones': _observaciones, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'cajaID': _cajaID,
    'negocioID': _negocioID,
    'saldoFinal': _saldoFinal,
    'diferencia': _diferencia,
    'observaciones': _observaciones,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CierreCajaModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CierreCajaModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CAJAID = amplify_core.QueryField(fieldName: "cajaID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final SALDOFINAL = amplify_core.QueryField(fieldName: "saldoFinal");
  static final DIFERENCIA = amplify_core.QueryField(fieldName: "diferencia");
  static final OBSERVACIONES = amplify_core.QueryField(fieldName: "observaciones");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CierreCaja";
    modelSchemaDefinition.pluralName = "CierreCajas";
    
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
      key: CierreCaja.CAJAID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.SALDOFINAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.DIFERENCIA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.OBSERVACIONES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CierreCaja.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CierreCajaModelType extends amplify_core.ModelType<CierreCaja> {
  const _CierreCajaModelType();
  
  @override
  CierreCaja fromJson(Map<String, dynamic> jsonData) {
    return CierreCaja.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CierreCaja';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CierreCaja] in your schema.
 */
class CierreCajaModelIdentifier implements amplify_core.ModelIdentifier<CierreCaja> {
  final String id;

  /** Create an instance of CierreCajaModelIdentifier using [id] the primary key. */
  const CierreCajaModelIdentifier({
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
  String toString() => 'CierreCajaModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CierreCajaModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}