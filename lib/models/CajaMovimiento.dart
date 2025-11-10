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


/** This is an auto generated class representing the CajaMovimiento type in your schema. */
class CajaMovimiento extends amplify_core.Model {
  static const classType = const _CajaMovimientoModelType();
  final String id;
  final String? _cajaID;
  final String? _tipo;
  final String? _origen;
  final double? _monto;
  final String? _negocioID;
  final String? _descripcion;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CajaMovimientoModelIdentifier get modelIdentifier {
      return CajaMovimientoModelIdentifier(
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
  
  String get origen {
    try {
      return _origen!;
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
  
  String? get descripcion {
    return _descripcion;
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
  
  const CajaMovimiento._internal({required this.id, required cajaID, required tipo, required origen, required monto, required negocioID, descripcion, required isDeleted, required createdAt, required updatedAt}): _cajaID = cajaID, _tipo = tipo, _origen = origen, _monto = monto, _negocioID = negocioID, _descripcion = descripcion, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory CajaMovimiento({String? id, required String cajaID, required String tipo, required String origen, required double monto, required String negocioID, String? descripcion, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return CajaMovimiento._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      cajaID: cajaID,
      tipo: tipo,
      origen: origen,
      monto: monto,
      negocioID: negocioID,
      descripcion: descripcion,
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
    return other is CajaMovimiento &&
      id == other.id &&
      _cajaID == other._cajaID &&
      _tipo == other._tipo &&
      _origen == other._origen &&
      _monto == other._monto &&
      _negocioID == other._negocioID &&
      _descripcion == other._descripcion &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("CajaMovimiento {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("cajaID=" + "$_cajaID" + ", ");
    buffer.write("tipo=" + "$_tipo" + ", ");
    buffer.write("origen=" + "$_origen" + ", ");
    buffer.write("monto=" + (_monto != null ? _monto!.toString() : "null") + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("descripcion=" + "$_descripcion" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CajaMovimiento copyWith({String? cajaID, String? tipo, String? origen, double? monto, String? negocioID, String? descripcion, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return CajaMovimiento._internal(
      id: id,
      cajaID: cajaID ?? this.cajaID,
      tipo: tipo ?? this.tipo,
      origen: origen ?? this.origen,
      monto: monto ?? this.monto,
      negocioID: negocioID ?? this.negocioID,
      descripcion: descripcion ?? this.descripcion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  CajaMovimiento copyWithModelFieldValues({
    ModelFieldValue<String>? cajaID,
    ModelFieldValue<String>? tipo,
    ModelFieldValue<String>? origen,
    ModelFieldValue<double>? monto,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<String?>? descripcion,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return CajaMovimiento._internal(
      id: id,
      cajaID: cajaID == null ? this.cajaID : cajaID.value,
      tipo: tipo == null ? this.tipo : tipo.value,
      origen: origen == null ? this.origen : origen.value,
      monto: monto == null ? this.monto : monto.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      descripcion: descripcion == null ? this.descripcion : descripcion.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  CajaMovimiento.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _cajaID = json['cajaID'],
      _tipo = json['tipo'],
      _origen = json['origen'],
      _monto = (json['monto'] as num?)?.toDouble(),
      _negocioID = json['negocioID'],
      _descripcion = json['descripcion'],
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'cajaID': _cajaID, 'tipo': _tipo, 'origen': _origen, 'monto': _monto, 'negocioID': _negocioID, 'descripcion': _descripcion, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'cajaID': _cajaID,
    'tipo': _tipo,
    'origen': _origen,
    'monto': _monto,
    'negocioID': _negocioID,
    'descripcion': _descripcion,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CajaMovimientoModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CajaMovimientoModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final CAJAID = amplify_core.QueryField(fieldName: "cajaID");
  static final TIPO = amplify_core.QueryField(fieldName: "tipo");
  static final ORIGEN = amplify_core.QueryField(fieldName: "origen");
  static final MONTO = amplify_core.QueryField(fieldName: "monto");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final DESCRIPCION = amplify_core.QueryField(fieldName: "descripcion");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CajaMovimiento";
    modelSchemaDefinition.pluralName = "CajaMovimientos";
    
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
      key: CajaMovimiento.CAJAID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.TIPO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.ORIGEN,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.MONTO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.DESCRIPCION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CajaMovimiento.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CajaMovimientoModelType extends amplify_core.ModelType<CajaMovimiento> {
  const _CajaMovimientoModelType();
  
  @override
  CajaMovimiento fromJson(Map<String, dynamic> jsonData) {
    return CajaMovimiento.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CajaMovimiento';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CajaMovimiento] in your schema.
 */
class CajaMovimientoModelIdentifier implements amplify_core.ModelIdentifier<CajaMovimiento> {
  final String id;

  /** Create an instance of CajaMovimientoModelIdentifier using [id] the primary key. */
  const CajaMovimientoModelIdentifier({
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
  String toString() => 'CajaMovimientoModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CajaMovimientoModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}