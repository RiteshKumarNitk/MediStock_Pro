import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:intl/intl.dart';

final expiryForecastProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ApiClient.get('/reports?type=expiry');
  if (response.statusCode != 200) return [];

  final List data = jsonDecode(response.body);
  return data.map((item) {
    final map = Map<String, dynamic>.from(item as Map);
    return {
      ...map,
      'medi_products': {'name': map['product']['name']}
    };
  }).toList().cast<Map<String, dynamic>>();
});

class ExpiryForecastScreen extends ConsumerWidget {
  const ExpiryForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(expiryForecastProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('6-Month Expiry Forecast')),
      body: forecastAsync.when(
        data: (batches) {
          if (batches.isEmpty) {
            return const Center(child: Text('No products expiring in the next 6 months.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
              final expiry = DateTime.parse(batch['expiry_date']);
              final daysLeft = expiry.difference(DateTime.now()).inDays;
              
              Color statusColor = Colors.green;
              if (daysLeft <= 30) {
                statusColor = Colors.red;
              } else if (daysLeft <= 90) {
                statusColor = Colors.orange;
              }

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(Icons.warning_amber_rounded, color: statusColor),
                  ),
                  title: Text(batch['medi_products']['name']),
                  subtitle: Text('Batch: ${batch['batch_no']} • Qty: ${batch['quantity']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(DateFormat('MMM yyyy').format(expiry), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$daysLeft days left', style: TextStyle(color: statusColor, fontSize: 12)),
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
