// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiry_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpiryAlertImpl _$$ExpiryAlertImplFromJson(Map<String, dynamic> json) =>
    _$ExpiryAlertImpl(
      tenantId: json['tenantId'] as String,
      productName: json['productName'] as String,
      batchNo: json['batchNo'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      quantity: (json['quantity'] as num).toInt(),
      daysRemaining: (json['daysRemaining'] as num).toInt(),
    );

Map<String, dynamic> _$$ExpiryAlertImplToJson(_$ExpiryAlertImpl instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'productName': instance.productName,
      'batchNo': instance.batchNo,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'quantity': instance.quantity,
      'daysRemaining': instance.daysRemaining,
    };
