import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';
import 'package:medistock_pro/features/inventory/models/expiry_alert.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository(supabase));

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final response = await supabase.from('medi_expiry_alerts').select();
  return (response as List).map((json) => ExpiryAlert.fromJson(json)).toList();
});

final productsProvider = FutureProvider((ref) {
  return ref.watch(inventoryRepositoryProvider).getProducts();
});
