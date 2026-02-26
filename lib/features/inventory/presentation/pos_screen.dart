import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/core/supabase_client.dart';
import 'package:medistock_pro/features/inventory/repositories/sales_repository.dart';

import 'package:medistock_pro/features/inventory/services/pdf_service.dart';


final salesRepositoryProvider = Provider((ref) => SalesRepository(supabase));


class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final List<Map<String, dynamic>> _cart = [];
  final _customerNameController = TextEditingController(text: 'Walk-in Customer');
  final _customerPhoneController = TextEditingController();
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  double get _taxableTotal => _cart.fold(0, (sum, item) => sum + (item['taxable_value'] as double));
  double get _cgstTotal => _cart.fold(0, (sum, item) => sum + (item['cgst'] as double));
  double get _sgstTotal => _cart.fold(0, (sum, item) => sum + (item['sgst'] as double));
  double get _totalAmount => _taxableTotal + _cgstTotal + _sgstTotal;

  Future<void> _searchBatches(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await supabase
          .from('medi_batches')
          .select('*, medi_products(name, gst_percent)')
          .ilike('medi_products.name', '%$query%')
          .gt('quantity', 0)
          .limit(10);
      
      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(results);
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _addToCart(Map<String, dynamic> batch) {
    final product = batch['medi_products'];
    final gst = (product['gst_percent'] as num).toDouble();
    
    setState(() {
      _cart.add({
        'batch_id': batch['id'],
        'product_name': product['name'],
        'batch_no': batch['batch_no'],
        'qty': 1,
        'unit_price': (batch['selling_price'] ?? batch['mrp'] ?? 0.0) as double,
        'taxable_value': (batch['selling_price'] ?? batch['mrp'] ?? 0.0) as double,
        'cgst': ((batch['selling_price'] ?? batch['mrp'] ?? 0.0) * (gst / 200)),
        'sgst': ((batch['selling_price'] ?? batch['mrp'] ?? 0.0) * (gst / 200)),
        'max_qty': batch['quantity'],
      });
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;

    try {
      final saleInvoice = await ref.read(salesRepositoryProvider).createSale(
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        paymentMode: 'cash',
        items: _cart,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Sale Successful'),
            content: Text('Invoice #${saleInvoice.invoiceNumber} has been generated.'),
            actions: [
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Done'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Print Receipt'),
                onPressed: () async {
                  final file = await PDFService.generateSalesInvoicePDF(saleInvoice, _cart);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF Saved: ${file.path.split('/').last}')),
                  );
                },
              ),
            ],
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Billing')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: _searchBatches,
                  decoration: InputDecoration(
                    hintText: 'Search Product...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          if (_searchResults.isNotEmpty)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final res = _searchResults[index];
                  return ListTile(
                    title: Text(res['medi_products']['name']),
                    subtitle: Text('Batch: ${res['batch_no']} | Stock: ${res['quantity']}'),
                    trailing: Text('₹${res['selling_price'] ?? res['mrp']}'),
                    onTap: () => _addToCart(res),
                  );
                },
              ),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text('Batch: ${item['batch_no']}'),
                  trailing: SizedBox(
                    width: 150,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (item['qty'] > 1) {
                                item['qty']--;
                                // Recalculate based on new qty
                              } else {
                                _cart.removeAt(index);
                              }
                            });
                          },
                        ),
                        Text('${item['qty']}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (item['qty'] < item['max_qty']) {
                                item['qty']++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('₹${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Complete Sale & Print'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
