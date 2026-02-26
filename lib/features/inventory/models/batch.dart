import 'package:freezed_annotation/freezed_annotation.dart';

part 'batch.freezed.dart';
part 'batch.g.dart';

@freezed
class Batch with _$Batch {
  const factory Batch({
    required String id,
    required String tenantId,
    required String productId,
    required String batchNo,
    required DateTime expiryDate,
    required int quantity,
    double? purchasePrice,
    double? mrp,
    double? sellingPrice,
    DateTime? createdAt,
  }) = _Batch;

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);
}
