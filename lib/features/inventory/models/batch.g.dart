// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BatchImpl _$$BatchImplFromJson(Map<String, dynamic> json) => _$BatchImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  productId: json['productId'] as String,
  batchNo: json['batchNo'] as String,
  expiryDate: DateTime.parse(json['expiryDate'] as String),
  quantity: (json['quantity'] as num).toInt(),
  purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
  mrp: (json['mrp'] as num?)?.toDouble(),
  sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$BatchImplToJson(_$BatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'productId': instance.productId,
      'batchNo': instance.batchNo,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      'mrp': instance.mrp,
      'sellingPrice': instance.sellingPrice,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
