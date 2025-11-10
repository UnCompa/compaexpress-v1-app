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


/** This is an auto generated class representing the Order type in your schema. */
class Order extends amplify_core.Model {
  static const classType = const _OrderModelType();
  final String id;
  final String? _sellerID;
  final String? _negocioID;
  final String? _orderNumber;
  final amplify_core.TemporalDateTime? _orderDate;
  final double? _orderReceivedTotal;
  final double? _orderReturnedTotal;
  final List<OrderPayment>? _orderPayments;
  final String? _orderStatus;
  final List<OrderItem>? _orderItems;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;
  final String? _cajaID;
  final String? _cajaMovimientoID;
  final String? _cierreCajaID;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  OrderModelIdentifier get modelIdentifier {
      return OrderModelIdentifier(
        id: id
      );
  }
  
  String get sellerID {
    try {
      return _sellerID!;
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
  
  String get orderNumber {
    try {
      return _orderNumber!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get orderDate {
    try {
      return _orderDate!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get orderReceivedTotal {
    try {
      return _orderReceivedTotal!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get orderReturnedTotal {
    try {
      return _orderReturnedTotal!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<OrderPayment>? get orderPayments {
    return _orderPayments;
  }
  
  String? get orderStatus {
    return _orderStatus;
  }
  
  List<OrderItem>? get orderItems {
    return _orderItems;
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
  
  String? get cajaID {
    return _cajaID;
  }
  
  String? get cajaMovimientoID {
    return _cajaMovimientoID;
  }
  
  String? get cierreCajaID {
    return _cierreCajaID;
  }
  
  const Order._internal({required this.id, required sellerID, required negocioID, required orderNumber, required orderDate, required orderReceivedTotal, required orderReturnedTotal, orderPayments, orderStatus, orderItems, required isDeleted, required createdAt, required updatedAt, cajaID, cajaMovimientoID, cierreCajaID}): _sellerID = sellerID, _negocioID = negocioID, _orderNumber = orderNumber, _orderDate = orderDate, _orderReceivedTotal = orderReceivedTotal, _orderReturnedTotal = orderReturnedTotal, _orderPayments = orderPayments, _orderStatus = orderStatus, _orderItems = orderItems, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt, _cajaID = cajaID, _cajaMovimientoID = cajaMovimientoID, _cierreCajaID = cierreCajaID;
  
  factory Order({String? id, required String sellerID, required String negocioID, required String orderNumber, required amplify_core.TemporalDateTime orderDate, required double orderReceivedTotal, required double orderReturnedTotal, List<OrderPayment>? orderPayments, String? orderStatus, List<OrderItem>? orderItems, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt, String? cajaID, String? cajaMovimientoID, String? cierreCajaID}) {
    return Order._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      sellerID: sellerID,
      negocioID: negocioID,
      orderNumber: orderNumber,
      orderDate: orderDate,
      orderReceivedTotal: orderReceivedTotal,
      orderReturnedTotal: orderReturnedTotal,
      orderPayments: orderPayments != null ? List<OrderPayment>.unmodifiable(orderPayments) : orderPayments,
      orderStatus: orderStatus,
      orderItems: orderItems != null ? List<OrderItem>.unmodifiable(orderItems) : orderItems,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cajaID: cajaID,
      cajaMovimientoID: cajaMovimientoID,
      cierreCajaID: cierreCajaID);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Order &&
      id == other.id &&
      _sellerID == other._sellerID &&
      _negocioID == other._negocioID &&
      _orderNumber == other._orderNumber &&
      _orderDate == other._orderDate &&
      _orderReceivedTotal == other._orderReceivedTotal &&
      _orderReturnedTotal == other._orderReturnedTotal &&
      DeepCollectionEquality().equals(_orderPayments, other._orderPayments) &&
      _orderStatus == other._orderStatus &&
      DeepCollectionEquality().equals(_orderItems, other._orderItems) &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt &&
      _cajaID == other._cajaID &&
      _cajaMovimientoID == other._cajaMovimientoID &&
      _cierreCajaID == other._cierreCajaID;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Order {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("sellerID=" + "$_sellerID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("orderNumber=" + "$_orderNumber" + ", ");
    buffer.write("orderDate=" + (_orderDate != null ? _orderDate!.format() : "null") + ", ");
    buffer.write("orderReceivedTotal=" + (_orderReceivedTotal != null ? _orderReceivedTotal!.toString() : "null") + ", ");
    buffer.write("orderReturnedTotal=" + (_orderReturnedTotal != null ? _orderReturnedTotal!.toString() : "null") + ", ");
    buffer.write("orderStatus=" + "$_orderStatus" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("cajaID=" + "$_cajaID" + ", ");
    buffer.write("cajaMovimientoID=" + "$_cajaMovimientoID" + ", ");
    buffer.write("cierreCajaID=" + "$_cierreCajaID");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Order copyWith({String? sellerID, String? negocioID, String? orderNumber, amplify_core.TemporalDateTime? orderDate, double? orderReceivedTotal, double? orderReturnedTotal, List<OrderPayment>? orderPayments, String? orderStatus, List<OrderItem>? orderItems, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt, String? cajaID, String? cajaMovimientoID, String? cierreCajaID}) {
    return Order._internal(
      id: id,
      sellerID: sellerID ?? this.sellerID,
      negocioID: negocioID ?? this.negocioID,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
      orderReceivedTotal: orderReceivedTotal ?? this.orderReceivedTotal,
      orderReturnedTotal: orderReturnedTotal ?? this.orderReturnedTotal,
      orderPayments: orderPayments ?? this.orderPayments,
      orderStatus: orderStatus ?? this.orderStatus,
      orderItems: orderItems ?? this.orderItems,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cajaID: cajaID ?? this.cajaID,
      cajaMovimientoID: cajaMovimientoID ?? this.cajaMovimientoID,
      cierreCajaID: cierreCajaID ?? this.cierreCajaID);
  }
  
  Order copyWithModelFieldValues({
    ModelFieldValue<String>? sellerID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<String>? orderNumber,
    ModelFieldValue<amplify_core.TemporalDateTime>? orderDate,
    ModelFieldValue<double>? orderReceivedTotal,
    ModelFieldValue<double>? orderReturnedTotal,
    ModelFieldValue<List<OrderPayment>?>? orderPayments,
    ModelFieldValue<String?>? orderStatus,
    ModelFieldValue<List<OrderItem>?>? orderItems,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt,
    ModelFieldValue<String?>? cajaID,
    ModelFieldValue<String?>? cajaMovimientoID,
    ModelFieldValue<String?>? cierreCajaID
  }) {
    return Order._internal(
      id: id,
      sellerID: sellerID == null ? this.sellerID : sellerID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      orderNumber: orderNumber == null ? this.orderNumber : orderNumber.value,
      orderDate: orderDate == null ? this.orderDate : orderDate.value,
      orderReceivedTotal: orderReceivedTotal == null ? this.orderReceivedTotal : orderReceivedTotal.value,
      orderReturnedTotal: orderReturnedTotal == null ? this.orderReturnedTotal : orderReturnedTotal.value,
      orderPayments: orderPayments == null ? this.orderPayments : orderPayments.value,
      orderStatus: orderStatus == null ? this.orderStatus : orderStatus.value,
      orderItems: orderItems == null ? this.orderItems : orderItems.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      cajaID: cajaID == null ? this.cajaID : cajaID.value,
      cajaMovimientoID: cajaMovimientoID == null ? this.cajaMovimientoID : cajaMovimientoID.value,
      cierreCajaID: cierreCajaID == null ? this.cierreCajaID : cierreCajaID.value
    );
  }
  
  Order.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _sellerID = json['sellerID'],
      _negocioID = json['negocioID'],
      _orderNumber = json['orderNumber'],
      _orderDate = json['orderDate'] != null ? amplify_core.TemporalDateTime.fromString(json['orderDate']) : null,
      _orderReceivedTotal = (json['orderReceivedTotal'] as num?)?.toDouble(),
      _orderReturnedTotal = (json['orderReturnedTotal'] as num?)?.toDouble(),
      _orderPayments = json['orderPayments']  is Map
        ? (json['orderPayments']['items'] is List
          ? (json['orderPayments']['items'] as List)
              .where((e) => e != null)
              .map((e) => OrderPayment.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['orderPayments'] is List
          ? (json['orderPayments'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => OrderPayment.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _orderStatus = json['orderStatus'],
      _orderItems = json['orderItems']  is Map
        ? (json['orderItems']['items'] is List
          ? (json['orderItems']['items'] as List)
              .where((e) => e != null)
              .map((e) => OrderItem.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['orderItems'] is List
          ? (json['orderItems'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => OrderItem.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _cajaID = json['cajaID'],
      _cajaMovimientoID = json['cajaMovimientoID'],
      _cierreCajaID = json['cierreCajaID'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'sellerID': _sellerID, 'negocioID': _negocioID, 'orderNumber': _orderNumber, 'orderDate': _orderDate?.format(), 'orderReceivedTotal': _orderReceivedTotal, 'orderReturnedTotal': _orderReturnedTotal, 'orderPayments': _orderPayments?.map((OrderPayment? e) => e?.toJson()).toList(), 'orderStatus': _orderStatus, 'orderItems': _orderItems?.map((OrderItem? e) => e?.toJson()).toList(), 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'cajaID': _cajaID, 'cajaMovimientoID': _cajaMovimientoID, 'cierreCajaID': _cierreCajaID
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'sellerID': _sellerID,
    'negocioID': _negocioID,
    'orderNumber': _orderNumber,
    'orderDate': _orderDate,
    'orderReceivedTotal': _orderReceivedTotal,
    'orderReturnedTotal': _orderReturnedTotal,
    'orderPayments': _orderPayments,
    'orderStatus': _orderStatus,
    'orderItems': _orderItems,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
    'cajaID': _cajaID,
    'cajaMovimientoID': _cajaMovimientoID,
    'cierreCajaID': _cierreCajaID
  };

  static final amplify_core.QueryModelIdentifier<OrderModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<OrderModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final SELLERID = amplify_core.QueryField(fieldName: "sellerID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final ORDERNUMBER = amplify_core.QueryField(fieldName: "orderNumber");
  static final ORDERDATE = amplify_core.QueryField(fieldName: "orderDate");
  static final ORDERRECEIVEDTOTAL = amplify_core.QueryField(fieldName: "orderReceivedTotal");
  static final ORDERRETURNEDTOTAL = amplify_core.QueryField(fieldName: "orderReturnedTotal");
  static final ORDERPAYMENTS = amplify_core.QueryField(
    fieldName: "orderPayments",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'OrderPayment'));
  static final ORDERSTATUS = amplify_core.QueryField(fieldName: "orderStatus");
  static final ORDERITEMS = amplify_core.QueryField(
    fieldName: "orderItems",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'OrderItem'));
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static final CAJAID = amplify_core.QueryField(fieldName: "cajaID");
  static final CAJAMOVIMIENTOID = amplify_core.QueryField(fieldName: "cajaMovimientoID");
  static final CIERRECAJAID = amplify_core.QueryField(fieldName: "cierreCajaID");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Order";
    modelSchemaDefinition.pluralName = "Orders";
    
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
      amplify_core.ModelIndex(fields: const ["negocioID"], name: "byNegocio"),
      amplify_core.ModelIndex(fields: const ["cajaID"], name: "byCaja"),
      amplify_core.ModelIndex(fields: const ["cajaMovimientoID"], name: "byCajaMovimiento"),
      amplify_core.ModelIndex(fields: const ["cierreCajaID"], name: "byCierreCaja")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.SELLERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.ORDERNUMBER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.ORDERDATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.ORDERRECEIVEDTOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.ORDERRETURNEDTOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Order.ORDERPAYMENTS,
      isRequired: false,
      ofModelName: 'OrderPayment',
      associatedKey: OrderPayment.ORDERID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.ORDERSTATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Order.ORDERITEMS,
      isRequired: false,
      ofModelName: 'OrderItem',
      associatedKey: OrderItem.ORDERID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.CAJAID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.CAJAMOVIMIENTOID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Order.CIERRECAJAID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
}

class _OrderModelType extends amplify_core.ModelType<Order> {
  const _OrderModelType();
  
  @override
  Order fromJson(Map<String, dynamic> jsonData) {
    return Order.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Order';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Order] in your schema.
 */
class OrderModelIdentifier implements amplify_core.ModelIdentifier<Order> {
  final String id;

  /** Create an instance of OrderModelIdentifier using [id] the primary key. */
  const OrderModelIdentifier({
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
  String toString() => 'OrderModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is OrderModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}