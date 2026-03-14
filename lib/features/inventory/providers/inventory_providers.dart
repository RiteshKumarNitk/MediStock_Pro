import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/models/expiry_alert.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final response = await ApiClient.get('/reports?type=inventory'); 
  if (response.statusCode != 200) return [];
  
  final Map<String, dynamic> decoded = jsonDecode(response.body);
  if (decoded['success'] != true) return [];
  
  final List data = decoded['data'] ?? [];
  return data.map((item) {
    try {
      // Map JSON fields to match ExpiryAlert constructor expectations
      return ExpiryAlert(
        tenantId: (item['tenantId'] ?? '').toString(),
        productName: (item['productName'] ?? item['name'] ?? 'Unknown').toString(),
        batchNo: (item['batchNo'] ?? item['batch_no'] ?? 'N/A').toString(),
        expiryDate: item['expiryDate'] != null ? DateTime.tryParse(item['expiryDate'].toString()) ?? DateTime.now() : DateTime.now(),
        quantity: (item['quantity'] ?? item['total_qty'] ?? 0) is num ? (item['quantity'] ?? item['total_qty'] ?? 0).toInt() : 0,
        daysRemaining: (item['daysRemaining'] ?? 0) is num ? (item['daysRemaining'] ?? 0).toInt() : 0,
      );
    } catch (e) {
      debugPrint('Error parsing ExpiryAlert: $e');
      return ExpiryAlert(
        tenantId: '',
        productName: 'Parsing Error',
        batchNo: 'N/A',
        expiryDate: DateTime.now(),
        quantity: 0,
        daysRemaining: 0,
      );
    }
  }).toList();
});

final productsProvider = FutureProvider((ref) {
  return ref.watch(inventoryRepositoryProvider).getProducts();
});

final lowStockProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.watch(inventoryRepositoryProvider).getInventoryPaginated(limit: 100);
  final List<Map<String, dynamic>> inventory = result['data'] ?? [];
  // Filter items where total_quantity < 10 (Assumed safety threshold)
  return inventory.where((item) {
    final qty = (item['total_quantity'] as num?)?.toDouble() ?? 0.0;
    return qty < 10 && qty > 0;
  }).toList();
});
