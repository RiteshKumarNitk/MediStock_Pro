import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String tenantId,
    required String name,
    String? barcode,
    String? hsnCode,
    String? category,
    @Default(12.0) double gstPercent,
    DateTime? createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      tenantId: (json['tenantId'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      barcode: json['barcode']?.toString(),
      hsnCode: json['hsnCode']?.toString(),
      category: json['category']?.toString(),
      gstPercent: (json['gstPercent'] ?? 12.0) is num ? (json['gstPercent'] as num).toDouble() : 12.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
