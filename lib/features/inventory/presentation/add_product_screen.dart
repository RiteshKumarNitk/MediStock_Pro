import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_provider.dart';

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
  DateTime? _expiryDate;
  
  bool _isLoading = false;
  bool _isNewProduct = true;

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
          _isNewProduct = false; // Product exists
        });
      }
    } catch (e) {
      // Ignore error, treat as new
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
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

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(inventoryProvider.notifier);
      await notifier.addStock(
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        batchNo: _batchNoController.text.trim(),
        expiryDate: _expiryDate!,
        quantity: int.parse(_quantityController.text.trim()),
        purchasePrice: null, // Optional for now
        sellingPrice: null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')),
        );
        context.pop(); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Stock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                readOnly: !_isNewProduct, 
                enabled: _isNewProduct,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchNoController,
                      decoration: const InputDecoration(labelText: 'Batch No'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Expiry Date'),
                        child: Text(
                          _expiryDate == null
                              ? 'Select Date'
                              : DateFormat('MMM yyyy').format(_expiryDate!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                 validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
