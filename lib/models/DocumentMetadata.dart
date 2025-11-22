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


/** This is an auto generated class representing the DocumentMetadata type in your schema. */
class DocumentMetadata extends amplify_core.Model {
  static const classType = const _DocumentMetadataModelType();
  final String id;
  final String? _key;
  final String? _value;
  final String? _invoiceID;
  final String? _orderID;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;
  final String? _invoiceMetadataId;
  final String? _orderMetadataId;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DocumentMetadataModelIdentifier get modelIdentifier {
      return DocumentMetadataModelIdentifier(
        id: id
      );
  }
  
  String get key {
    try {
      return _key!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get value {
    try {
      return _value!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get invoiceID {
    return _invoiceID;
  }
  
  String? get orderID {
    return _orderID;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  String? get invoiceMetadataId {
    return _invoiceMetadataId;
  }
  
  String? get orderMetadataId {
    return _orderMetadataId;
  }
  
  const DocumentMetadata._internal({required this.id, required key, required value, invoiceID, orderID, createdAt, updatedAt, invoiceMetadataId, orderMetadataId}): _key = key, _value = value, _invoiceID = invoiceID, _orderID = orderID, _createdAt = createdAt, _updatedAt = updatedAt, _invoiceMetadataId = invoiceMetadataId, _orderMetadataId = orderMetadataId;
  
  factory DocumentMetadata({String? id, required String key, required String value, String? invoiceID, String? orderID, String? invoiceMetadataId, String? orderMetadataId}) {
    return DocumentMetadata._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      key: key,
      value: value,
      invoiceID: invoiceID,
      orderID: orderID,
      invoiceMetadataId: invoiceMetadataId,
      orderMetadataId: orderMetadataId);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DocumentMetadata &&
      id == other.id &&
      _key == other._key &&
      _value == other._value &&
      _invoiceID == other._invoiceID &&
      _orderID == other._orderID &&
      _invoiceMetadataId == other._invoiceMetadataId &&
      _orderMetadataId == other._orderMetadataId;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DocumentMetadata {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("key=" + "$_key" + ", ");
    buffer.write("value=" + "$_value" + ", ");
    buffer.write("invoiceID=" + "$_invoiceID" + ", ");
    buffer.write("orderID=" + "$_orderID" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("invoiceMetadataId=" + "$_invoiceMetadataId" + ", ");
    buffer.write("orderMetadataId=" + "$_orderMetadataId");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DocumentMetadata copyWith({String? key, String? value, String? invoiceID, String? orderID, String? invoiceMetadataId, String? orderMetadataId}) {
    return DocumentMetadata._internal(
      id: id,
      key: key ?? this.key,
      value: value ?? this.value,
      invoiceID: invoiceID ?? this.invoiceID,
      orderID: orderID ?? this.orderID,
      invoiceMetadataId: invoiceMetadataId ?? this.invoiceMetadataId,
      orderMetadataId: orderMetadataId ?? this.orderMetadataId);
  }
  
  DocumentMetadata copyWithModelFieldValues({
    ModelFieldValue<String>? key,
    ModelFieldValue<String>? value,
    ModelFieldValue<String?>? invoiceID,
    ModelFieldValue<String?>? orderID,
    ModelFieldValue<String?>? invoiceMetadataId,
    ModelFieldValue<String?>? orderMetadataId
  }) {
    return DocumentMetadata._internal(
      id: id,
      key: key == null ? this.key : key.value,
      value: value == null ? this.value : value.value,
      invoiceID: invoiceID == null ? this.invoiceID : invoiceID.value,
      orderID: orderID == null ? this.orderID : orderID.value,
      invoiceMetadataId: invoiceMetadataId == null ? this.invoiceMetadataId : invoiceMetadataId.value,
      orderMetadataId: orderMetadataId == null ? this.orderMetadataId : orderMetadataId.value
    );
  }
  
  DocumentMetadata.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _key = json['key'],
      _value = json['value'],
      _invoiceID = json['invoiceID'],
      _orderID = json['orderID'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _invoiceMetadataId = json['invoiceMetadataId'],
      _orderMetadataId = json['orderMetadataId'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'key': _key, 'value': _value, 'invoiceID': _invoiceID, 'orderID': _orderID, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'invoiceMetadataId': _invoiceMetadataId, 'orderMetadataId': _orderMetadataId
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'key': _key,
    'value': _value,
    'invoiceID': _invoiceID,
    'orderID': _orderID,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
    'invoiceMetadataId': _invoiceMetadataId,
    'orderMetadataId': _orderMetadataId
  };

  static final amplify_core.QueryModelIdentifier<DocumentMetadataModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DocumentMetadataModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final KEY = amplify_core.QueryField(fieldName: "key");
  static final VALUE = amplify_core.QueryField(fieldName: "value");
  static final INVOICEID = amplify_core.QueryField(fieldName: "invoiceID");
  static final ORDERID = amplify_core.QueryField(fieldName: "orderID");
  static final INVOICEMETADATAID = amplify_core.QueryField(fieldName: "invoiceMetadataId");
  static final ORDERMETADATAID = amplify_core.QueryField(fieldName: "orderMetadataId");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DocumentMetadata";
    modelSchemaDefinition.pluralName = "DocumentMetadata";
    
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
      amplify_core.ModelIndex(fields: const ["invoiceID"], name: "byInvoice"),
      amplify_core.ModelIndex(fields: const ["orderID"], name: "byOrder")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DocumentMetadata.KEY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DocumentMetadata.VALUE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DocumentMetadata.INVOICEID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DocumentMetadata.ORDERID,
      isRequired: false,
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
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DocumentMetadata.INVOICEMETADATAID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DocumentMetadata.ORDERMETADATAID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
}

class _DocumentMetadataModelType extends amplify_core.ModelType<DocumentMetadata> {
  const _DocumentMetadataModelType();
  
  @override
  DocumentMetadata fromJson(Map<String, dynamic> jsonData) {
    return DocumentMetadata.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DocumentMetadata';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DocumentMetadata] in your schema.
 */
class DocumentMetadataModelIdentifier implements amplify_core.ModelIdentifier<DocumentMetadata> {
  final String id;

  /** Create an instance of DocumentMetadataModelIdentifier using [id] the primary key. */
  const DocumentMetadataModelIdentifier({
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
  String toString() => 'DocumentMetadataModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DocumentMetadataModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}