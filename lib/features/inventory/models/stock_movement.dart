import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_movement.freezed.dart';
part 'stock_movement.g.dart';

@freezed
class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String id,
    required String tenantId,
    required String batchId,
    required String type, // purchase, sale, return_in, return_out, adjustment
    required int quantity,
    String? referenceId,
    String? reason,
    DateTime? createdAt,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) => _$StockMovementFromJson(json);
}
