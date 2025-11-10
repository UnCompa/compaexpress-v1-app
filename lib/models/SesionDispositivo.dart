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


/** This is an auto generated class representing the SesionDispositivo type in your schema. */
class SesionDispositivo extends amplify_core.Model {
  static const classType = const _SesionDispositivoModelType();
  final String id;
  final String? _negocioId;
  final String? _userId;
  final String? _deviceId;
  final String? _deviceType;
  final String? _deviceInfo;
  final bool? _isActive;
  final amplify_core.TemporalDateTime? _lastActivity;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SesionDispositivoModelIdentifier get modelIdentifier {
      return SesionDispositivoModelIdentifier(
        id: id
      );
  }
  
  String get negocioId {
    try {
      return _negocioId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  String get deviceId {
    try {
      return _deviceId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get deviceType {
    try {
      return _deviceType!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get deviceInfo {
    return _deviceInfo;
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
  
  amplify_core.TemporalDateTime get lastActivity {
    try {
      return _lastActivity!;
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
  
  const SesionDispositivo._internal({required this.id, required negocioId, required userId, required deviceId, required deviceType, deviceInfo, required isActive, required lastActivity, required createdAt, required updatedAt}): _negocioId = negocioId, _userId = userId, _deviceId = deviceId, _deviceType = deviceType, _deviceInfo = deviceInfo, _isActive = isActive, _lastActivity = lastActivity, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory SesionDispositivo({String? id, required String negocioId, required String userId, required String deviceId, required String deviceType, String? deviceInfo, required bool isActive, required amplify_core.TemporalDateTime lastActivity, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return SesionDispositivo._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      negocioId: negocioId,
      userId: userId,
      deviceId: deviceId,
      deviceType: deviceType,
      deviceInfo: deviceInfo,
      isActive: isActive,
      lastActivity: lastActivity,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SesionDispositivo &&
      id == other.id &&
      _negocioId == other._negocioId &&
      _userId == other._userId &&
      _deviceId == other._deviceId &&
      _deviceType == other._deviceType &&
      _deviceInfo == other._deviceInfo &&
      _isActive == other._isActive &&
      _lastActivity == other._lastActivity &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("SesionDispositivo {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("negocioId=" + "$_negocioId" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("deviceId=" + "$_deviceId" + ", ");
    buffer.write("deviceType=" + "$_deviceType" + ", ");
    buffer.write("deviceInfo=" + "$_deviceInfo" + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("lastActivity=" + (_lastActivity != null ? _lastActivity!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SesionDispositivo copyWith({String? negocioId, String? userId, String? deviceId, String? deviceType, String? deviceInfo, bool? isActive, amplify_core.TemporalDateTime? lastActivity, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return SesionDispositivo._internal(
      id: id,
      negocioId: negocioId ?? this.negocioId,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceType: deviceType ?? this.deviceType,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      isActive: isActive ?? this.isActive,
      lastActivity: lastActivity ?? this.lastActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  SesionDispositivo copyWithModelFieldValues({
    ModelFieldValue<String>? negocioId,
    ModelFieldValue<String>? userId,
    ModelFieldValue<String>? deviceId,
    ModelFieldValue<String>? deviceType,
    ModelFieldValue<String?>? deviceInfo,
    ModelFieldValue<bool>? isActive,
    ModelFieldValue<amplify_core.TemporalDateTime>? lastActivity,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return SesionDispositivo._internal(
      id: id,
      negocioId: negocioId == null ? this.negocioId : negocioId.value,
      userId: userId == null ? this.userId : userId.value,
      deviceId: deviceId == null ? this.deviceId : deviceId.value,
      deviceType: deviceType == null ? this.deviceType : deviceType.value,
      deviceInfo: deviceInfo == null ? this.deviceInfo : deviceInfo.value,
      isActive: isActive == null ? this.isActive : isActive.value,
      lastActivity: lastActivity == null ? this.lastActivity : lastActivity.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  SesionDispositivo.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _negocioId = json['negocioId'],
      _userId = json['userId'],
      _deviceId = json['deviceId'],
      _deviceType = json['deviceType'],
      _deviceInfo = json['deviceInfo'],
      _isActive = json['isActive'],
      _lastActivity = json['lastActivity'] != null ? amplify_core.TemporalDateTime.fromString(json['lastActivity']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'negocioId': _negocioId, 'userId': _userId, 'deviceId': _deviceId, 'deviceType': _deviceType, 'deviceInfo': _deviceInfo, 'isActive': _isActive, 'lastActivity': _lastActivity?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'negocioId': _negocioId,
    'userId': _userId,
    'deviceId': _deviceId,
    'deviceType': _deviceType,
    'deviceInfo': _deviceInfo,
    'isActive': _isActive,
    'lastActivity': _lastActivity,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SesionDispositivoModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SesionDispositivoModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioId");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final DEVICEID = amplify_core.QueryField(fieldName: "deviceId");
  static final DEVICETYPE = amplify_core.QueryField(fieldName: "deviceType");
  static final DEVICEINFO = amplify_core.QueryField(fieldName: "deviceInfo");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static final LASTACTIVITY = amplify_core.QueryField(fieldName: "lastActivity");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SesionDispositivo";
    modelSchemaDefinition.pluralName = "SesionDispositivos";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "superadmin" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "admin" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.DELETE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["negocioId"], name: "byNegocio")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.DEVICEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.DEVICETYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.DEVICEINFO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.ISACTIVE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.LASTACTIVITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SesionDispositivo.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SesionDispositivoModelType extends amplify_core.ModelType<SesionDispositivo> {
  const _SesionDispositivoModelType();
  
  @override
  SesionDispositivo fromJson(Map<String, dynamic> jsonData) {
    return SesionDispositivo.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'SesionDispositivo';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SesionDispositivo] in your schema.
 */
class SesionDispositivoModelIdentifier implements amplify_core.ModelIdentifier<SesionDispositivo> {
  final String id;

  /** Create an instance of SesionDispositivoModelIdentifier using [id] the primary key. */
  const SesionDispositivoModelIdentifier({
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
  String toString() => 'SesionDispositivoModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SesionDispositivoModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}