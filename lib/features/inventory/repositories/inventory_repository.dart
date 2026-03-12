import 'dart:convert';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/models/product.dart';

class InventoryRepository {
  Future<List<Product>> getProducts() async {
    final response = await ApiClient.get('/products');
    if (response.statusCode != 200) return [];

    final List data = jsonDecode(response.body);
    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<List<Map<String, dynamic>>> getInventoryWithTotalQty() async {
    final response = await ApiClient.get('/reports?type=inventory');
    if (response.statusCode != 200) return [];

    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> savePurchaseInvoice(Map<String, dynamic> data) async {
    // Mapping frontend data to backend expectations
    final body = {
      'invoiceNumber': data['invoice_number'],
      'vendorName': data['vendor_name'] ?? data['customer_name'],
      'vendorGstin': data['vendor_gstin'] ?? data['gstin'],
      'totalAmount': data['total_amount'],
      'taxAmount': data['tax_amount'] ?? 0,
      'imageUrl': data['image_url'],
      'items': (data['items'] as List).map((item) => {
        'productName': item['product_name'], // Backend can handle product upsert if we add it, but here we assume items have productId
        'productId': item['productId'], // Or handle name mapping
        'batchNo': item['batch_no'],
        'expiryDate': item['expiry_date'],
        'qty': item['qty'],
        'rate': item['rate'],
        'taxableValue': item['taxable_value'],
        'mrp': item['mrp'],
        'sellingPrice': item['selling_price'],
        'gstPercent': item['gst_percent'],
      }).toList(),
    };

    final response = await ApiClient.post('/purchases', body);
    if (response.statusCode != 201) {
      throw Exception('Failed to save purchase: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getPurchaseInvoices() async {
    final response = await ApiClient.get('/reports?type=summary'); // Or implement a proper list endpoint
    // Fallback: If no dedicated list endpoint yet, return empty for now or implement list in API
    return [];
  }

  Future<List<Map<String, dynamic>>> getPurchaseItems(String invoiceId) async {
    // Dedicated endpoint for purchase details could be added
    return [];
  }
}
