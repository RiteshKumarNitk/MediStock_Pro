import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/core/app_theme.dart';

class OCRReviewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialData;

  const OCRReviewScreen({super.key, required this.initialData});

  @override
  ConsumerState<OCRReviewScreen> createState() => _OCRReviewScreenState();
}

class _OCRReviewScreenState extends ConsumerState<OCRReviewScreen> {
  late TextEditingController _invoiceNoController;
  late TextEditingController _vendorController;
  late TextEditingController _gstinController;
  late TextEditingController _taxAmountController;
  late List<Map<String, dynamic>> _items;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _invoiceNoController = TextEditingController(text: widget.initialData['invoice_number']);
    _vendorController = TextEditingController(text: widget.initialData['customer_name']);
    _gstinController = TextEditingController(text: widget.initialData['gstin']);
    _taxAmountController = TextEditingController(text: (widget.initialData['tax_amount'] ?? 0).toString());
    _items = List<Map<String, dynamic>>.from(widget.initialData['items']);
  }

  @override
  void dispose() {
    _invoiceNoController.dispose();
    _vendorController.dispose();
    _gstinController.dispose();
    _taxAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveInvoice() async {
    setState(() => _isSaving = true);
    try {
      final finalData = {
        ...widget.initialData,
        'invoice_number': _invoiceNoController.text,
        'customer_name': _vendorController.text,
        'gstin': _gstinController.text,
        'tax_amount': double.tryParse(_taxAmountController.text) ?? 0.0,
        'items': _items,
      };

      await ref.read(inventoryRepositoryProvider).savePurchaseInvoice(finalData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory updated successfully!')),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Extraction'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveInvoice,
            child: _isSaving 
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('General Info'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _invoiceNoController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Reference',
                      prefixIcon: Icon(Icons.numbers_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _vendorController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor / Supplier',
                      prefixIcon: Icon(Icons.business_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _gstinController,
                          decoration: const InputDecoration(
                            labelText: 'Vendor GSTIN',
                            prefixIcon: Icon(Icons.verified_user_rounded, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _taxAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tax Amount',
                            prefixIcon: Icon(Icons.receipt_long_rounded, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Items Found (${_items.length})'),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: item['product_name']?.toString() ?? '',
                        onChanged: (v) => _items[index]['product_name'] = v,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: Icon(Icons.medication_rounded, size: 20),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item['barcode']?.toString() ?? '',
                              onChanged: (v) => _items[index]['barcode'] = v,
                              decoration: const InputDecoration(
                                labelText: 'Barcode/ID',
                                prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: item['category']?.toString() ?? 'General',
                              onChanged: (v) => _items[index]['category'] = v,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_rounded, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item['hsn_code']?.toString() ?? '',
                              onChanged: (v) => _items[index]['hsn_code'] = v,
                              decoration: const InputDecoration(
                                labelText: 'HSN Code',
                                prefixIcon: Icon(Icons.tag_rounded, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: item['gst_percent']?.toString() ?? '12',
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _items[index]['gst_percent'] = double.tryParse(v) ?? 12.0,
                              decoration: const InputDecoration(
                                labelText: 'GST %',
                                prefixIcon: Icon(Icons.percent_rounded, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item['batch_no']?.toString() ?? '',
                              onChanged: (v) => _items[index]['batch_no'] = v,
                              decoration: const InputDecoration(
                                labelText: 'Batch',
                                prefixIcon: Icon(Icons.qr_code_rounded, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: item['qty']?.toString() ?? '0',
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _items[index]['qty'] = int.tryParse(v) ?? 0,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                prefixIcon: Icon(Icons.inventory_2_rounded, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item['expiry_date']?.toString() ?? '',
                              onChanged: (v) => _items[index]['expiry_date'] = v,
                              decoration: const InputDecoration(
                                labelText: 'Expiry Date',
                                prefixIcon: Icon(Icons.event_rounded, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: (item['purchase_price'] ?? item['rate'])?.toString() ?? '0.0',
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final val = double.tryParse(v) ?? 0.0;
                                _items[index]['purchase_price'] = val;
                                _items[index]['rate'] = val;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Pur. Price (₹)',
                                prefixIcon: Icon(Icons.shopping_cart_rounded, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item['mrp']?.toString() ?? '0.0',
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _items[index]['mrp'] = double.tryParse(v) ?? 0.0,
                              decoration: const InputDecoration(
                                labelText: 'MRP (₹)',
                                prefixIcon: Icon(Icons.money_rounded, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: item['selling_price']?.toString() ?? '0.0',
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _items[index]['selling_price'] = double.tryParse(v) ?? 0.0,
                              decoration: const InputDecoration(
                                labelText: 'Sell Price (₹)',
                                prefixIcon: Icon(Icons.sell_rounded, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 64),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRM & UPLOAD STOCK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
      ],
    );
  }
}
