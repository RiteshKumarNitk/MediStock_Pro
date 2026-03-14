import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_list_provider.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';
import 'package:intl/intl.dart';
import 'package:medistock_pro/core/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(inventoryListControllerProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryListControllerProvider);

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
                onChanged: (value) => ref.read(inventoryListControllerProvider.notifier).updateSearch(value),
                decoration: const InputDecoration(
                  hintText: 'Search medications...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading 
              ? _buildLoadingShimmer()
              : state.items.isEmpty
                ? _buildEmptyState(state.searchQuery)
                : RefreshIndicator(
                    onRefresh: () async => ref.read(inventoryListControllerProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = state.items[index];
                        final totalQuantity = product['total_quantity'] ?? 0;
                        final bool isLowStock = totalQuantity < 10;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.medication_rounded, color: AppTheme.primaryColor, size: 20),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product['name']?.toString() ?? 'Unknown Medication',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isLowStock ? 'LOW' : 'OK',
                                    style: TextStyle(
                                      color: isLowStock ? Colors.red : Colors.green,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'Barcode: ${product['barcode'] ?? 'N/A'} • ${product['category'] ?? 'General'}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product['displayPrice']?.toString() ?? '₹0',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryColor),
                                ),
                                Text(
                                  '$totalQuantity units',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            onTap: () => _showProductDetails(context, product),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.white,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            query.isEmpty ? 'Inventory is empty' : 'No matches found',
            style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final batches = (product['batches'] as List?) ?? [];
        final totalQuantity = product['total_quantity'] ?? 0;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.medication_rounded, color: AppTheme.primaryColor, size: 36),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name']?.toString() ?? 'Unknown',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${totalQuantity} In Stock',
                                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      const Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDetailRow('Barcode', product['barcode']?.toString() ?? 'N/A'),
                      _buildDetailRow('Category', product['category']?.toString() ?? 'General'),
                      _buildDetailRow('HSN Code', product['hsnCode']?.toString() ?? 'N/A'),
                      _buildDetailRow('GST Percent', '${product['gstPercent'] ?? 12}%'),
                      
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Batches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${batches.length} Batches', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (batches.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(30),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                          child: const Text('No batches in stock', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        )
                      else
                        ...batches.map((b) {
                          final expiryStr = b['expiryDate']?.toString();
                          DateTime? expiry;
                          if (expiryStr != null) {
                            try { expiry = DateTime.parse(expiryStr); } catch (_) {}
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Batch: ${b['batchNo'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Exp: ${expiry != null ? DateFormat('MMM yyyy').format(expiry) : 'N/A'}',
                                      style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${b['quantity'] ?? 0} units', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${b['sellingPrice'] ?? '0.0'}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Quick Restock via 'Add Stock'
                          context.pop(); 
                          context.push('/inventory/add?barcode=${product['barcode'] ?? ''}');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Add Stock', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Close bottom sheet and launch edit profile screen
                          context.pop();
                          context.push('/inventory/edit', extra: product);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Edit Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
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
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
