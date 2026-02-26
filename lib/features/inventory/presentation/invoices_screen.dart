import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/features/inventory/services/pdf_service.dart';
import 'package:medistock_pro/features/inventory/models/invoice.dart';

final invoicesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getPurchaseInvoices();

});

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoiceMap = invoices[index];
              final date = DateTime.parse(invoiceMap['created_at']);

              return Card(
                child: ListTile(
                  title: Text('Invoice #${invoiceMap['invoice_number']}'),
                  subtitle: Text('${invoiceMap['customer_name'] ?? 'Walk-in'} • ${DateFormat('dd MMM yyyy').format(date)}'),
                  trailing: Text('₹${invoiceMap['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => _showInvoiceDetails(context, ref, invoiceMap),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, WidgetRef ref, Map<String, dynamic> invoiceData) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: ref.read(inventoryRepositoryProvider).getPurchaseItems(invoiceData['id']),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final items = snapshot.data ?? [];
                
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice #${invoiceData['invoice_number']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            onPressed: () => _generateAndOpenPDF(context, invoiceData, items),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Customer: ${invoiceData['customer_name'] ?? 'N/A'}'),
                      Text('GSTIN: ${invoiceData['gstin'] ?? 'N/A'}'),
                      const Divider(height: 30),
                      const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            return ListTile(
                              dense: true,
                              title: Text(item['product_name']),
                              subtitle: Text('Batch: ${item['batch_no'] ?? 'N/A'} • Qty: ${item['qty']}'),
                              trailing: Text('₹${item['taxable_value']}'),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('₹${invoiceData['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _generateAndOpenPDF(BuildContext context, Map<String, dynamic> invoiceMap, List<Map<String, dynamic>> itemsList) async {
    try {
      // Map raw data to models
      final invoice = Invoice(
        id: invoiceMap['id'],
        tenantId: invoiceMap['tenant_id'],
        invoiceNumber: invoiceMap['invoice_number'],
        customerName: invoiceMap['customer_name'],
        gstin: invoiceMap['gstin'],
        totalAmount: (invoiceMap['total_amount'] as num).toDouble(),
        taxAmount: (invoiceMap['tax_amount'] as num).toDouble(),
        createdAt: DateTime.parse(invoiceMap['created_at']),
      );

      final items = itemsList.map((m) => InvoiceItem(
        id: m['id'],
        invoiceId: m['invoice_id'],
        productName: m['product_name'],
        batchNo: m['batch_no'],
        expiryDate: m['expiry_date'] != null ? DateTime.parse(m['expiry_date']) : null,
        qty: m['qty'],
        rate: (m['rate'] as num).toDouble(),
        taxableValue: (m['taxable_value'] as num).toDouble(),
      )).toList();

      final file = await PDFService.generatePurchaseInvoicePDF(invoice, items);

      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Generated: ${file.path.split('/').last}')),
      );
      
      // Note: In real app, we would use printing or open_file package to open it.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }
}
