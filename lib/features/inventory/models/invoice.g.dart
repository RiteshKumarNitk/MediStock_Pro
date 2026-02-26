// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerName: json['customerName'] as String?,
      gstin: json['gstin'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'invoiceNumber': instance.invoiceNumber,
      'customerName': instance.customerName,
      'gstin': instance.gstin,
      'totalAmount': instance.totalAmount,
      'taxAmount': instance.taxAmount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$InvoiceItemImpl _$$InvoiceItemImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceItemImpl(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      productName: json['productName'] as String,
      batchNo: json['batchNo'] as String?,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      qty: (json['qty'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      taxableValue: (json['taxableValue'] as num).toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InvoiceItemImplToJson(_$InvoiceItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'productName': instance.productName,
      'batchNo': instance.batchNo,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'qty': instance.qty,
      'rate': instance.rate,
      'discount': instance.discount,
      'taxableValue': instance.taxableValue,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
