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


/** This is an auto generated class representing the InvoiceItem type in your schema. */
class InvoiceItem extends amplify_core.Model {
  static const classType = const _InvoiceItemModelType();
  final String id;
  final String? _invoiceID;
  final String? _productoID;
  final String? _precioID;
  final int? _quantity;
  final int? _tax;
  final double? _subtotal;
  final double? _total;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  InvoiceItemModelIdentifier get modelIdentifier {
      return InvoiceItemModelIdentifier(
        id: id
      );
  }
  
  String get invoiceID {
    try {
      return _invoiceID!;
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
  
  String? get precioID {
    return _precioID;
  }
  
  int get quantity {
    try {
      return _quantity!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get tax {
    return _tax;
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
  
  double get total {
    try {
      return _total!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool? get isDeleted {
    return _isDeleted;
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
  
  const InvoiceItem._internal({required this.id, required invoiceID, required productoID, precioID, required quantity, tax, required subtotal, required total, isDeleted, required createdAt, required updatedAt}): _invoiceID = invoiceID, _productoID = productoID, _precioID = precioID, _quantity = quantity, _tax = tax, _subtotal = subtotal, _total = total, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory InvoiceItem({String? id, required String invoiceID, required String productoID, String? precioID, required int quantity, int? tax, required double subtotal, required double total, bool? isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return InvoiceItem._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      invoiceID: invoiceID,
      productoID: productoID,
      precioID: precioID,
      quantity: quantity,
      tax: tax,
      subtotal: subtotal,
      total: total,
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
    return other is InvoiceItem &&
      id == other.id &&
      _invoiceID == other._invoiceID &&
      _productoID == other._productoID &&
      _precioID == other._precioID &&
      _quantity == other._quantity &&
      _tax == other._tax &&
      _subtotal == other._subtotal &&
      _total == other._total &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("InvoiceItem {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("invoiceID=" + "$_invoiceID" + ", ");
    buffer.write("productoID=" + "$_productoID" + ", ");
    buffer.write("precioID=" + "$_precioID" + ", ");
    buffer.write("quantity=" + (_quantity != null ? _quantity!.toString() : "null") + ", ");
    buffer.write("tax=" + (_tax != null ? _tax!.toString() : "null") + ", ");
    buffer.write("subtotal=" + (_subtotal != null ? _subtotal!.toString() : "null") + ", ");
    buffer.write("total=" + (_total != null ? _total!.toString() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  InvoiceItem copyWith({String? invoiceID, String? productoID, String? precioID, int? quantity, int? tax, double? subtotal, double? total, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return InvoiceItem._internal(
      id: id,
      invoiceID: invoiceID ?? this.invoiceID,
      productoID: productoID ?? this.productoID,
      precioID: precioID ?? this.precioID,
      quantity: quantity ?? this.quantity,
      tax: tax ?? this.tax,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  InvoiceItem copyWithModelFieldValues({
    ModelFieldValue<String>? invoiceID,
    ModelFieldValue<String>? productoID,
    ModelFieldValue<String?>? precioID,
    ModelFieldValue<int>? quantity,
    ModelFieldValue<int?>? tax,
    ModelFieldValue<double>? subtotal,
    ModelFieldValue<double>? total,
    ModelFieldValue<bool?>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return InvoiceItem._internal(
      id: id,
      invoiceID: invoiceID == null ? this.invoiceID : invoiceID.value,
      productoID: productoID == null ? this.productoID : productoID.value,
      precioID: precioID == null ? this.precioID : precioID.value,
      quantity: quantity == null ? this.quantity : quantity.value,
      tax: tax == null ? this.tax : tax.value,
      subtotal: subtotal == null ? this.subtotal : subtotal.value,
      total: total == null ? this.total : total.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  InvoiceItem.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _invoiceID = json['invoiceID'],
      _productoID = json['productoID'],
      _precioID = json['precioID'],
      _quantity = (json['quantity'] as num?)?.toInt(),
      _tax = (json['tax'] as num?)?.toInt(),
      _subtotal = (json['subtotal'] as num?)?.toDouble(),
      _total = (json['total'] as num?)?.toDouble(),
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'invoiceID': _invoiceID, 'productoID': _productoID, 'precioID': _precioID, 'quantity': _quantity, 'tax': _tax, 'subtotal': _subtotal, 'total': _total, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'invoiceID': _invoiceID,
    'productoID': _productoID,
    'precioID': _precioID,
    'quantity': _quantity,
    'tax': _tax,
    'subtotal': _subtotal,
    'total': _total,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<InvoiceItemModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<InvoiceItemModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final INVOICEID = amplify_core.QueryField(fieldName: "invoiceID");
  static final PRODUCTOID = amplify_core.QueryField(fieldName: "productoID");
  static final PRECIOID = amplify_core.QueryField(fieldName: "precioID");
  static final QUANTITY = amplify_core.QueryField(fieldName: "quantity");
  static final TAX = amplify_core.QueryField(fieldName: "tax");
  static final SUBTOTAL = amplify_core.QueryField(fieldName: "subtotal");
  static final TOTAL = amplify_core.QueryField(fieldName: "total");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "InvoiceItem";
    modelSchemaDefinition.pluralName = "InvoiceItems";
    
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
      amplify_core.ModelIndex(fields: const ["productoID"], name: "byProducto"),
      amplify_core.ModelIndex(fields: const ["precioID"], name: "byProductoPrecios")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.INVOICEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.PRODUCTOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.PRECIOID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.QUANTITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.TAX,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.SUBTOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.TOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.ISDELETED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoiceItem.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _InvoiceItemModelType extends amplify_core.ModelType<InvoiceItem> {
  const _InvoiceItemModelType();
  
  @override
  InvoiceItem fromJson(Map<String, dynamic> jsonData) {
    return InvoiceItem.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'InvoiceItem';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [InvoiceItem] in your schema.
 */
class InvoiceItemModelIdentifier implements amplify_core.ModelIdentifier<InvoiceItem> {
  final String id;

  /** Create an instance of InvoiceItemModelIdentifier using [id] the primary key. */
  const InvoiceItemModelIdentifier({
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
  String toString() => 'InvoiceItemModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is InvoiceItemModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}