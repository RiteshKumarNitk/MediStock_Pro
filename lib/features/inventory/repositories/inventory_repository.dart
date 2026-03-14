import 'dart:convert';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/models/product.dart';

class InventoryRepository {
  Future<List<Product>> getProducts() async {
    final response = await ApiClient.get('/products');
    if (response.statusCode != 200) return [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    if (decoded['success'] != true) return [];
    
    final List data = decoded['data'] ?? [];
    return data.map((item) {
      return Product(
        id: (item['id'] ?? '').toString(),
        tenantId: (item['tenantId'] ?? '').toString(),
        name: (item['name'] ?? 'Unknown').toString(),
        barcode: item['barcode']?.toString(),
        hsnCode: item['hsnCode']?.toString(),
        category: item['category']?.toString(),
        gstPercent: (item['gstPercent'] ?? 12.0) is num ? (item['gstPercent'] as num).toDouble() : 12.0,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> getInventoryPaginated({
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    final query = 'type=inventory&page=$page&limit=$limit&search=${Uri.encodeComponent(search)}';
    final response = await ApiClient.get('/reports?$query');
    
    if (response.statusCode != 200) return {'data': [], 'total': 0};

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    if (decoded['success'] != true) return {'data': [], 'total': 0};
    
    final List data = decoded['data'] ?? [];
    final pagination = decoded['pagination'] ?? {};
    
    return {
      'data': data.map((item) => Map<String, dynamic>.from(item as Map)).toList(),
      'total': pagination['total'] ?? data.length,
      'totalPages': pagination['totalPages'] ?? 1,
    };
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
        'productName': item['product_name'],
        'productId': item['productId'],
        'barcode': item['barcode'] ?? item['barcode_no'],
        'category': item['category'],
        'hsnCode': item['hsn_code'] ?? item['hsnCode'],
        'batchNo': item['batch_no'],
        'expiryDate': item['expiry_date'],
        'qty': item['qty'],
        'rate': item['purchase_price'] ?? item['rate'],
        'taxableValue': item['taxable_value'] ?? ((item['purchase_price'] ?? item['rate'] ?? 0) * (item['qty'] ?? 0)),
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

  Future<List<Map<String, dynamic>>> getLedger() async {
    final response = await ApiClient.get('/reports?type=ledger');
    if (response.statusCode != 200) throw Exception('Ledger error: ${response.body}');
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    return (decoded['data'] as List).cast<Map<String, dynamic>>();
  }
}
