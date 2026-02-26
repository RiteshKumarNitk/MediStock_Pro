import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String tenantId,
    required String invoiceNumber,
    String? customerName,
    String? gstin,
    required double totalAmount,
    required double taxAmount,
    DateTime? createdAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
}

@freezed
class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String id,
    required String invoiceId,
    required String productName,
    String? batchNo,
    DateTime? expiryDate,
    required int qty,
    required double rate,
    @Default(0) double discount,
    required double taxableValue,
    DateTime? createdAt,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
}
