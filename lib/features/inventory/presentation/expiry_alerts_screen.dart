import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/core/app_theme.dart';
import 'package:intl/intl.dart';

class ExpiryAlertsScreen extends ConsumerWidget {
  const ExpiryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(expiryAlertsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Expiry Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(expiryAlertsProvider),
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('All Clear!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const Text('No products are expiring soon.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isExpired = alert.daysRemaining <= 0;
              final isCritical = alert.daysRemaining <= 30;

              final statusColor = isExpired 
                  ? AppTheme.errorColor 
                  : (isCritical ? Colors.orange : Colors.green);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExpired ? Icons.event_busy_rounded : Icons.event_repeat_rounded,
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        alert.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Batch: ${alert.batchNo}', style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: statusColor),
                              const SizedBox(width: 6),
                              Text(
                                'Expiry: ${DateFormat('dd MMM yyyy').format(alert.expiryDate)}',
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isExpired ? 'EXPIRED' : '${alert.daysRemaining}d',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_rounded, size: 18, color: Colors.black38),
                              const SizedBox(width: 8),
                              Text('Stock: ${alert.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Action to remove or clear stock
                            },
                            icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: AppTheme.errorColor),
                            label: const Text('Clear Stock', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Failed to load alerts: $err'),
            ],
          ),
        ),
      ),
    );
  }
}
