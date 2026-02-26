// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockMovementImpl _$$StockMovementImplFromJson(Map<String, dynamic> json) =>
    _$StockMovementImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      batchId: json['batchId'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      referenceId: json['referenceId'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StockMovementImplToJson(_$StockMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'batchId': instance.batchId,
      'type': instance.type,
      'quantity': instance.quantity,
      'referenceId': instance.referenceId,
      'reason': instance.reason,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
