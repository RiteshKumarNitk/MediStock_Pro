import 'package:medistock_pro/core/neon_client.dart';
import 'package:medistock_pro/features/inventory/models/sales.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

class SalesRepository {
  final AuthService _authService = AuthService();

  Future<SalesInvoice> createSale({
    required String customerName,
    required String customerPhone,
    required String paymentMode,
    required List<Map<String, dynamic>> items, // [{batch_id, qty, unit_price, taxable_value, cgst, sgst}]
  }) async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) throw Exception('User not authenticated');

    // 1. Calculate Totals
    double totalAmount = 0;
    double taxAmount = 0;
    for (var item in items) {
      totalAmount += (item['taxable_value'] + item['cgst'] + item['sgst']);
      taxAmount += (item['cgst'] + item['sgst']);
    }

    // 2. Create Sale Invoice
    final invoiceNumber = 'SALE-${DateTime.now().millisecondsSinceEpoch}';
    final invoiceResult = await neonClient.query(
      '''
      INSERT INTO medi_sales_invoices 
      (tenant_id, invoice_number, customer_name, customer_phone, total_amount, tax_amount, payment_mode)
      VALUES (@tenant_id, @invoice_number, @customer_name, @customer_phone, @total_amount, @tax_amount, @payment_mode)
      RETURNING *
      ''',
      substitutionValues: {
        'tenant_id': tenantId,
        'invoice_number': invoiceNumber,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'total_amount': totalAmount,
        'tax_amount': taxAmount,
        'payment_mode': paymentMode,
      },
    );

    final invoiceData = invoiceResult[0].toColumnMap();
    final String invoiceId = invoiceData['id'];

    // 3. Process Sale Items & Stock Movements
    for (var item in items) {
      // Save Sale Item
      await neonClient.query(
        '''
        INSERT INTO medi_sales_items (invoice_id, batch_id, qty, unit_price, taxable_value, cgst, sgst)
        VALUES (@invoice_id, @batch_id, @qty, @unit_price, @taxable_value, @cgst, @sgst)
        ''',
        substitutionValues: {
          'invoice_id': invoiceId,
          'batch_id': item['batch_id'],
          'qty': item['qty'],
          'unit_price': item['unit_price'],
          'taxable_value': item['taxable_value'],
          'cgst': item['cgst'],
          'sgst': item['sgst'],
        },
      );

      // Log Stock Movement (Outbound)
      await neonClient.query(
        '''
        INSERT INTO medi_stock_movements (tenant_id, batch_id, type, quantity, reference_id, reason)
        VALUES (@tenant_id, @batch_id, 'sale', @quantity, @reference_id, @reason)
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'batch_id': item['batch_id'],
          'quantity': -item['qty'], // Negative for sales
          'reference_id': invoiceId,
          'reason': 'Sale Invoice $invoiceNumber',
        },
      );
    }

    return SalesInvoice.fromJson(invoiceData);
  }

  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) return [];

    final result = await neonClient.query(
      'SELECT * FROM medi_sales_invoices WHERE tenant_id = @tenantId ORDER BY created_at DESC',
      substitutionValues: {'tenantId': tenantId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }
}
