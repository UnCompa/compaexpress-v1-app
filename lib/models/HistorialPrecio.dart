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


/** This is an auto generated class representing the HistorialPrecio type in your schema. */
class HistorialPrecio extends amplify_core.Model {
  static const classType = const _HistorialPrecioModelType();
  final String id;
  final String? _productoID;
  final String? _tipo;
  final double? _precio;
  final amplify_core.TemporalDateTime? _fechaInicio;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _fechaFin;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  HistorialPrecioModelIdentifier get modelIdentifier {
      return HistorialPrecioModelIdentifier(
        id: id
      );
  }
  
  String get productoID {
    try {
      return _productoID!;
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
  
  double get precio {
    try {
      return _precio!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get fechaInicio {
    try {
      return _fechaInicio!;
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
  
  amplify_core.TemporalDateTime? get fechaFin {
    return _fechaFin;
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
  
  const HistorialPrecio._internal({required this.id, required productoID, required tipo, required precio, required fechaInicio, required isDeleted, fechaFin, required createdAt, required updatedAt}): _productoID = productoID, _tipo = tipo, _precio = precio, _fechaInicio = fechaInicio, _isDeleted = isDeleted, _fechaFin = fechaFin, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory HistorialPrecio({String? id, required String productoID, required String tipo, required double precio, required amplify_core.TemporalDateTime fechaInicio, required bool isDeleted, amplify_core.TemporalDateTime? fechaFin, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return HistorialPrecio._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      productoID: productoID,
      tipo: tipo,
      precio: precio,
      fechaInicio: fechaInicio,
      isDeleted: isDeleted,
      fechaFin: fechaFin,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HistorialPrecio &&
      id == other.id &&
      _productoID == other._productoID &&
      _tipo == other._tipo &&
      _precio == other._precio &&
      _fechaInicio == other._fechaInicio &&
      _isDeleted == other._isDeleted &&
      _fechaFin == other._fechaFin &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("HistorialPrecio {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("productoID=" + "$_productoID" + ", ");
    buffer.write("tipo=" + "$_tipo" + ", ");
    buffer.write("precio=" + (_precio != null ? _precio.toString() : "null") + ", ");
    buffer.write("fechaInicio=" + (_fechaInicio != null ? _fechaInicio.format() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("fechaFin=" + (_fechaFin != null ? _fechaFin.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  HistorialPrecio copyWith({String? productoID, String? tipo, double? precio, amplify_core.TemporalDateTime? fechaInicio, bool? isDeleted, amplify_core.TemporalDateTime? fechaFin, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return HistorialPrecio._internal(
      id: id,
      productoID: productoID ?? this.productoID,
      tipo: tipo ?? this.tipo,
      precio: precio ?? this.precio,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      isDeleted: isDeleted ?? this.isDeleted,
      fechaFin: fechaFin ?? this.fechaFin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  HistorialPrecio copyWithModelFieldValues({
    ModelFieldValue<String>? productoID,
    ModelFieldValue<String>? tipo,
    ModelFieldValue<double>? precio,
    ModelFieldValue<amplify_core.TemporalDateTime>? fechaInicio,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime?>? fechaFin,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return HistorialPrecio._internal(
      id: id,
      productoID: productoID == null ? this.productoID : productoID.value,
      tipo: tipo == null ? this.tipo : tipo.value,
      precio: precio == null ? this.precio : precio.value,
      fechaInicio: fechaInicio == null ? this.fechaInicio : fechaInicio.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      fechaFin: fechaFin == null ? this.fechaFin : fechaFin.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  HistorialPrecio.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _productoID = json['productoID'],
      _tipo = json['tipo'],
      _precio = (json['precio'] as num?)?.toDouble(),
      _fechaInicio = json['fechaInicio'] != null ? amplify_core.TemporalDateTime.fromString(json['fechaInicio']) : null,
      _isDeleted = json['isDeleted'],
      _fechaFin = json['fechaFin'] != null ? amplify_core.TemporalDateTime.fromString(json['fechaFin']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'productoID': _productoID, 'tipo': _tipo, 'precio': _precio, 'fechaInicio': _fechaInicio?.format(), 'isDeleted': _isDeleted, 'fechaFin': _fechaFin?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'productoID': _productoID,
    'tipo': _tipo,
    'precio': _precio,
    'fechaInicio': _fechaInicio,
    'isDeleted': _isDeleted,
    'fechaFin': _fechaFin,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<HistorialPrecioModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<HistorialPrecioModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final PRODUCTOID = amplify_core.QueryField(fieldName: "productoID");
  static final TIPO = amplify_core.QueryField(fieldName: "tipo");
  static final PRECIO = amplify_core.QueryField(fieldName: "precio");
  static final FECHAINICIO = amplify_core.QueryField(fieldName: "fechaInicio");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final FECHAFIN = amplify_core.QueryField(fieldName: "fechaFin");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "HistorialPrecio";
    modelSchemaDefinition.pluralName = "HistorialPrecios";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.GROUPS,
        groupClaim: "cognito:groups",
        groups: [ "admin", "vendedor" ],
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null),
      amplify_core.ModelIndex(fields: const ["productoID"], name: "byProducto")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.PRODUCTOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.TIPO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.PRECIO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.FECHAINICIO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.FECHAFIN,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: HistorialPrecio.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _HistorialPrecioModelType extends amplify_core.ModelType<HistorialPrecio> {
  const _HistorialPrecioModelType();
  
  @override
  HistorialPrecio fromJson(Map<String, dynamic> jsonData) {
    return HistorialPrecio.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'HistorialPrecio';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [HistorialPrecio] in your schema.
 */
class HistorialPrecioModelIdentifier implements amplify_core.ModelIdentifier<HistorialPrecio> {
  final String id;

  /** Create an instance of HistorialPrecioModelIdentifier using [id] the primary key. */
  const HistorialPrecioModelIdentifier({
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
  String toString() => 'HistorialPrecioModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is HistorialPrecioModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}