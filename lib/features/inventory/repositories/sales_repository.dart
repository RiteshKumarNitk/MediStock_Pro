import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medistock_pro/features/inventory/models/sales.dart';

class SalesRepository {
  final SupabaseClient _client;

  SalesRepository(this._client);

  Future<SalesInvoice> createSale({
    required String customerName,
    required String customerPhone,
    required String paymentMode,
    required List<Map<String, dynamic>> items, // [{batch_id, qty, unit_price, taxable_value, cgst, sgst}]
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final profile = await _client
        .from('medi_profiles')
        .select('tenant_id')
        .eq('id', user.id)
        .single();
    
    final String tenantId = profile['tenant_id'];

    // 1. Calculate Totals
    double totalAmount = 0;
    double taxAmount = 0;
    for (var item in items) {
      totalAmount += (item['taxable_value'] + item['cgst'] + item['sgst']);
      taxAmount += (item['cgst'] + item['sgst']);
    }

    // 2. Create Sale Invoice
    final invoiceResp = await _client.from('medi_sales_invoices').insert({
      'tenant_id': tenantId,
      'invoice_number': 'SALE-${DateTime.now().millisecondsSinceEpoch}',
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'payment_mode': paymentMode,
    }).select().single();

    final String invoiceId = invoiceResp['id'];
    final createdInvoice = SalesInvoice.fromJson(invoiceResp);

    // 3. Process Sale Items & Stock Movements
    for (var item in items) {
      // Save Sale Item
      await _client.from('medi_sales_items').insert({
        'invoice_id': invoiceId,
        'batch_id': item['batch_id'],
        'qty': item['qty'],
        'unit_price': item['unit_price'],
        'taxable_value': item['taxable_value'],
        'cgst': item['cgst'],
        'sgst': item['sgst'],
      });

      // Log Stock Movement (Outbound)
      await _client.from('medi_stock_movements').insert({
        'tenant_id': tenantId,
        'batch_id': item['batch_id'],
        'type': 'sale',
        'quantity': -item['qty'], // Negative for sales
        'reference_id': invoiceId,
        'reason': 'Sale Invoice ${invoiceResp['invoice_number']}',
      });
    }

    return createdInvoice;
  }

  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    final response = await _client
        .from('medi_sales_invoices')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
