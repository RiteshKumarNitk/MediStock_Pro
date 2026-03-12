import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/neon_client.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

class InventoryProvider extends StateNotifier<bool> {
  InventoryProvider() : super(false);

  final _authService = AuthService();

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) return null;

    final result = await neonClient.query(
      'SELECT * FROM medi_products WHERE tenant_id = @tenantId AND barcode = @barcode',
      substitutionValues: {
        'tenantId': tenantId,
        'barcode': barcode,
      },
    );
    
    if (result.isEmpty) return null;
    return result[0].toColumnMap();
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
      final tenantId = await _authService.getTenantId();
      if (tenantId == null) throw Exception('User not authenticated');

      // 2. Upsert Product
      final productResult = await neonClient.query(
        '''
        INSERT INTO medi_products (tenant_id, barcode, name)
        VALUES (@tenant_id, @barcode, @name)
        ON CONFLICT (tenant_id, barcode) DO UPDATE SET name = EXCLUDED.name
        RETURNING id
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'barcode': barcode,
          'name': name,
        },
      );
      final productId = productResult[0][0];

      // 3. Add Batch
      final batchResult = await neonClient.query(
        '''
        INSERT INTO medi_batches (tenant_id, product_id, batch_no, expiry_date, quantity, purchase_price, selling_price)
        VALUES (@tenant_id, @product_id, @batch_no, @expiry_date, @quantity, @purchase_price, @selling_price)
        RETURNING id
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'product_id': productId,
          'batch_no': batchNo,
          'expiry_date': expiryDate.toIso8601String(),
          'quantity': quantity,
          'purchase_price': purchasePrice,
          'selling_price': sellingPrice,
        },
      );
      final batchId = batchResult[0][0];

      // 4. Log Stock Movement
      await neonClient.query(
        '''
        INSERT INTO medi_stock_movements (tenant_id, batch_id, type, quantity, reason)
        VALUES (@tenant_id, @batch_id, 'manual_adjustment', @quantity, 'Initial stock entry')
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'batch_id': batchId,
          'quantity': quantity,
        },
      );
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
