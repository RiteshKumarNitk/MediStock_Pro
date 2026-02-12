import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';

class InventoryProvider extends StateNotifier<bool> {
  InventoryProvider() : super(false);

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final data = await supabase
        .from('medi_products')
        .select()
        .eq('barcode', barcode)
        .maybeSingle();
    return data;
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
      // 1. Get current user profile to get tenant_id
      final profile = await supabase
          .from('medi_profiles')
          .select('tenant_id')
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      
      final String tenantId = profile['tenant_id'];

      // 2. Upsert Product
      final product = await supabase.from('medi_products').upsert({
        'tenant_id': tenantId,
        'barcode': barcode,
        'name': name,
      }).select().single();

      // 3. Add Batch
      await supabase.from('medi_batches').insert({
        'tenant_id': tenantId,
        'product_id': product['id'],
        'batch_no': batchNo,
        'expiry_date': expiryDate.toIso8601String(),
        'quantity': quantity,
        'purchase_price': purchasePrice,
        'selling_price': sellingPrice,
      });
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
