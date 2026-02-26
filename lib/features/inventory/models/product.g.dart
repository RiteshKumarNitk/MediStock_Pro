// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      hsnCode: json['hsnCode'] as String?,
      category: json['category'] as String?,
      gstPercent: (json['gstPercent'] as num?)?.toDouble() ?? 12.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'barcode': instance.barcode,
      'hsnCode': instance.hsnCode,
      'category': instance.category,
      'gstPercent': instance.gstPercent,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
