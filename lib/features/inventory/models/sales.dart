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

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: (json['id'] ?? '').toString(),
      tenantId: (json['tenantId'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? 'N/A').toString(),
      customerName: json['customerName']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      totalAmount: (json['totalAmount'] ?? 0.0) is num ? (json['totalAmount'] as num).toDouble() : 0.0,
      taxAmount: (json['taxAmount'] ?? 0.0) is num ? (json['taxAmount'] as num).toDouble() : 0.0,
      discountAmount: (json['discountAmount'] ?? 0.0) is num ? (json['discountAmount'] as num).toDouble() : 0.0,
      paymentMode: (json['paymentMode'] ?? 'cash').toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
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

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      id: (json['id'] ?? '').toString(),
      invoiceId: (json['invoiceId'] ?? '').toString(),
      batchId: (json['batchId'] ?? '').toString(),
      qty: (json['qty'] ?? 0) is num ? (json['qty'] as num).toInt() : 0,
      unitPrice: (json['unitPrice'] ?? 0.0) is num ? (json['unitPrice'] as num).toDouble() : 0.0,
      taxableValue: (json['taxableValue'] ?? 0.0) is num ? (json['taxableValue'] as num).toDouble() : 0.0,
      cgst: (json['cgst'] ?? 0.0) is num ? (json['cgst'] as num).toDouble() : 0.0,
      sgst: (json['sgst'] ?? 0.0) is num ? (json['sgst'] as num).toDouble() : 0.0,
      igst: (json['igst'] ?? 0.0) is num ? (json['igst'] as num).toDouble() : 0.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
