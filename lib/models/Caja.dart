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


/** This is an auto generated class representing the Caja type in your schema. */
class Caja extends amplify_core.Model {
  static const classType = const _CajaModelType();
  final String id;
  final String? _negocioID;
  final bool? _isDeleted;
  final double? _saldoInicial;
  final double? _saldoTransferencias;
  final double? _saldoTarjetas;
  final double? _saldoOtros;
  final bool? _isActive;
  final List<CajaMoneda>? _cajaMonedas;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CajaModelIdentifier get modelIdentifier {
      return CajaModelIdentifier(
        id: id
      );
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
  
  double get saldoInicial {
    try {
      return _saldoInicial!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double? get saldoTransferencias {
    return _saldoTransferencias;
  }
  
  double? get saldoTarjetas {
    return _saldoTarjetas;
  }
  
  double? get saldoOtros {
    return _saldoOtros;
  }
  
  bool get isActive {
    try {
      return _isActive!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<CajaMoneda>? get cajaMonedas {
    return _cajaMonedas;
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
  
  const Caja._internal({required this.id, required negocioID, required isDeleted, required saldoInicial, saldoTransferencias, saldoTarjetas, saldoOtros, required isActive, cajaMonedas, required createdAt, required updatedAt}): _negocioID = negocioID, _isDeleted = isDeleted, _saldoInicial = saldoInicial, _saldoTransferencias = saldoTransferencias, _saldoTarjetas = saldoTarjetas, _saldoOtros = saldoOtros, _isActive = isActive, _cajaMonedas = cajaMonedas, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Caja({String? id, required String negocioID, required bool isDeleted, required double saldoInicial, double? saldoTransferencias, double? saldoTarjetas, double? saldoOtros, required bool isActive, List<CajaMoneda>? cajaMonedas, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Caja._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      negocioID: negocioID,
      isDeleted: isDeleted,
      saldoInicial: saldoInicial,
      saldoTransferencias: saldoTransferencias,
      saldoTarjetas: saldoTarjetas,
      saldoOtros: saldoOtros,
      isActive: isActive,
      cajaMonedas: cajaMonedas != null ? List<CajaMoneda>.unmodifiable(cajaMonedas) : cajaMonedas,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Caja &&
      id == other.id &&
      _negocioID == other._negocioID &&
      _isDeleted == other._isDeleted &&
      _saldoInicial == other._saldoInicial &&
      _saldoTransferencias == other._saldoTransferencias &&
      _saldoTarjetas == other._saldoTarjetas &&
      _saldoOtros == other._saldoOtros &&
      _isActive == other._isActive &&
      DeepCollectionEquality().equals(_cajaMonedas, other._cajaMonedas) &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Caja {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("saldoInicial=" + (_saldoInicial != null ? _saldoInicial.toString() : "null") + ", ");
    buffer.write("saldoTransferencias=" + (_saldoTransferencias != null ? _saldoTransferencias.toString() : "null") + ", ");
    buffer.write("saldoTarjetas=" + (_saldoTarjetas != null ? _saldoTarjetas.toString() : "null") + ", ");
    buffer.write("saldoOtros=" + (_saldoOtros != null ? _saldoOtros.toString() : "null") + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Caja copyWith({String? negocioID, bool? isDeleted, double? saldoInicial, double? saldoTransferencias, double? saldoTarjetas, double? saldoOtros, bool? isActive, List<CajaMoneda>? cajaMonedas, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Caja._internal(
      id: id,
      negocioID: negocioID ?? this.negocioID,
      isDeleted: isDeleted ?? this.isDeleted,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      saldoTransferencias: saldoTransferencias ?? this.saldoTransferencias,
      saldoTarjetas: saldoTarjetas ?? this.saldoTarjetas,
      saldoOtros: saldoOtros ?? this.saldoOtros,
      isActive: isActive ?? this.isActive,
      cajaMonedas: cajaMonedas ?? this.cajaMonedas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Caja copyWithModelFieldValues({
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<double>? saldoInicial,
    ModelFieldValue<double?>? saldoTransferencias,
    ModelFieldValue<double?>? saldoTarjetas,
    ModelFieldValue<double?>? saldoOtros,
    ModelFieldValue<bool>? isActive,
    ModelFieldValue<List<CajaMoneda>?>? cajaMonedas,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Caja._internal(
      id: id,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      saldoInicial: saldoInicial == null ? this.saldoInicial : saldoInicial.value,
      saldoTransferencias: saldoTransferencias == null ? this.saldoTransferencias : saldoTransferencias.value,
      saldoTarjetas: saldoTarjetas == null ? this.saldoTarjetas : saldoTarjetas.value,
      saldoOtros: saldoOtros == null ? this.saldoOtros : saldoOtros.value,
      isActive: isActive == null ? this.isActive : isActive.value,
      cajaMonedas: cajaMonedas == null ? this.cajaMonedas : cajaMonedas.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Caja.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _negocioID = json['negocioID'],
      _isDeleted = json['isDeleted'],
      _saldoInicial = (json['saldoInicial'] as num?)?.toDouble(),
      _saldoTransferencias = (json['saldoTransferencias'] as num?)?.toDouble(),
      _saldoTarjetas = (json['saldoTarjetas'] as num?)?.toDouble(),
      _saldoOtros = (json['saldoOtros'] as num?)?.toDouble(),
      _isActive = json['isActive'],
      _cajaMonedas = json['cajaMonedas']  is Map
        ? (json['cajaMonedas']['items'] is List
          ? (json['cajaMonedas']['items'] as List)
              .where((e) => e != null)
              .map((e) => CajaMoneda.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['cajaMonedas'] is List
          ? (json['cajaMonedas'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => CajaMoneda.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'negocioID': _negocioID, 'isDeleted': _isDeleted, 'saldoInicial': _saldoInicial, 'saldoTransferencias': _saldoTransferencias, 'saldoTarjetas': _saldoTarjetas, 'saldoOtros': _saldoOtros, 'isActive': _isActive, 'cajaMonedas': _cajaMonedas?.map((CajaMoneda? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'negocioID': _negocioID,
    'isDeleted': _isDeleted,
    'saldoInicial': _saldoInicial,
    'saldoTransferencias': _saldoTransferencias,
    'saldoTarjetas': _saldoTarjetas,
    'saldoOtros': _saldoOtros,
    'isActive': _isActive,
    'cajaMonedas': _cajaMonedas,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CajaModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CajaModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final SALDOINICIAL = amplify_core.QueryField(fieldName: "saldoInicial");
  static final SALDOTRANSFERENCIAS = amplify_core.QueryField(fieldName: "saldoTransferencias");
  static final SALDOTARJETAS = amplify_core.QueryField(fieldName: "saldoTarjetas");
  static final SALDOOTROS = amplify_core.QueryField(fieldName: "saldoOtros");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static final CAJAMONEDAS = amplify_core.QueryField(
    fieldName: "cajaMonedas",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'CajaMoneda'));
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Caja";
    modelSchemaDefinition.pluralName = "Cajas";
    
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
          amplify_core.ModelOperation.UPDATE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["negocioID"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.SALDOINICIAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.SALDOTRANSFERENCIAS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.SALDOTARJETAS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.SALDOOTROS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.ISACTIVE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Caja.CAJAMONEDAS,
      isRequired: false,
      ofModelName: 'CajaMoneda',
      associatedKey: CajaMoneda.CAJAID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Caja.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CajaModelType extends amplify_core.ModelType<Caja> {
  const _CajaModelType();
  
  @override
  Caja fromJson(Map<String, dynamic> jsonData) {
    return Caja.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Caja';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Caja] in your schema.
 */
class CajaModelIdentifier implements amplify_core.ModelIdentifier<Caja> {
  final String id;

  /** Create an instance of CajaModelIdentifier using [id] the primary key. */
  const CajaModelIdentifier({
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
  String toString() => 'CajaModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CajaModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}