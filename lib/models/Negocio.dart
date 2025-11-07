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


/** This is an auto generated class representing the Negocio type in your schema. */
class Negocio extends amplify_core.Model {
  static const classType = const _NegocioModelType();
  final String id;
  final String? _nombre;
  final String? _representate;
  final String? _ruc;
  final String? _telefono;
  final int? _duration;
  final String? _logo;
  final String? _correoElectronico;
  final String? _pais;
  final String? _provincia;
  final String? _ciudad;
  final int? _movilAccess;
  final int? _pcAccess;
  final String? _direccion;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  NegocioModelIdentifier get modelIdentifier {
      return NegocioModelIdentifier(
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
  
  String? get representate {
    return _representate;
  }
  
  String get ruc {
    try {
      return _ruc!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get telefono {
    return _telefono;
  }
  
  int? get duration {
    return _duration;
  }
  
  String? get logo {
    return _logo;
  }
  
  String? get correoElectronico {
    return _correoElectronico;
  }
  
  String? get pais {
    return _pais;
  }
  
  String? get provincia {
    return _provincia;
  }
  
  String? get ciudad {
    return _ciudad;
  }
  
  int? get movilAccess {
    return _movilAccess;
  }
  
  int? get pcAccess {
    return _pcAccess;
  }
  
  String? get direccion {
    return _direccion;
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
  
  const Negocio._internal({required this.id, required nombre, representate, required ruc, telefono, duration, logo, correoElectronico, pais, provincia, ciudad, movilAccess, pcAccess, direccion, required isDeleted, required createdAt, required updatedAt}): _nombre = nombre, _representate = representate, _ruc = ruc, _telefono = telefono, _duration = duration, _logo = logo, _correoElectronico = correoElectronico, _pais = pais, _provincia = provincia, _ciudad = ciudad, _movilAccess = movilAccess, _pcAccess = pcAccess, _direccion = direccion, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Negocio({String? id, required String nombre, String? representate, required String ruc, String? telefono, int? duration, String? logo, String? correoElectronico, String? pais, String? provincia, String? ciudad, int? movilAccess, int? pcAccess, String? direccion, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Negocio._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      nombre: nombre,
      representate: representate,
      ruc: ruc,
      telefono: telefono,
      duration: duration,
      logo: logo,
      correoElectronico: correoElectronico,
      pais: pais,
      provincia: provincia,
      ciudad: ciudad,
      movilAccess: movilAccess,
      pcAccess: pcAccess,
      direccion: direccion,
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
    return other is Negocio &&
      id == other.id &&
      _nombre == other._nombre &&
      _representate == other._representate &&
      _ruc == other._ruc &&
      _telefono == other._telefono &&
      _duration == other._duration &&
      _logo == other._logo &&
      _correoElectronico == other._correoElectronico &&
      _pais == other._pais &&
      _provincia == other._provincia &&
      _ciudad == other._ciudad &&
      _movilAccess == other._movilAccess &&
      _pcAccess == other._pcAccess &&
      _direccion == other._direccion &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Negocio {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("nombre=" + "$_nombre" + ", ");
    buffer.write("representate=" + "$_representate" + ", ");
    buffer.write("ruc=" + "$_ruc" + ", ");
    buffer.write("telefono=" + "$_telefono" + ", ");
    buffer.write("duration=" + (_duration != null ? _duration.toString() : "null") + ", ");
    buffer.write("logo=" + "$_logo" + ", ");
    buffer.write("correoElectronico=" + "$_correoElectronico" + ", ");
    buffer.write("pais=" + "$_pais" + ", ");
    buffer.write("provincia=" + "$_provincia" + ", ");
    buffer.write("ciudad=" + "$_ciudad" + ", ");
    buffer.write("movilAccess=" + (_movilAccess != null ? _movilAccess.toString() : "null") + ", ");
    buffer.write("pcAccess=" + (_pcAccess != null ? _pcAccess.toString() : "null") + ", ");
    buffer.write("direccion=" + "$_direccion" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Negocio copyWith({String? nombre, String? representate, String? ruc, String? telefono, int? duration, String? logo, String? correoElectronico, String? pais, String? provincia, String? ciudad, int? movilAccess, int? pcAccess, String? direccion, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Negocio._internal(
      id: id,
      nombre: nombre ?? this.nombre,
      representate: representate ?? this.representate,
      ruc: ruc ?? this.ruc,
      telefono: telefono ?? this.telefono,
      duration: duration ?? this.duration,
      logo: logo ?? this.logo,
      correoElectronico: correoElectronico ?? this.correoElectronico,
      pais: pais ?? this.pais,
      provincia: provincia ?? this.provincia,
      ciudad: ciudad ?? this.ciudad,
      movilAccess: movilAccess ?? this.movilAccess,
      pcAccess: pcAccess ?? this.pcAccess,
      direccion: direccion ?? this.direccion,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Negocio copyWithModelFieldValues({
    ModelFieldValue<String>? nombre,
    ModelFieldValue<String?>? representate,
    ModelFieldValue<String>? ruc,
    ModelFieldValue<String?>? telefono,
    ModelFieldValue<int?>? duration,
    ModelFieldValue<String?>? logo,
    ModelFieldValue<String?>? correoElectronico,
    ModelFieldValue<String?>? pais,
    ModelFieldValue<String?>? provincia,
    ModelFieldValue<String?>? ciudad,
    ModelFieldValue<int?>? movilAccess,
    ModelFieldValue<int?>? pcAccess,
    ModelFieldValue<String?>? direccion,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Negocio._internal(
      id: id,
      nombre: nombre == null ? this.nombre : nombre.value,
      representate: representate == null ? this.representate : representate.value,
      ruc: ruc == null ? this.ruc : ruc.value,
      telefono: telefono == null ? this.telefono : telefono.value,
      duration: duration == null ? this.duration : duration.value,
      logo: logo == null ? this.logo : logo.value,
      correoElectronico: correoElectronico == null ? this.correoElectronico : correoElectronico.value,
      pais: pais == null ? this.pais : pais.value,
      provincia: provincia == null ? this.provincia : provincia.value,
      ciudad: ciudad == null ? this.ciudad : ciudad.value,
      movilAccess: movilAccess == null ? this.movilAccess : movilAccess.value,
      pcAccess: pcAccess == null ? this.pcAccess : pcAccess.value,
      direccion: direccion == null ? this.direccion : direccion.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Negocio.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _nombre = json['nombre'],
      _representate = json['representate'],
      _ruc = json['ruc'],
      _telefono = json['telefono'],
      _duration = (json['duration'] as num?)?.toInt(),
      _logo = json['logo'],
      _correoElectronico = json['correoElectronico'],
      _pais = json['pais'],
      _provincia = json['provincia'],
      _ciudad = json['ciudad'],
      _movilAccess = (json['movilAccess'] as num?)?.toInt(),
      _pcAccess = (json['pcAccess'] as num?)?.toInt(),
      _direccion = json['direccion'],
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': _nombre, 'representate': _representate, 'ruc': _ruc, 'telefono': _telefono, 'duration': _duration, 'logo': _logo, 'correoElectronico': _correoElectronico, 'pais': _pais, 'provincia': _provincia, 'ciudad': _ciudad, 'movilAccess': _movilAccess, 'pcAccess': _pcAccess, 'direccion': _direccion, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': _nombre,
    'representate': _representate,
    'ruc': _ruc,
    'telefono': _telefono,
    'duration': _duration,
    'logo': _logo,
    'correoElectronico': _correoElectronico,
    'pais': _pais,
    'provincia': _provincia,
    'ciudad': _ciudad,
    'movilAccess': _movilAccess,
    'pcAccess': _pcAccess,
    'direccion': _direccion,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<NegocioModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<NegocioModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NOMBRE = amplify_core.QueryField(fieldName: "nombre");
  static final REPRESENTATE = amplify_core.QueryField(fieldName: "representate");
  static final RUC = amplify_core.QueryField(fieldName: "ruc");
  static final TELEFONO = amplify_core.QueryField(fieldName: "telefono");
  static final DURATION = amplify_core.QueryField(fieldName: "duration");
  static final LOGO = amplify_core.QueryField(fieldName: "logo");
  static final CORREOELECTRONICO = amplify_core.QueryField(fieldName: "correoElectronico");
  static final PAIS = amplify_core.QueryField(fieldName: "pais");
  static final PROVINCIA = amplify_core.QueryField(fieldName: "provincia");
  static final CIUDAD = amplify_core.QueryField(fieldName: "ciudad");
  static final MOVILACCESS = amplify_core.QueryField(fieldName: "movilAccess");
  static final PCACCESS = amplify_core.QueryField(fieldName: "pcAccess");
  static final DIRECCION = amplify_core.QueryField(fieldName: "direccion");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Negocio";
    modelSchemaDefinition.pluralName = "Negocios";
    
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
          amplify_core.ModelOperation.UPDATE
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.NOMBRE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.REPRESENTATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.RUC,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.TELEFONO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.DURATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.LOGO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.CORREOELECTRONICO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.PAIS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.PROVINCIA,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.CIUDAD,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.MOVILACCESS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.PCACCESS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.DIRECCION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Negocio.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _NegocioModelType extends amplify_core.ModelType<Negocio> {
  const _NegocioModelType();
  
  @override
  Negocio fromJson(Map<String, dynamic> jsonData) {
    return Negocio.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Negocio';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Negocio] in your schema.
 */
class NegocioModelIdentifier implements amplify_core.ModelIdentifier<Negocio> {
  final String id;

  /** Create an instance of NegocioModelIdentifier using [id] the primary key. */
  const NegocioModelIdentifier({
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
  String toString() => 'NegocioModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is NegocioModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}