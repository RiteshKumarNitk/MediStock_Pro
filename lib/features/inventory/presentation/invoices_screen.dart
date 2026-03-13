import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/features/inventory/services/pdf_service.dart';
import 'package:medistock_pro/features/inventory/models/invoice.dart';
import 'package:medistock_pro/core/app_theme.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Invoice History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {}, // Implementation later
          ),
        ],
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No invoices recorded yet.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoiceMap = invoices[index];
              final date = DateTime.parse(invoiceMap['created_at']);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor),
                  ),
                  title: Text(
                    'Invoice #${invoiceMap['invoice_number']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${invoiceMap['customer_name'] ?? 'Walk-in'} • ${DateFormat('dd MMM yyyy').format(date)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${invoiceMap['total_amount']}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryColor),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                    ],
                  ),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: ref.read(inventoryRepositoryProvider).getPurchaseItems(invoiceData['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final items = snapshot.data ?? [];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Invoice Detail', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('#${invoiceData['invoice_number']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                                  onPressed: () => _generateAndOpenPDF(context, invoiceData, items),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow('Vendor/Partner', invoiceData['customer_name'] ?? 'N/A'),
                          _buildDetailRow('GSTIN Reference', invoiceData['gstin'] ?? 'N/A'),
                          const Divider(height: 48),
                          const Text('ITEMS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.grey)),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: items.length,
                              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade50),
                              itemBuilder: (context, idx) {
                                final item = items[idx];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item['product_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Batch: ${item['batch_no'] ?? 'N/A'} • Qty: ${item['qty']}'),
                                  trailing: Text('₹${item['taxable_value']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text('₹${invoiceData['total_amount']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.primaryColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _generateAndOpenPDF(BuildContext context, Map<String, dynamic> invoiceMap, List<Map<String, dynamic>> itemsList) async {
    try {
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Generated: ${file.path.split('/').last}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }
}
