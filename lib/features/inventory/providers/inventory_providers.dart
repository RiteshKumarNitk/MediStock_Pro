import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/neon_client.dart';
import 'package:medistock_pro/features/inventory/models/expiry_alert.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final result = await neonClient.query(
    'SELECT * FROM medi_expiry_alerts', // Assuming view exists or we fetch from batches
  );
  return result.map((row) => ExpiryAlert.fromJson(row.toColumnMap())).toList();
});

final productsProvider = FutureProvider((ref) {
  return ref.watch(inventoryRepositoryProvider).getProducts();
});
