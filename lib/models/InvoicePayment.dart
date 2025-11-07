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


/** This is an auto generated class representing the InvoicePayment type in your schema. */
class InvoicePayment extends amplify_core.Model {
  static const classType = const _InvoicePaymentModelType();
  final String id;
  final String? _invoiceID;
  final TiposPago? _tipoPago;
  final double? _monto;
  final String? _detalles;
  final bool? _isDeleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  InvoicePaymentModelIdentifier get modelIdentifier {
      return InvoicePaymentModelIdentifier(
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
  
  TiposPago get tipoPago {
    try {
      return _tipoPago!;
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
  
  String? get detalles {
    return _detalles;
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
  
  const InvoicePayment._internal({required this.id, required invoiceID, required tipoPago, required monto, detalles, required isDeleted, required createdAt, required updatedAt}): _invoiceID = invoiceID, _tipoPago = tipoPago, _monto = monto, _detalles = detalles, _isDeleted = isDeleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory InvoicePayment({String? id, required String invoiceID, required TiposPago tipoPago, required double monto, String? detalles, required bool isDeleted, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return InvoicePayment._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      invoiceID: invoiceID,
      tipoPago: tipoPago,
      monto: monto,
      detalles: detalles,
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
    return other is InvoicePayment &&
      id == other.id &&
      _invoiceID == other._invoiceID &&
      _tipoPago == other._tipoPago &&
      _monto == other._monto &&
      _detalles == other._detalles &&
      _isDeleted == other._isDeleted &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("InvoicePayment {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("invoiceID=" + "$_invoiceID" + ", ");
    buffer.write("tipoPago=" + (_tipoPago != null ? amplify_core.enumToString(_tipoPago)! : "null") + ", ");
    buffer.write("monto=" + (_monto != null ? _monto.toString() : "null") + ", ");
    buffer.write("detalles=" + "$_detalles" + ", ");
    buffer.write("isDeleted=" + (_isDeleted != null ? _isDeleted.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  InvoicePayment copyWith({String? invoiceID, TiposPago? tipoPago, double? monto, String? detalles, bool? isDeleted, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return InvoicePayment._internal(
      id: id,
      invoiceID: invoiceID ?? this.invoiceID,
      tipoPago: tipoPago ?? this.tipoPago,
      monto: monto ?? this.monto,
      detalles: detalles ?? this.detalles,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  InvoicePayment copyWithModelFieldValues({
    ModelFieldValue<String>? invoiceID,
    ModelFieldValue<TiposPago>? tipoPago,
    ModelFieldValue<double>? monto,
    ModelFieldValue<String?>? detalles,
    ModelFieldValue<bool>? isDeleted,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return InvoicePayment._internal(
      id: id,
      invoiceID: invoiceID == null ? this.invoiceID : invoiceID.value,
      tipoPago: tipoPago == null ? this.tipoPago : tipoPago.value,
      monto: monto == null ? this.monto : monto.value,
      detalles: detalles == null ? this.detalles : detalles.value,
      isDeleted: isDeleted == null ? this.isDeleted : isDeleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  InvoicePayment.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _invoiceID = json['invoiceID'],
      _tipoPago = amplify_core.enumFromString<TiposPago>(json['tipoPago'], TiposPago.values),
      _monto = (json['monto'] as num?)?.toDouble(),
      _detalles = json['detalles'],
      _isDeleted = json['isDeleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'invoiceID': _invoiceID, 'tipoPago': amplify_core.enumToString(_tipoPago), 'monto': _monto, 'detalles': _detalles, 'isDeleted': _isDeleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'invoiceID': _invoiceID,
    'tipoPago': _tipoPago,
    'monto': _monto,
    'detalles': _detalles,
    'isDeleted': _isDeleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<InvoicePaymentModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<InvoicePaymentModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final INVOICEID = amplify_core.QueryField(fieldName: "invoiceID");
  static final TIPOPAGO = amplify_core.QueryField(fieldName: "tipoPago");
  static final MONTO = amplify_core.QueryField(fieldName: "monto");
  static final DETALLES = amplify_core.QueryField(fieldName: "detalles");
  static final ISDELETED = amplify_core.QueryField(fieldName: "isDeleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "InvoicePayment";
    modelSchemaDefinition.pluralName = "InvoicePayments";
    
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
      amplify_core.ModelIndex(fields: const ["invoiceID"], name: "byInvoice")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.INVOICEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.TIPOPAGO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.MONTO,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.DETALLES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.ISDELETED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: InvoicePayment.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _InvoicePaymentModelType extends amplify_core.ModelType<InvoicePayment> {
  const _InvoicePaymentModelType();
  
  @override
  InvoicePayment fromJson(Map<String, dynamic> jsonData) {
    return InvoicePayment.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'InvoicePayment';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [InvoicePayment] in your schema.
 */
class InvoicePaymentModelIdentifier implements amplify_core.ModelIdentifier<InvoicePayment> {
  final String id;

  /** Create an instance of InvoicePaymentModelIdentifier using [id] the primary key. */
  const InvoicePaymentModelIdentifier({
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
  String toString() => 'InvoicePaymentModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is InvoicePaymentModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}