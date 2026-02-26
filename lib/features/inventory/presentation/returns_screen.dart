import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';
import 'package:intl/intl.dart';

class ReturnsManagementScreen extends ConsumerWidget {
  const ReturnsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returns Management')),
      body: FutureBuilder(
        future: supabase.from('medi_returns').select('*, medi_batches(*)'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final returns = snapshot.data as List;

          if (returns.isEmpty) {
            return const Center(child: Text('No return records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final ret = returns[index];
              final batch = ret['medi_batches'];
              final status = ret['status'] as String;

              return Card(
                child: ListTile(
                  title: Text('Return ID: ${ret['id'].toString().substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batch: ${batch['batch_no']}'),
                      if (ret['reason'] != null) Text('Reason: ${ret['reason']}'),
                      Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(ret['created_at']))}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open dialog to select batch for return
        },
        label: const Text('Log New Return'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'returned': return Colors.green;
      case 'expired': return Colors.red;
      default: return Colors.grey;
    }
  }
}
