import 'package:medistock_pro/core/neon_client.dart';
import 'package:medistock_pro/features/inventory/models/product.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

class InventoryRepository {
  final AuthService _authService = AuthService();

  Future<List<Product>> getProducts() async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) return [];

    final result = await neonClient.query(
      'SELECT * FROM medi_products WHERE tenant_id = @tenantId',
      substitutionValues: {'tenantId': tenantId},
    );
    
    return result.map((row) {
      final json = row.toColumnMap();
      return Product.fromJson(json);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getInventoryWithTotalQty() async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) return [];

    // Joining products and batches to get total quantity
    final result = await neonClient.query(
      '''
      SELECT p.*, COALESCE(SUM(b.quantity), 0) as total_quantity
      FROM medi_products p
      LEFT JOIN medi_batches b ON p.id = b.product_id
      WHERE p.tenant_id = @tenantId
      GROUP BY p.id
      ORDER BY p.name
      ''',
      substitutionValues: {'tenantId': tenantId},
    );
    
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> savePurchaseInvoice(Map<String, dynamic> data) async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) throw Exception('User not authenticated');

    // 1. Create Purchase Invoice
    final invoiceResult = await neonClient.query(
      '''
      INSERT INTO medi_purchase_invoices 
      (tenant_id, invoice_number, vendor_name, vendor_gstin, total_amount, tax_amount, image_url)
      VALUES (@tenant_id, @invoice_number, @vendor_name, @vendor_gstin, @total_amount, @tax_amount, @image_url)
      RETURNING id
      ''',
      substitutionValues: {
        'tenant_id': tenantId,
        'invoice_number': data['invoice_number'],
        'vendor_name': data['vendor_name'] ?? data['customer_name'],
        'vendor_gstin': data['vendor_gstin'] ?? data['gstin'],
        'total_amount': data['total_amount'],
        'tax_amount': data['tax_amount'] ?? 0,
        'image_url': data['image_url'],
      },
    );

    final String invoiceId = invoiceResult[0][0].toString();

    // 2. Process Items
    final List items = data['items'];
    for (var item in items) {
      // Upsert Product (Postgres syntax for upsert: ON CONFLICT)
      final productResult = await neonClient.query(
        '''
        INSERT INTO medi_products (tenant_id, barcode, name, gst_percent, hsn_code)
        VALUES (@tenant_id, @barcode, @name, @gst_percent, @hsn_code)
        ON CONFLICT (tenant_id, name) DO UPDATE SET
          barcode = EXCLUDED.barcode,
          gst_percent = EXCLUDED.gst_percent,
          hsn_code = EXCLUDED.hsn_code
        RETURNING id
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'barcode': item['barcode'] ?? ('SCAN-' + item['product_name'].hashCode.toString()),
          'name': item['product_name'],
          'gst_percent': item['gst_percent'] ?? 12,
          'hsn_code': item['hsn_code'],
        },
      );
      final productId = productResult[0][0];

      // Insert Batch 
      final batchResult = await neonClient.query(
        '''
        INSERT INTO medi_batches (tenant_id, product_id, batch_no, expiry_date, purchase_price)
        VALUES (@tenant_id, @product_id, @batch_no, @expiry_date, @purchase_price)
        RETURNING id
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'product_id': productId,
          'batch_no': item['batch_no'],
          'expiry_date': item['expiry_date'],
          'purchase_price': item['rate'],
        },
      );
      final batchId = batchResult[0][0];

      // Log Stock Movement (Ledger) - Trigger will update medi_batches.quantity
      await neonClient.query(
        '''
        INSERT INTO medi_stock_movements (tenant_id, batch_id, type, quantity, reference_id, reason)
        VALUES (@tenant_id, @batch_id, 'purchase', @quantity, @reference_id, @reason)
        ''',
        substitutionValues: {
          'tenant_id': tenantId,
          'batch_id': batchId,
          'quantity': item['qty'],
          'reference_id': invoiceId,
          'reason': 'Purchase Invoice ${data['invoice_number']}',
        },
      );

      // Save Purchase Item record
      await neonClient.query(
        '''
        INSERT INTO medi_purchase_items (invoice_id, product_id, batch_no, qty, rate, taxable_value, cgst, sgst)
        VALUES (@invoice_id, @product_id, @batch_no, @qty, @rate, @taxable_value, @cgst, @sgst)
        ''',
        substitutionValues: {
          'invoice_id': invoiceId,
          'product_id': productId,
          'batch_no': item['batch_no'],
          'qty': item['qty'],
          'rate': item['rate'],
          'taxable_value': item['taxable_value'],
          'cgst': (item['taxable_value'] * (item['gst_percent'] ?? 12) / 200), 
          'sgst': (item['taxable_value'] * (item['gst_percent'] ?? 12) / 200),
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPurchaseInvoices() async {
    final tenantId = await _authService.getTenantId();
    if (tenantId == null) return [];

    final result = await neonClient.query(
      'SELECT * FROM medi_purchase_invoices WHERE tenant_id = @tenantId ORDER BY created_at DESC',
      substitutionValues: {'tenantId': tenantId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<List<Map<String, dynamic>>> getPurchaseItems(String invoiceId) async {
    final result = await neonClient.query(
      '''
      SELECT pi.*, p.name as product_name 
      FROM medi_purchase_items pi
      JOIN medi_products p ON pi.product_id = p.id
      WHERE pi.invoice_id = @invoiceId
      ''',
      substitutionValues: {'invoiceId': invoiceId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }
}
