import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/core/supabase_client.dart';

final inventoryListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await supabase
      .from('medi_products')
      .select('*, medi_batches(quantity)') // Updated to medi_batches
      .order('name');
  return List<Map<String, dynamic>>.from(data);
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      drawer: Drawer(
         child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
             ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => context.go('/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () => context.pop(), 
            ),
             const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                 await supabase.auth.signOut();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/inventory/add'),
        child: const Icon(Icons.add),
      ),
      body: inventoryAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found. Add some stock!'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final batches = product['medi_batches'] as List; // Updated key
              final totalQuantity = batches.fold<int>(0, (sum, b) => sum + (b['quantity'] as int));

              return ListTile(
                title: Text(product['name']),
                subtitle: Text('Barcode: ${product['barcode']}'),
                trailing: Chip(label: Text('Qty: $totalQuantity')),
                onTap: () {
                  // TODO: View product details
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
