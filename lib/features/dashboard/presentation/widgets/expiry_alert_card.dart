import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/features/dashboard/providers/dashboard_provider.dart';

class ExpiryAlertCard extends ConsumerWidget {
  const ExpiryAlertCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiryAlertsAsync = ref.watch(expiryAlertsProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Expiry Alerts (Next 30 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 16),
            expiryAlertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const Text('No batches expiring soon.');
                }
                return Column(
                  children: [
                    Text(
                      '${alerts.length} Batches Expiring Soon!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alerts.length > 5 ? 5 : alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return ListTile(
                          title: Text(alert.productName),
                          subtitle: Text('Batch: ${alert.batchNo}'),
                          trailing: Text(
                            '${alert.daysRemaining} days',
                             style: TextStyle(
                              color: alert.daysRemaining < 7 
                                  ? Colors.red 
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    if (alerts.length > 5)
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to full report
                        },
                        child: const Text('View All'),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading alerts: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
