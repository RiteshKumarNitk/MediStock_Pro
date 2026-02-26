// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SalesInvoiceImpl _$$SalesInvoiceImplFromJson(Map<String, dynamic> json) =>
    _$SalesInvoiceImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['paymentMode'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SalesInvoiceImplToJson(_$SalesInvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'invoiceNumber': instance.invoiceNumber,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'totalAmount': instance.totalAmount,
      'taxAmount': instance.taxAmount,
      'discountAmount': instance.discountAmount,
      'paymentMode': instance.paymentMode,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$SalesItemImpl _$$SalesItemImplFromJson(Map<String, dynamic> json) =>
    _$SalesItemImpl(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      batchId: json['batchId'] as String,
      qty: (json['qty'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxableValue: (json['taxableValue'] as num).toDouble(),
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SalesItemImplToJson(_$SalesItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'batchId': instance.batchId,
      'qty': instance.qty,
      'unitPrice': instance.unitPrice,
      'taxableValue': instance.taxableValue,
      'cgst': instance.cgst,
      'sgst': instance.sgst,
      'igst': instance.igst,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
