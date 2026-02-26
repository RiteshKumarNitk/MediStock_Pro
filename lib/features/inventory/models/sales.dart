import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales.freezed.dart';
part 'sales.g.dart';


@freezed
class SalesInvoice with _$SalesInvoice {
  const factory SalesInvoice({
    required String id,
    required String tenantId,
    required String invoiceNumber,
    String? customerName,
    String? customerPhone,
    required double totalAmount,
    required double taxAmount,
    @Default(0.0) double discountAmount,
    required String paymentMode, // cash, card, upi
    DateTime? createdAt,
  }) = _SalesInvoice;

  factory SalesInvoice.fromJson(Map<String, dynamic> json) => _$SalesInvoiceFromJson(json);
}

@freezed
class SalesItem with _$SalesItem {
  const factory SalesItem({
    required String id,
    required String invoiceId,
    required String batchId,
    required int qty,
    required double unitPrice,
    required double taxableValue,
    @Default(0.0) double cgst,
    @Default(0.0) double sgst,
    @Default(0.0) double igst,
    DateTime? createdAt,
  }) = _SalesItem;

  factory SalesItem.fromJson(Map<String, dynamic> json) => _$SalesItemFromJson(json);
}
