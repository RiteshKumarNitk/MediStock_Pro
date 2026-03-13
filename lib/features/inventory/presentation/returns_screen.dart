import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/core/app_theme.dart';
import 'package:intl/intl.dart';

class ReturnsManagementScreen extends ConsumerWidget {
  const ReturnsManagementScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchReturns() async {
    final response = await ApiClient.get('/reports?type=returns');
    if (response.statusCode != 200) return [];

    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Returns & Recalls'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReturns(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.errorColor)));
          }

          final returns = snapshot.data ?? [];

          if (returns.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_return_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No return logs found.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final ret = returns[index];
              final batchNo = ret['medi_batches']['batch_no'];
              final status = (ret['status'] as String).toLowerCase();
              final statusColor = _getStatusColor(status);

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
                        child: Icon(Icons.assignment_return_rounded, color: statusColor),
                      ),
                      title: Text(
                        'ID: ${ret['id'].toString().substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Batch: $batchNo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          if (ret['reason'] != null) 
                            Text('Reason: ${ret['reason']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.black38),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(ret['created_at'].toString())),
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Text('LOG NEW RETURN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white)),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'returned': return Colors.green;
      case 'expired': return AppTheme.errorColor;
      default: return Colors.grey;
    }
  }
}
