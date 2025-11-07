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


/** This is an auto generated class representing the CompraItem type in your schema. */
class CompraItem extends amplify_core.Model {
  static const classType = const _CompraItemModelType();
  final String id;
  final String? _compraID;
  final String? _productoID;
  final int? _cantidad;
  final double? _precioUnitario;
  final double? _subtotal;
  final amplify_core.TemporalDateTime? _createdAt;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CompraItemModelIdentifier get modelIdentifier {
      return CompraItemModelIdentifier(
        id: id
      );
  }
  
  String get compraID {
    try {
      return _compraID!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  int get cantidad {
    try {
      return _cantidad!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get precioUnitario {
    try {
      return _precioUnitario!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get subtotal {
    try {
      return _subtotal!;
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
  
  const CompraItem._internal({required this.id, required compraID, required productoID, required cantidad, required precioUnitario, required subtotal, required createdAt, required isDeleted, required updatedAt}): _compraID = compraID, _productoID = productoID, _cantidad = cantidad, _precioUnitario = precioUnitario, _subtotal = subtotal, _createdAt = createdAt, _isDeleted = isDeleted, _updatedAt = updatedAt;
  
  factory CompraItem({String? id, required String compraID, required String productoID, required int cantidad, required double precioUnitario, required double subtotal, required amplify_core.TemporalDateTime createdAt, required bool isDeleted, required amplify_core.TemporalDateTime updatedAt}) {
    return CompraItem._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      compraID: compraID,
      productoID: productoID,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
      createdAt: createdAt,
      isDeleted: isDeleted,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompraItem &&
      id == other.id &&
      _compraID == other._compraID &&
      _productoID == other._productoID &&
      _cantidad == other._cantidad &&
      _precioUnitario == other._precioUnitario &&
      _subtotal == other._subtotal &&
      _createdAt == other._createdAt &&
      _isDeleted == other._isDeleted &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("CompraItem {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("compraID=" + "$_compraID" + ", ");
    buffer.write("productoID=" + "$_productoID" + ", ");
    buffer.write("cantidad=" + (_cantidad != null ? _cantidad.toString() : "null") + ", ");
    buffer.write("precioUnitario=" + (_precioUnitario != null ? _precioUnitario.toString() : "null") + ", ");
    buffer.write("subtotal=" + (_subtotal != null ? _subtotal.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  CompraItem copyWith({String? compraID, String? productoID, int? cantidad, double? precioUnitario, double? subtotal, amplify_core.TemporalDateTime? createdAt, bool? isDeleted, amplify_core.TemporalDateTime? updatedAt}) {
    return CompraItem._internal(
      id: id,
      compraID: compraID ?? this.compraID,
      productoID: productoID ?? this.productoID,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  CompraItem copyWithModelFieldValues({
    ModelFieldValue<String>? compraID,
    ModelFieldValue<String>? productoID,
    ModelFieldValue<int>? cantidad,
    ModelFieldValue<double>? precioUnitario,
    ModelFieldValue<double>? subtotal,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return CompraItem._internal(
      id: id,
      compraID: compraID == null ? this.compraID : compraID.value,
      productoID: productoID == null ? this.productoID : productoID.value,
      cantidad: cantidad == null ? this.cantidad : cantidad.value,
      precioUnitario: precioUnitario == null ? this.precioUnitario : precioUnitario.value,
      subtotal: subtotal == null ? this.subtotal : subtotal.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  CompraItem.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _compraID = json['compraID'],
      _productoID = json['productoID'],
      _cantidad = (json['cantidad'] as num?)?.toInt(),
      _precioUnitario = (json['precioUnitario'] as num?)?.toDouble(),
      _subtotal = (json['subtotal'] as num?)?.toDouble(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _isDeleted = json['isDeleted'],
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'compraID': _compraID, 'productoID': _productoID, 'cantidad': _cantidad, 'precioUnitario': _precioUnitario, 'subtotal': _subtotal, 'createdAt': _createdAt?.format(), 'isDeleted': _isDeleted, 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'compraID': _compraID,
    'productoID': _productoID,
    'cantidad': _cantidad,
    'precioUnitario': _precioUnitario,
    'subtotal': _subtotal,
    'createdAt': _createdAt,
    'isDeleted': _isDeleted,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CompraItemModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CompraItemModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final COMPRAID = amplify_core.QueryField(fieldName: "compraID");
  static final PRODUCTOID = amplify_core.QueryField(fieldName: "productoID");
  static final CANTIDAD = amplify_core.QueryField(fieldName: "cantidad");
  static final PRECIOUNITARIO = amplify_core.QueryField(fieldName: "precioUnitario");
  static final SUBTOTAL = amplify_core.QueryField(fieldName: "subtotal");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "CompraItem";
    modelSchemaDefinition.pluralName = "CompraItems";
    
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
      amplify_core.ModelIndex(fields: const ["compraID"], name: "byCompra"),
      amplify_core.ModelIndex(fields: const ["productoID"], name: "byProducto")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.COMPRAID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.PRODUCTOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.CANTIDAD,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.PRECIOUNITARIO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.SUBTOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: CompraItem.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _CompraItemModelType extends amplify_core.ModelType<CompraItem> {
  const _CompraItemModelType();
  
  @override
  CompraItem fromJson(Map<String, dynamic> jsonData) {
    return CompraItem.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'CompraItem';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [CompraItem] in your schema.
 */
class CompraItemModelIdentifier implements amplify_core.ModelIdentifier<CompraItem> {
  final String id;

  /** Create an instance of CompraItemModelIdentifier using [id] the primary key. */
  const CompraItemModelIdentifier({
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
  String toString() => 'CompraItemModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CompraItemModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}