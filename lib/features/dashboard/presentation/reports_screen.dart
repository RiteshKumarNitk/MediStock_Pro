import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';
import 'package:intl/intl.dart';

final reportsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final sales = await supabase.from('medi_sales_invoices').select('total_amount, tax_amount');
  final purchases = await supabase.from('medi_purchase_invoices').select('total_amount, tax_amount');
  
  double totalSales = sales.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());
  double totalPurchases = purchases.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());
  double totalTax = sales.fold(0.0, (sum, item) => sum + (item['tax_amount'] as num).toDouble());
  
  return {
    'total_sales': totalSales,
    'total_purchases': totalPurchases,
    'total_tax': totalTax,
    'net_profit': totalSales - totalPurchases,
    'sales_count': sales.length,
    'purchase_count': purchases.length,
  };
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Reports')),
      body: reportsAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildReportCard('Total Sales', '₹${data['total_sales'].toStringAsFixed(2)}', Icons.trending_up, Colors.green, '${data['sales_count']} Invoices'),
              const SizedBox(height: 16),
              _buildReportCard('Total Purchases', '₹${data['total_purchases'].toStringAsFixed(2)}', Icons.trending_down, Colors.red, '${data['purchase_count']} Invoices'),
              const SizedBox(height: 16),
              _buildReportCard('Net Profit/Loss', '₹${data['net_profit'].toStringAsFixed(2)}', Icons.account_balance_wallet, data['net_profit'] >= 0 ? Colors.blue : Colors.orange, 'After ${data['sales_count'] + data['purchase_count']} Transactions'),
              const SizedBox(height: 24),
              const Text('Tax Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              _buildReportCard('Total GST Collected', '₹${data['total_tax'].toStringAsFixed(2)}', Icons.receipt_long, Colors.purple, 'Ready for Filing'),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
