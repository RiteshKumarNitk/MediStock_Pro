import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medistock_pro/features/inventory/models/product.dart';


class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository(this._client);

  Future<List<Product>> getProducts() async {
    final response = await _client.from('medi_products').select();
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getInventoryWithTotalQty() async {
    final data = await _client
        .from('medi_products')
        .select('*, medi_batches(quantity)')
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> savePurchaseInvoice(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final profile = await _client
        .from('medi_profiles')
        .select('tenant_id')
        .eq('id', user.id)
        .single();
    
    final String tenantId = profile['tenant_id'];

    // 1. Create Purchase Invoice
    final invoiceResp = await _client.from('medi_purchase_invoices').insert({
      'tenant_id': tenantId,
      'invoice_number': data['invoice_number'],
      'vendor_name': data['vendor_name'] ?? data['customer_name'],
      'vendor_gstin': data['vendor_gstin'] ?? data['gstin'],
      'total_amount': data['total_amount'],
      'tax_amount': data['tax_amount'] ?? 0,
      'image_url': data['image_url'],
    }).select().single();

    final String invoiceId = invoiceResp['id'];

    // 2. Process Items
    final List items = data['items'];
    for (var item in items) {
      // Upsert Product
      final product = await _client.from('medi_products').upsert({
        'tenant_id': tenantId,
        'barcode': item['barcode'] ?? ('SCAN-' + item['product_name'].hashCode.toString()),
        'name': item['product_name'],
        'gst_percent': item['gst_percent'] ?? 12,
        'hsn_code': item['hsn_code'],
      }).select().single();

      // Upsert Batch (Batch No + Product ID should be unique enough or we create new)
      final batch = await _client.from('medi_batches').upsert({
        'tenant_id': tenantId,
        'product_id': product['id'],
        'batch_no': item['batch_no'],
        'expiry_date': item['expiry_date'],
        'purchase_price': item['rate'],
      }).select().single();

      // Log Stock Movement (Ledger) - Trigger will update medi_batches.quantity
      await _client.from('medi_stock_movements').insert({
        'tenant_id': tenantId,
        'batch_id': batch['id'],
        'type': 'purchase',
        'quantity': item['qty'],
        'reference_id': invoiceId,
        'reason': 'Purchase Invoice ${data['invoice_number']}',
      });

      // Save Purchase Item record
      await _client.from('medi_purchase_items').insert({
        'invoice_id': invoiceId,
        'product_id': product['id'],
        'batch_no': item['batch_no'],
        'qty': item['qty'],
        'rate': item['rate'],
        'taxable_value': item['taxable_value'],
        'cgst': (item['taxable_value'] * (item['gst_percent'] ?? 12) / 200), 
        'sgst': (item['taxable_value'] * (item['gst_percent'] ?? 12) / 200),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getPurchaseInvoices() async {
    final response = await _client
        .from('medi_purchase_invoices')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPurchaseItems(String invoiceId) async {
    final response = await _client
        .from('medi_purchase_items')
        .select('*, medi_products(name)')
        .eq('invoice_id', invoiceId);
    return List<Map<String, dynamic>>.from(response);
  }
}
