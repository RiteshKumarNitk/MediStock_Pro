import 'dart:convert';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/models/sales.dart';

class SalesRepository {
  Future<SalesInvoice> createSale({
    required String customerName,
    required String customerPhone,
    required String paymentMode,
    required List<Map<String, dynamic>> items, // [{batch_id, qty, unit_price, taxable_value, cgst, sgst}]
  }) async {
    final body = {
      'invoiceNumber': 'SALE-${DateTime.now().millisecondsSinceEpoch}',
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMode': paymentMode,
      'totalAmount': items.fold<double>(0, (sum, item) => sum + item['taxable_value'] + item['cgst'] + item['sgst']),
      'taxAmount': items.fold<double>(0, (sum, item) => sum + item['cgst'] + item['sgst']),
      'items': items.map((item) => {
        'batchId': item['batch_id'],
        'qty': item['qty'],
        'unitPrice': item['unit_price'],
        'taxableValue': item['taxable_value'],
        'cgst': item['cgst'],
        'sgst': item['sgst'],
      }).toList(),
    };

    final response = await ApiClient.post('/sales', body);
    if (response.statusCode != 201) {
      throw Exception('Failed to create sale: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return SalesInvoice(
      id: (data['id'] ?? '').toString(),
      tenantId: (data['tenantId'] ?? '').toString(),
      invoiceNumber: (data['invoiceNumber'] ?? 'SALE-ERR').toString(),
      customerName: data['customerName']?.toString(),
      customerPhone: data['customerPhone']?.toString(),
      totalAmount: (data['totalAmount'] ?? 0.0) is num ? (data['totalAmount'] as num).toDouble() : 0.0,
      taxAmount: (data['taxAmount'] ?? 0.0) is num ? (data['taxAmount'] as num).toDouble() : 0.0,
      paymentMode: (data['paymentMode'] ?? 'cash').toString(),
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) : null,
    );
  }

  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    final response = await ApiClient.get('/reports?type=summary'); // Or proper list
    return [];
  }
}
