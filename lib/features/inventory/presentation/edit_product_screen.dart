import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/core/app_theme.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _categoryController;
  late TextEditingController _hsnCodeController;
  late TextEditingController _gstPercentController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']?.toString() ?? '');
    _barcodeController = TextEditingController(text: widget.product['barcode']?.toString() ?? '');
    _categoryController = TextEditingController(text: widget.product['category']?.toString() ?? 'General');
    _hsnCodeController = TextEditingController(text: widget.product['hsnCode']?.toString() ?? '');
    _gstPercentController = TextEditingController(text: (widget.product['gstPercent'] ?? 12.0).toString());
    
    // Find price from displayPrice or batches if available (displayPrice format is '₹X' or '₹X - ₹Y')
    // For simplicity, we can try to find the latest batch price
    final batches = (widget.product['batches'] as List?) ?? [];
    if (batches.isNotEmpty) {
      final latestBatch = batches.last;
      _purchasePriceController = TextEditingController(text: (latestBatch['purchasePrice'] ?? '').toString());
      _sellingPriceController = TextEditingController(text: (latestBatch['sellingPrice'] ?? '').toString());
    } else {
      _purchasePriceController = TextEditingController();
      _sellingPriceController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _hsnCodeController.dispose();
    _gstPercentController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.put('/products/${widget.product['id']}', {
        'name': _nameController.text.trim(),
        'barcode': _barcodeController.text.trim(),
        'category': _categoryController.text.trim(),
        'hsnCode': _hsnCodeController.text.trim(),
        'gstPercent': double.tryParse(_gstPercentController.text.trim()) ?? 12.0,
        'purchasePrice': double.tryParse(_purchasePriceController.text.trim()),
        'sellingPrice': double.tryParse(_sellingPriceController.text.trim()),
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!'), backgroundColor: Colors.green),
          );
          ref.invalidate(lowStockProvider);
          ref.invalidate(productsProvider);
          ref.invalidate(expiryAlertsProvider);
          // Also invalidate the inventory list provider from inventory_screen.dart
          // (It's not explicitly exported but invalidated via these repositories usually)
          
          context.pop(); 
        }
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Medication Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Product Details'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        prefixIcon: Icon(Icons.medication_rounded),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode / ID',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hsnCodeController,
                            decoration: const InputDecoration(
                              labelText: 'HSN Code',
                              prefixIcon: Icon(Icons.numbers_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _gstPercentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'GST %',
                              prefixIcon: Icon(Icons.percent_rounded),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Standard Pricing'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Price',
                          prefixIcon: Icon(Icons.shopping_cart_rounded),
                          prefixText: '₹',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price',
                          prefixIcon: Icon(Icons.sell_rounded),
                          prefixText: '₹',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 64),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
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
