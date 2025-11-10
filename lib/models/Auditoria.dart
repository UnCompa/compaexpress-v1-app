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


/** This is an auto generated class representing the Auditoria type in your schema. */
class Auditoria extends amplify_core.Model {
  static const classType = const _AuditoriaModelType();
  final String id;
  final String? _userId;
  final String? _grupo;
  final String? _accion;
  final String? _entidad;
  final String? _entidadId;
  final String? _descripcion;
  final amplify_core.TemporalDateTime? _fecha;
  final String? _negocioID;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  AuditoriaModelIdentifier get modelIdentifier {
      return AuditoriaModelIdentifier(
        id: id
      );
  }
  
  String get userId {
    try {
      return _userId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get grupo {
    try {
      return _grupo!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get accion {
    try {
      return _accion!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get entidad {
    try {
      return _entidad!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get entidadId {
    return _entidadId;
  }
  
  String? get descripcion {
    return _descripcion;
  }
  
  amplify_core.TemporalDateTime get fecha {
    try {
      return _fecha!;
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
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Auditoria._internal({required this.id, required userId, required grupo, required accion, required entidad, entidadId, descripcion, required fecha, required negocioID, createdAt, updatedAt}): _userId = userId, _grupo = grupo, _accion = accion, _entidad = entidad, _entidadId = entidadId, _descripcion = descripcion, _fecha = fecha, _negocioID = negocioID, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Auditoria({String? id, required String userId, required String grupo, required String accion, required String entidad, String? entidadId, String? descripcion, required amplify_core.TemporalDateTime fecha, required String negocioID}) {
    return Auditoria._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      grupo: grupo,
      accion: accion,
      entidad: entidad,
      entidadId: entidadId,
      descripcion: descripcion,
      fecha: fecha,
      negocioID: negocioID);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Auditoria &&
      id == other.id &&
      _userId == other._userId &&
      _grupo == other._grupo &&
      _accion == other._accion &&
      _entidad == other._entidad &&
      _entidadId == other._entidadId &&
      _descripcion == other._descripcion &&
      _fecha == other._fecha &&
      _negocioID == other._negocioID;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Auditoria {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("grupo=" + "$_grupo" + ", ");
    buffer.write("accion=" + "$_accion" + ", ");
    buffer.write("entidad=" + "$_entidad" + ", ");
    buffer.write("entidadId=" + "$_entidadId" + ", ");
    buffer.write("descripcion=" + "$_descripcion" + ", ");
    buffer.write("fecha=" + (_fecha != null ? _fecha!.format() : "null") + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Auditoria copyWith({String? userId, String? grupo, String? accion, String? entidad, String? entidadId, String? descripcion, amplify_core.TemporalDateTime? fecha, String? negocioID}) {
    return Auditoria._internal(
      id: id,
      userId: userId ?? this.userId,
      grupo: grupo ?? this.grupo,
      accion: accion ?? this.accion,
      entidad: entidad ?? this.entidad,
      entidadId: entidadId ?? this.entidadId,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      negocioID: negocioID ?? this.negocioID);
  }
  
  Auditoria copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<String>? grupo,
    ModelFieldValue<String>? accion,
    ModelFieldValue<String>? entidad,
    ModelFieldValue<String?>? entidadId,
    ModelFieldValue<String?>? descripcion,
    ModelFieldValue<amplify_core.TemporalDateTime>? fecha,
    ModelFieldValue<String>? negocioID
  }) {
    return Auditoria._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      grupo: grupo == null ? this.grupo : grupo.value,
      accion: accion == null ? this.accion : accion.value,
      entidad: entidad == null ? this.entidad : entidad.value,
      entidadId: entidadId == null ? this.entidadId : entidadId.value,
      descripcion: descripcion == null ? this.descripcion : descripcion.value,
      fecha: fecha == null ? this.fecha : fecha.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value
    );
  }
  
  Auditoria.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _grupo = json['grupo'],
      _accion = json['accion'],
      _entidad = json['entidad'],
      _entidadId = json['entidadId'],
      _descripcion = json['descripcion'],
      _fecha = json['fecha'] != null ? amplify_core.TemporalDateTime.fromString(json['fecha']) : null,
      _negocioID = json['negocioID'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'grupo': _grupo, 'accion': _accion, 'entidad': _entidad, 'entidadId': _entidadId, 'descripcion': _descripcion, 'fecha': _fecha?.format(), 'negocioID': _negocioID, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'grupo': _grupo,
    'accion': _accion,
    'entidad': _entidad,
    'entidadId': _entidadId,
    'descripcion': _descripcion,
    'fecha': _fecha,
    'negocioID': _negocioID,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<AuditoriaModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<AuditoriaModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final GRUPO = amplify_core.QueryField(fieldName: "grupo");
  static final ACCION = amplify_core.QueryField(fieldName: "accion");
  static final ENTIDAD = amplify_core.QueryField(fieldName: "entidad");
  static final ENTIDADID = amplify_core.QueryField(fieldName: "entidadId");
  static final DESCRIPCION = amplify_core.QueryField(fieldName: "descripcion");
  static final FECHA = amplify_core.QueryField(fieldName: "fecha");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Auditoria";
    modelSchemaDefinition.pluralName = "Auditorias";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "superadmin", "admin" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["negocioID"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.GRUPO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.ACCION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.ENTIDAD,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.ENTIDADID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.DESCRIPCION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.FECHA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Auditoria.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _AuditoriaModelType extends amplify_core.ModelType<Auditoria> {
  const _AuditoriaModelType();
  
  @override
  Auditoria fromJson(Map<String, dynamic> jsonData) {
    return Auditoria.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Auditoria';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Auditoria] in your schema.
 */
class AuditoriaModelIdentifier implements amplify_core.ModelIdentifier<Auditoria> {
  final String id;

  /** Create an instance of AuditoriaModelIdentifier using [id] the primary key. */
  const AuditoriaModelIdentifier({
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
  String toString() => 'AuditoriaModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is AuditoriaModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}