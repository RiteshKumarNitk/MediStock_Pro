import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';

class OCRReviewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialData;

  const OCRReviewScreen({super.key, required this.initialData});

  @override
  ConsumerState<OCRReviewScreen> createState() => _OCRReviewScreenState();
}

class _OCRReviewScreenState extends ConsumerState<OCRReviewScreen> {
  late TextEditingController _invoiceNoController;
  late TextEditingController _vendorController;
  late List<Map<String, dynamic>> _items;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _invoiceNoController = TextEditingController(text: widget.initialData['invoice_number']);
    _vendorController = TextEditingController(text: widget.initialData['customer_name']);
    _items = List<Map<String, dynamic>>.from(widget.initialData['items']);
  }

  @override
  void dispose() {
    _invoiceNoController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  Future<void> _saveInvoice() async {
    setState(() => _isSaving = true);
    try {
      final finalData = {
        ...widget.initialData,
        'invoice_number': _invoiceNoController.text,
        'customer_name': _vendorController.text,
        'items': _items,
      };

      await ref.read(inventoryRepositoryProvider).savePurchaseInvoice(finalData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice saved successfully!')),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Scanned Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invoice Header', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _invoiceNoController,
              decoration: const InputDecoration(labelText: 'Invoice Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vendorController,
              decoration: const InputDecoration(labelText: 'Vendor Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: item['product_name'],
                          onChanged: (v) => _items[index]['product_name'] = v,
                          decoration: const InputDecoration(labelText: 'Product Name'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item['batch_no'],
                                onChanged: (v) => _items[index]['batch_no'] = v,
                                decoration: const InputDecoration(labelText: 'Batch'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: item['qty'].toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => _items[index]['qty'] = int.tryParse(v) ?? 0,
                                decoration: const InputDecoration(labelText: 'Qty'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item['expiry_date'],
                                onChanged: (v) => _items[index]['expiry_date'] = v,
                                decoration: const InputDecoration(labelText: 'Expiry (YYYY-MM-DD)'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: item['rate'].toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => _items[index]['rate'] = double.tryParse(v) ?? 0.0,
                                decoration: const InputDecoration(labelText: 'Rate (₹)'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveInvoice,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Save Stock'),
            ),
          ],
        ),
      ),
    );
  }
}
