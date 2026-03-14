import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/repositories/sales_repository.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';
import 'package:medistock_pro/features/inventory/services/pdf_service.dart';
import 'package:medistock_pro/core/app_theme.dart';

final salesRepositoryProvider = Provider((ref) => SalesRepository());

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

  double get _taxableTotal => _cart.fold(0, (sum, item) => sum + (((item['unit_price'] ?? 0.0) as double) * (item['qty'] as int)));
  double get _cgstTotal => _cart.fold(0, (sum, item) => sum + (((item['cgst'] ?? 0.0) as double) * (item['qty'] as int)));
  double get _sgstTotal => _cart.fold(0, (sum, item) => sum + (((item['sgst'] ?? 0.0) as double) * (item['qty'] as int)));
  double get _totalAmount => _taxableTotal + _cgstTotal + _sgstTotal;

  Future<void> _searchBatches(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final response = await ApiClient.get('/batches?query=$query&inStock=true');
      if (response.statusCode != 200) return;

      final Map<String, dynamic> decoded = jsonDecode(response.body);
      if (decoded['success'] != true) return;
      final List data = decoded['data'] ?? [];
      
      setState(() {
        _searchResults = data.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            ...map,
            'medi_products': {
              'name': map['product']?['name'] ?? 'Unknown Item',
              'gst_percent': map['product']?['gstPercent'] ?? 0,
            }
          };
        }).toList().cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _addToCart(Map<String, dynamic> batch) {
    final product = batch['medi_products'] ?? {'name': 'Unknown', 'gst_percent': 0};
    final gst = (product['gst_percent'] as num?)?.toDouble() ?? 0.0;
    final price = (batch['selling_price'] ?? batch['mrp'] ?? 0.0) as double;
    
    setState(() {
      _cart.add({
        'batch_id': batch['id'],
        'product_name': product['name'] ?? 'Unknown Item',
        'batch_no': batch['batch_no'] ?? 'N/A',
        'qty': 1,
        'unit_price': price,
        'taxable_value': price,
        'cgst': (price * (gst / 200)),
        'sgst': (price * (gst / 200)),
        'max_qty': batch['quantity'] ?? 1,
      });
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;

    try {
      final saleInvoice = await ref.read(salesRepositoryProvider).createSale(
        customerName: _customerNameController.text.isEmpty ? 'Walk-in Customer' : _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        paymentMode: 'cash',
        items: _cart.map((item) {
          final qty = item['qty'] as int;
          final unitPrice = item['unit_price'] as double;
          final cgstPerUnit = (item['cgst'] ?? 0.0) as double;
          final sgstPerUnit = (item['sgst'] ?? 0.0) as double;
          
          return {
            ...item,
            'taxable_value': unitPrice * qty,
            'cgst': cgstPerUnit * qty,
            'sgst': sgstPerUnit * qty,
          };
        }).toList(),
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 12),
                Text('Sale Complete'),
              ],
            ),
            content: Text('Invoice #${saleInvoice.invoiceNumber ?? 'N/A'} has been generated successfully.'),
            actions: [
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.print_rounded),
                label: const Text('Print Receipt'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                onPressed: () async {
                  final file = await PDFService.generateSalesInvoicePDF(saleInvoice, _cart);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF Generated: ${file.path.split('/').last}')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('New Sale (POS)'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Customer & Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_rounded, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _searchBatches,
                  decoration: InputDecoration(
                    hintText: 'Search medication or batch...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    suffixIcon: _isSearching 
                      ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) 
                      : null,
                    filled: true,
                    fillColor: AppTheme.primaryColor.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Stack(
              children: [
                // Cart Items List
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(item['product_name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Batch: ${item['batch_no'] ?? 'N/A'} | ₹${item['unit_price']}/unit'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.black45),
                              onPressed: () => setState(() {
                                if (item['qty'] > 1) {
                                  item['qty']--;
                                } else {
                                  _cart.removeAt(index);
                                }
                              }),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                              onPressed: () => setState(() {
                                if (item['qty'] < (item['max_qty'] ?? 1)) {
                                  item['qty']++;
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Search Results Overlay
                if (_searchResults.isNotEmpty)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.05),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final res = _searchResults[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.add_box_rounded, color: AppTheme.primaryColor),
                                ),
                                title: Text(res['medi_products']?['name']?.toString() ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Batch: ${res['batch_no'] ?? 'N/A'} | Stock: ${res['quantity'] ?? 0}', style: TextStyle(color: Colors.grey.shade600)),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('₹${res['selling_price'] ?? res['mrp'] ?? 0.0}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor, fontSize: 16)),
                                  ],
                                ),
                                onTap: () => _addToCart(res),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Receipt Style Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Items:', style: TextStyle(color: Colors.black54)),
                    Text('${_cart.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Payable', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    Text('₹${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text('PROCESS PAYMENT & PRINT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
