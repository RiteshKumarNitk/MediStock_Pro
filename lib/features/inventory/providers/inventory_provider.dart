import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';

class Product {
  final String id;
  final String name;
  final String barcode;

  Product({required this.id, required this.name, required this.barcode});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
    );
  }
}

class InventoryRepository {
  Future<String> _getTenantId() async {
     final user = supabase.auth.currentUser;
     if (user == null) throw Exception('Not logged in');
     
     final data = await supabase
        .from('profiles')
        .select('tenant_id')
        .eq('id', user.id)
        .single();
     return data['tenant_id'];
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('barcode', barcode)
        .maybeSingle();
    
    if (response == null) return null;
    return Product.fromJson(response);
  }

  Future<void> addProductAndBatch({
    required String barcode,
    required String name,
    required String batchNo,
    required DateTime expiryDate,
    required int quantity,
  }) async {
    final tenantId = await _getTenantId();

    // Check if product exists for this tenant (RLS handles visibility, but we check specific barcode)
    final productRes = await supabase
        .from('products')
        .select()
        .eq('barcode', barcode)
        .maybeSingle();

    String productId;
    if (productRes == null) {
      // Create new product
      final newProduct = await supabase
          .from('products')
          .insert({
            'tenant_id': tenantId,
            'name': name,
            'barcode': barcode,
          })
          .select()
          .single();
      productId = newProduct['id'];
    } else {
      productId = productRes['id'];
    }

    // Create batch
    await supabase.from('batches').insert({
      'tenant_id': tenantId,
      'product_id': productId,
      'batch_no': batchNo,
      'expiry_date': expiryDate.toIso8601String(),
      'quantity': quantity,
    });
  }
}

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());
