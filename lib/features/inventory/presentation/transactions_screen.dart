import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/core/app_theme.dart';

final ledgerProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).getLedger();
});

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Transaction Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(ledgerProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ledgerAsync.when(
              data: (transactions) {
                final filtered = _selectedFilter == 'All'
                    ? transactions
                    : transactions.where((tx) => 
                        (tx['transaction_type'] == 'sale' && _selectedFilter == 'Sales') ||
                        (tx['transaction_type'] == 'purchase' && _selectedFilter == 'Purchases')
                      ).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    final isSale = tx['transaction_type'] == 'sale';
                    final date = tx['createdAt'] != null 
                        ? DateTime.parse(tx['createdAt']) 
                        : DateTime.now();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                            color: (isSale ? Colors.green : Colors.blue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isSale ? Icons.trending_up_rounded : Icons.shopping_cart_checkout_rounded,
                            color: isSale ? Colors.green : Colors.blue,
                          ),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isSale ? Colors.green : Colors.blue).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isSale ? 'SALE' : 'PURCHASE',
                                style: TextStyle(
                                  color: isSale ? Colors.green : Colors.blue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Inv #${tx['invoiceNumber']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${tx['customerName'] ?? 'Walk-in'} • ${DateFormat('dd MMM, hh:mm a').format(date)}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${tx['totalAmount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 16, 
                                color: isSale ? Colors.green.shade700 : Colors.blue.shade700
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          // TODO: Show Details
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 8),
          _buildFilterChip('Sales'),
          const SizedBox(width: 8),
          _buildFilterChip('Purchases'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No transactions recorded yet.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
