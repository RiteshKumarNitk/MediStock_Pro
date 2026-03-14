import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';

class InventoryProvider extends StateNotifier<bool> {
  InventoryProvider() : super(false);

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final response = await ApiClient.get('/products?barcode=$barcode');
    if (response.statusCode != 200) return null;
    
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    if (decoded['success'] != true) return null;
    final List data = decoded['data'] ?? [];
    if (data.isEmpty) return null;
    return data[0] as Map<String, dynamic>;
  }

  Future<void> addStock({
    required String barcode,
    required String name,
    required String batchNo,
    required DateTime expiryDate,
    required int quantity,
    required double? purchasePrice,
    required double? sellingPrice,
  }) async {
    state = true;
    try {
      // 1. Ensure Product exists or create it
      // Note: Backend /products POST should handle upsert if we designed it that way, 
      // but let's assume we need to create product first if not exists or use a dedicated endpoint.
      // In our current backend, we have POST /products and POST /batches.
      
      final productResponse = await ApiClient.post('/products', {
        'name': name,
        'barcode': barcode,
      });

      if (productResponse.statusCode != 201 && productResponse.statusCode != 200) {
         // If it already exists, it might return 200 or 409 depending on implementation.
         // For now, let's proceed to fetch the ID or use a more robust backend service.
      }
      
      final decodedProduct = jsonDecode(productResponse.body);
      if (decodedProduct['success'] != true) {
        throw Exception('Failed to create product');
      }
      final productId = decodedProduct['data']['id'];

      // 2. Add Batch
      final batchResponse = await ApiClient.post('/batches', {
        'productId': productId,
        'batchNo': batchNo,
        'expiryDate': expiryDate.toIso8601String(),
        'quantity': quantity,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
      });

      if (batchResponse.statusCode != 201) {
        throw Exception('Failed to add batch: ${batchResponse.body}');
      }
    } catch (e) {
      debugPrint('Error adding stock: $e');
      rethrow;
    } finally {
      state = false;
    }
  }
}

final inventoryProvider = StateNotifierProvider<InventoryProvider, bool>((ref) {
  return InventoryProvider();
});
