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
    return SalesInvoice.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    final response = await ApiClient.get('/reports?type=summary'); // Or proper list
    return [];
  }
}
