import 'package:freezed_annotation/freezed_annotation.dart';

part 'expiry_alert.freezed.dart';
part 'expiry_alert.g.dart';

@freezed
class ExpiryAlert with _$ExpiryAlert {
  const factory ExpiryAlert({
    required String tenantId,
    required String productName,
    required String batchNo,
    required DateTime expiryDate,
    required int quantity,
    required int daysRemaining,
  }) = _ExpiryAlert;

  factory ExpiryAlert.fromJson(Map<String, dynamic> json) => _$ExpiryAlertFromJson(json);
}
