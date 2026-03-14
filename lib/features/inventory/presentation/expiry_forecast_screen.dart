import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/core/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

final expiryForecastProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ApiClient.get('/reports?type=expiry');
  if (response.statusCode != 200) return [];

  final Map<String, dynamic> decoded = jsonDecode(response.body);
  if (decoded['success'] != true) return [];
  
  final List data = decoded['data'] ?? [];
  return data.map((item) {
    final map = Map<String, dynamic>.from(item as Map);
    // Robust access to nested product name
    final productName = map['product']?['name'] ?? 'Unknown Item';
    return {
      ...map,
      'medi_products': {'name': productName}
    };
  }).toList().cast<Map<String, dynamic>>();
});

class ExpiryForecastScreen extends ConsumerWidget {
  const ExpiryForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(expiryForecastProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Expiry Forecasting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: forecastAsync.when(
        data: (batches) {
          if (batches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.query_stats_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No upcoming expiries found.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
              final expiryStr = batch['expiry_date']?.toString();
              
              DateTime expiry;
              try {
                expiry = expiryStr != null ? DateTime.parse(expiryStr) : DateTime.now().add(const Duration(days: 365));
              } catch (e) {
                expiry = DateTime.now().add(const Duration(days: 365));
              }

              final daysLeft = expiry.difference(DateTime.now()).inDays;
              
              Color statusColor = Colors.green;
              if (daysLeft <= 30) {
                statusColor = AppTheme.errorColor;
              } else if (daysLeft <= 90) {
                statusColor = Colors.orange;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.timeline_rounded, color: statusColor),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch['medi_products']?['name'] ?? 'Unknown Item',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batch: ${batch['batch_no'] ?? 'N/A'} • Qty: ${batch['quantity'] ?? 0}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('MMM yyyy').format(expiry),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$daysLeft days',
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 88,
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            );
          },
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
