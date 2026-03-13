import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';
import 'package:medistock_pro/core/app_theme.dart';

final inventoryListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).getInventoryWithTotalQty();
});

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  final _authService = AuthService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Library'),
        centerTitle: true,
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/inventory/add'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
      body: Column(
        children: [
          // Elevated Search Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search medications...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
          Expanded(
            child: inventoryAsync.when(
              data: (products) {
                final filteredProducts = products.where((p) {
                  final name = p['name'].toString().toLowerCase();
                  final barcode = p['barcode'].toString().toLowerCase();
                  return name.contains(_searchQuery) || barcode.contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 24),
                        Text(
                          _searchQuery.isEmpty ? 'Inventory is empty' : 'No matches found',
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final totalQuantity = product['total_quantity'] ?? 0;
                    final bool isLowStock = totalQuantity < 10;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.medication_rounded, color: AppTheme.primaryColor),
                        ),
                        title: Text(
                          product['name']?.toString() ?? 'Unknown Medication',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Barcode: ${product['barcode'] ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isLowStock ? 'LOW STOCK' : 'IN STOCK',
                                style: TextStyle(
                                  color: isLowStock ? Colors.red : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalQuantity units',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
