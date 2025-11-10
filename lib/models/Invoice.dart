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


/** This is an auto generated class representing the Invoice type in your schema. */
class Invoice extends amplify_core.Model {
  static const classType = const _InvoiceModelType();
  final String id;
  final String? _sellerID;
  final String? _negocioID;
  final String? _clientID;
  final String? _invoiceNumber;
  final amplify_core.TemporalDateTime? _invoiceDate;
  final double? _invoiceReceivedTotal;
  final double? _invoiceReturnedTotal;
  final List<InvoicePayment>? _invoicePayments;
  final String? _invoiceStatus;
  final List<InvoiceItem>? _invoiceItems;
  final List<String>? _invoiceImages;
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
  
  InvoiceModelIdentifier get modelIdentifier {
      return InvoiceModelIdentifier(
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
  
  String? get clientID {
    return _clientID;
  }
  
  String get invoiceNumber {
    try {
      return _invoiceNumber!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get invoiceDate {
    try {
      return _invoiceDate!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get invoiceReceivedTotal {
    try {
      return _invoiceReceivedTotal!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get invoiceReturnedTotal {
    try {
      return _invoiceReturnedTotal!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<InvoicePayment>? get invoicePayments {
    return _invoicePayments;
  }
  
  String? get invoiceStatus {
    return _invoiceStatus;
  }
  
  List<InvoiceItem>? get invoiceItems {
    return _invoiceItems;
  }
  
  List<String>? get invoiceImages {
    return _invoiceImages;
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
  
  String? get cajaID {
    return _cajaID;
  }
  
  String? get cajaMovimientoID {
    return _cajaMovimientoID;
  }
  
  String? get cierreCajaID {
    return _cierreCajaID;
  }
  
  const Invoice._internal({required this.id, required sellerID, required negocioID, clientID, required invoiceNumber, required invoiceDate, required invoiceReceivedTotal, required invoiceReturnedTotal, invoicePayments, invoiceStatus, invoiceItems, invoiceImages, isDeleted, required createdAt, required updatedAt, cajaID, cajaMovimientoID, cierreCajaID}): _sellerID = sellerID, _negocioID = negocioID, _clientID = clientID, _invoiceNumber = invoiceNumber, _invoiceDate = invoiceDate, _invoiceReceivedTotal = invoiceReceivedTotal, _invoiceReturnedTotal = invoiceReturnedTotal, _invoicePayments = invoicePayments, _invoiceStatus = invoiceStatus, _invoiceItems = invoiceItems, _invoiceImages = invoiceImages, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt, _cajaID = cajaID, _cajaMovimientoID = cajaMovimientoID, _cierreCajaID = cierreCajaID;
  
  factory Invoice({String? id, required String sellerID, required String negocioID, String? clientID, required String invoiceNumber, required amplify_core.TemporalDateTime invoiceDate, required double invoiceReceivedTotal, required double invoiceReturnedTotal, List<InvoicePayment>? invoicePayments, String? invoiceStatus, List<InvoiceItem>? invoiceItems, List<String>? invoiceImages, bool? isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt, String? cajaID, String? cajaMovimientoID, String? cierreCajaID}) {
    return Invoice._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      sellerID: sellerID,
      negocioID: negocioID,
      clientID: clientID,
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      invoiceReceivedTotal: invoiceReceivedTotal,
      invoiceReturnedTotal: invoiceReturnedTotal,
      invoicePayments: invoicePayments != null ? List<InvoicePayment>.unmodifiable(invoicePayments) : invoicePayments,
      invoiceStatus: invoiceStatus,
      invoiceItems: invoiceItems != null ? List<InvoiceItem>.unmodifiable(invoiceItems) : invoiceItems,
      invoiceImages: invoiceImages != null ? List<String>.unmodifiable(invoiceImages) : invoiceImages,
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
    return other is Invoice &&
      id == other.id &&
      _sellerID == other._sellerID &&
      _negocioID == other._negocioID &&
      _clientID == other._clientID &&
      _invoiceNumber == other._invoiceNumber &&
      _invoiceDate == other._invoiceDate &&
      _invoiceReceivedTotal == other._invoiceReceivedTotal &&
      _invoiceReturnedTotal == other._invoiceReturnedTotal &&
      DeepCollectionEquality().equals(_invoicePayments, other._invoicePayments) &&
      _invoiceStatus == other._invoiceStatus &&
      DeepCollectionEquality().equals(_invoiceItems, other._invoiceItems) &&
      DeepCollectionEquality().equals(_invoiceImages, other._invoiceImages) &&
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
    
    buffer.write("Invoice {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("sellerID=" + "$_sellerID" + ", ");
    buffer.write("negocioID=" + "$_negocioID" + ", ");
    buffer.write("clientID=" + "$_clientID" + ", ");
    buffer.write("invoiceNumber=" + "$_invoiceNumber" + ", ");
    buffer.write("invoiceDate=" + (_invoiceDate != null ? _invoiceDate!.format() : "null") + ", ");
    buffer.write("invoiceReceivedTotal=" + (_invoiceReceivedTotal != null ? _invoiceReceivedTotal!.toString() : "null") + ", ");
    buffer.write("invoiceReturnedTotal=" + (_invoiceReturnedTotal != null ? _invoiceReturnedTotal!.toString() : "null") + ", ");
    buffer.write("invoiceStatus=" + "$_invoiceStatus" + ", ");
    buffer.write("invoiceImages=" + (_invoiceImages != null ? _invoiceImages!.toString() : "null") + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("cajaID=" + "$_cajaID" + ", ");
    buffer.write("cajaMovimientoID=" + "$_cajaMovimientoID" + ", ");
    buffer.write("cierreCajaID=" + "$_cierreCajaID");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Invoice copyWith({String? sellerID, String? negocioID, String? clientID, String? invoiceNumber, amplify_core.TemporalDateTime? invoiceDate, double? invoiceReceivedTotal, double? invoiceReturnedTotal, List<InvoicePayment>? invoicePayments, String? invoiceStatus, List<InvoiceItem>? invoiceItems, List<String>? invoiceImages, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt, String? cajaID, String? cajaMovimientoID, String? cierreCajaID}) {
    return Invoice._internal(
      id: id,
      sellerID: sellerID ?? this.sellerID,
      negocioID: negocioID ?? this.negocioID,
      clientID: clientID ?? this.clientID,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceReceivedTotal: invoiceReceivedTotal ?? this.invoiceReceivedTotal,
      invoiceReturnedTotal: invoiceReturnedTotal ?? this.invoiceReturnedTotal,
      invoicePayments: invoicePayments ?? this.invoicePayments,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      invoiceItems: invoiceItems ?? this.invoiceItems,
      invoiceImages: invoiceImages ?? this.invoiceImages,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cajaID: cajaID ?? this.cajaID,
      cajaMovimientoID: cajaMovimientoID ?? this.cajaMovimientoID,
      cierreCajaID: cierreCajaID ?? this.cierreCajaID);
  }
  
  Invoice copyWithModelFieldValues({
    ModelFieldValue<String>? sellerID,
    ModelFieldValue<String>? negocioID,
    ModelFieldValue<String?>? clientID,
    ModelFieldValue<String>? invoiceNumber,
    ModelFieldValue<amplify_core.TemporalDateTime>? invoiceDate,
    ModelFieldValue<double>? invoiceReceivedTotal,
    ModelFieldValue<double>? invoiceReturnedTotal,
    ModelFieldValue<List<InvoicePayment>?>? invoicePayments,
    ModelFieldValue<String?>? invoiceStatus,
    ModelFieldValue<List<InvoiceItem>?>? invoiceItems,
    ModelFieldValue<List<String>?>? invoiceImages,
    ModelFieldValue<bool?>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt,
    ModelFieldValue<String?>? cajaID,
    ModelFieldValue<String?>? cajaMovimientoID,
    ModelFieldValue<String?>? cierreCajaID
  }) {
    return Invoice._internal(
      id: id,
      sellerID: sellerID == null ? this.sellerID : sellerID.value,
      negocioID: negocioID == null ? this.negocioID : negocioID.value,
      clientID: clientID == null ? this.clientID : clientID.value,
      invoiceNumber: invoiceNumber == null ? this.invoiceNumber : invoiceNumber.value,
      invoiceDate: invoiceDate == null ? this.invoiceDate : invoiceDate.value,
      invoiceReceivedTotal: invoiceReceivedTotal == null ? this.invoiceReceivedTotal : invoiceReceivedTotal.value,
      invoiceReturnedTotal: invoiceReturnedTotal == null ? this.invoiceReturnedTotal : invoiceReturnedTotal.value,
      invoicePayments: invoicePayments == null ? this.invoicePayments : invoicePayments.value,
      invoiceStatus: invoiceStatus == null ? this.invoiceStatus : invoiceStatus.value,
      invoiceItems: invoiceItems == null ? this.invoiceItems : invoiceItems.value,
      invoiceImages: invoiceImages == null ? this.invoiceImages : invoiceImages.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      cajaID: cajaID == null ? this.cajaID : cajaID.value,
      cajaMovimientoID: cajaMovimientoID == null ? this.cajaMovimientoID : cajaMovimientoID.value,
      cierreCajaID: cierreCajaID == null ? this.cierreCajaID : cierreCajaID.value
    );
  }
  
  Invoice.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _sellerID = json['sellerID'],
      _negocioID = json['negocioID'],
      _clientID = json['clientID'],
      _invoiceNumber = json['invoiceNumber'],
      _invoiceDate = json['invoiceDate'] != null ? amplify_core.TemporalDateTime.fromString(json['invoiceDate']) : null,
      _invoiceReceivedTotal = (json['invoiceReceivedTotal'] as num?)?.toDouble(),
      _invoiceReturnedTotal = (json['invoiceReturnedTotal'] as num?)?.toDouble(),
      _invoicePayments = json['invoicePayments']  is Map
        ? (json['invoicePayments']['items'] is List
          ? (json['invoicePayments']['items'] as List)
              .where((e) => e != null)
              .map((e) => InvoicePayment.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['invoicePayments'] is List
          ? (json['invoicePayments'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => InvoicePayment.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _invoiceStatus = json['invoiceStatus'],
      _invoiceItems = json['invoiceItems']  is Map
        ? (json['invoiceItems']['items'] is List
          ? (json['invoiceItems']['items'] as List)
              .where((e) => e != null)
              .map((e) => InvoiceItem.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['invoiceItems'] is List
          ? (json['invoiceItems'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => InvoiceItem.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _invoiceImages = json['invoiceImages']?.cast<String>(),
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _cajaID = json['cajaID'],
      _cajaMovimientoID = json['cajaMovimientoID'],
      _cierreCajaID = json['cierreCajaID'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'sellerID': _sellerID, 'negocioID': _negocioID, 'clientID': _clientID, 'invoiceNumber': _invoiceNumber, 'invoiceDate': _invoiceDate?.format(), 'invoiceReceivedTotal': _invoiceReceivedTotal, 'invoiceReturnedTotal': _invoiceReturnedTotal, 'invoicePayments': _invoicePayments?.map((InvoicePayment? e) => e?.toJson()).toList(), 'invoiceStatus': _invoiceStatus, 'invoiceItems': _invoiceItems?.map((InvoiceItem? e) => e?.toJson()).toList(), 'invoiceImages': _invoiceImages, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'cajaID': _cajaID, 'cajaMovimientoID': _cajaMovimientoID, 'cierreCajaID': _cierreCajaID
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'sellerID': _sellerID,
    'negocioID': _negocioID,
    'clientID': _clientID,
    'invoiceNumber': _invoiceNumber,
    'invoiceDate': _invoiceDate,
    'invoiceReceivedTotal': _invoiceReceivedTotal,
    'invoiceReturnedTotal': _invoiceReturnedTotal,
    'invoicePayments': _invoicePayments,
    'invoiceStatus': _invoiceStatus,
    'invoiceItems': _invoiceItems,
    'invoiceImages': _invoiceImages,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
    'cajaID': _cajaID,
    'cajaMovimientoID': _cajaMovimientoID,
    'cierreCajaID': _cierreCajaID
  };

  static final amplify_core.QueryModelIdentifier<InvoiceModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<InvoiceModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final SELLERID = amplify_core.QueryField(fieldName: "sellerID");
  static final NEGOCIOID = amplify_core.QueryField(fieldName: "negocioID");
  static final CLIENTID = amplify_core.QueryField(fieldName: "clientID");
  static final INVOICENUMBER = amplify_core.QueryField(fieldName: "invoiceNumber");
  static final INVOICEDATE = amplify_core.QueryField(fieldName: "invoiceDate");
  static final INVOICERECEIVEDTOTAL = amplify_core.QueryField(fieldName: "invoiceReceivedTotal");
  static final INVOICERETURNEDTOTAL = amplify_core.QueryField(fieldName: "invoiceReturnedTotal");
  static final INVOICEPAYMENTS = amplify_core.QueryField(
    fieldName: "invoicePayments",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'InvoicePayment'));
  static final INVOICESTATUS = amplify_core.QueryField(fieldName: "invoiceStatus");
  static final INVOICEITEMS = amplify_core.QueryField(
    fieldName: "invoiceItems",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'InvoiceItem'));
  static final INVOICEIMAGES = amplify_core.QueryField(fieldName: "invoiceImages");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static final CAJAID = amplify_core.QueryField(fieldName: "cajaID");
  static final CAJAMOVIMIENTOID = amplify_core.QueryField(fieldName: "cajaMovimientoID");
  static final CIERRECAJAID = amplify_core.QueryField(fieldName: "cierreCajaID");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Invoice";
    modelSchemaDefinition.pluralName = "Invoices";
    
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
      amplify_core.ModelIndex(fields: const ["clientID"], name: "byClient"),
      amplify_core.ModelIndex(fields: const ["cajaID"], name: "byCaja"),
      amplify_core.ModelIndex(fields: const ["cajaMovimientoID"], name: "byCajaMovimiento"),
      amplify_core.ModelIndex(fields: const ["cierreCajaID"], name: "byCierreCaja")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.SELLERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.NEGOCIOID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.CLIENTID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.INVOICENUMBER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.INVOICEDATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.INVOICERECEIVEDTOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.INVOICERETURNEDTOTAL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Invoice.INVOICEPAYMENTS,
      isRequired: false,
      ofModelName: 'InvoicePayment',
      associatedKey: InvoicePayment.INVOICEID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.INVOICESTATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Invoice.INVOICEITEMS,
      isRequired: false,
      ofModelName: 'InvoiceItem',
      associatedKey: InvoiceItem.INVOICEID
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.INVOICEIMAGES,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.ISDELETED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.CAJAID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.CAJAMOVIMIENTOID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Invoice.CIERRECAJAID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
}

class _InvoiceModelType extends amplify_core.ModelType<Invoice> {
  const _InvoiceModelType();
  
  @override
  Invoice fromJson(Map<String, dynamic> jsonData) {
    return Invoice.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Invoice';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Invoice] in your schema.
 */
class InvoiceModelIdentifier implements amplify_core.ModelIdentifier<Invoice> {
  final String id;

  /** Create an instance of InvoiceModelIdentifier using [id] the primary key. */
  const InvoiceModelIdentifier({
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
  String toString() => 'InvoiceModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is InvoiceModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}