import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/models/expiry_alert.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final response = await ApiClient.get('/reports?type=inventory'); // Assume inventory report returns batch data
  if (response.statusCode != 200) return [];
  
  final List data = jsonDecode(response.body);
  // Map relevant parts to ExpiryAlert
  return data.map((item) => ExpiryAlert.fromJson(item)).toList();
});

final productsProvider = FutureProvider((ref) {
  return ref.watch(inventoryRepositoryProvider).getProducts();
});
