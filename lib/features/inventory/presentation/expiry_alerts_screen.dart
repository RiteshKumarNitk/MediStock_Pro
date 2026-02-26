import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:intl/intl.dart';

class ExpiryAlertsScreen extends ConsumerWidget {
  const ExpiryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(expiryAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiry Alerts'),
        backgroundColor: Colors.orange.shade50,
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(
              child: Text('No near-expiry products found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isExpired = alert.daysRemaining <= 0;
              final isCritical = alert.daysRemaining <= 30;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isExpired 
                        ? Colors.red.shade100 
                        : (isCritical ? Colors.orange.shade100 : Colors.blue.shade100),
                    child: Icon(
                      isExpired ? Icons.error_outline : Icons.warning_amber_rounded,
                      color: isExpired 
                          ? Colors.red 
                          : (isCritical ? Colors.orange : Colors.blue),
                    ),
                  ),
                  title: Text(
                    alert.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batch: ${alert.batchNo}'),
                      Text('Expires: ${DateFormat('dd MMM yyyy').format(alert.expiryDate)}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isExpired ? 'EXPIRED' : '${alert.daysRemaining} days left',
                        style: TextStyle(
                          color: isExpired ? Colors.red : (isCritical ? Colors.orange : Colors.green),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Qty: ${alert.quantity}'),
                    ],
                  ),
                ),
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
