import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_provider.dart';
import 'package:medistock_pro/core/app_theme.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final String? scannedBarcode;

  const AddProductScreen({super.key, this.scannedBarcode});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _barcodeController;
  final _nameController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  DateTime? _expiryDate;
  
  bool _isLoading = false;
  bool _isNewProduct = true;

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _batchNoController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.scannedBarcode);
    if (widget.scannedBarcode != null) {
      _checkBarcode(widget.scannedBarcode!);
    }
  }

  Future<void> _checkBarcode(String barcode) async {
    final notifier = ref.read(inventoryProvider.notifier);
    try {
      final product = await notifier.getProductByBarcode(barcode);
      if (product != null) {
        setState(() {
          _nameController.text = product['name'];
          _isNewProduct = false;
        });
      }
    } catch (e) {
      // Treat as new
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select expiry date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(inventoryProvider.notifier);
      await notifier.addStock(
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        batchNo: _batchNoController.text.trim(),
        expiryDate: _expiryDate!,
        quantity: int.parse(_quantityController.text.trim()),
        purchasePrice: double.tryParse(_purchasePriceController.text.trim()),
        sellingPrice: double.tryParse(_sellingPriceController.text.trim()),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory updated successfully!')),
        );
        context.pop();
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
        title: const Text('Add Physical Stock'),
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
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode / ID',
                        prefixIcon: const Icon(Icons.qr_code_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
                          onPressed: () async {
                            final code = await context.push<String>('/inventory/scan');
                            if (code != null) {
                              _barcodeController.text = code;
                              _checkBarcode(code);
                            }
                          },
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onChanged: (v) {
                        if (v.length > 3) _checkBarcode(v);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        prefixIcon: Icon(Icons.medication_rounded),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      readOnly: !_isNewProduct, 
                      enabled: _isNewProduct,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Batch Information'),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _batchNoController,
                            decoration: const InputDecoration(
                              labelText: 'Batch No',
                              prefixIcon: Icon(Icons.numbers_rounded),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Expiry',
                                prefixIcon: Icon(Icons.event_rounded),
                              ),
                              child: Text(
                                _expiryDate == null
                                    ? 'Select Date'
                                    : DateFormat('MMM yyyy').format(_expiryDate!),
                                style: TextStyle(
                                  color: _expiryDate == null ? Colors.black45 : Colors.black87,
                                  fontWeight: _expiryDate == null ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'In-Hand Quantity',
                        prefixIcon: Icon(Icons.inventory_2_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
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
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 64),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CONFIRM & ADD STOCK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 40),
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
