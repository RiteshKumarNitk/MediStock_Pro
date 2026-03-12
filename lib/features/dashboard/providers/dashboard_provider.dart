import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/inventory/models/expiry_alert.dart';

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final response = await ApiClient.get('/reports?type=expiry'); // Using expiry report for alerts
  if (response.statusCode != 200) return [];

  final List data = jsonDecode(response.body);
  return data.map((item) {
    // Map backend batch to ExpiryAlert model
    return ExpiryAlert.fromJson({
      ...item,
      'product_name': item['product']['name'],
      'days_remaining': DateTime.parse(item['expiryDate']).difference(DateTime.now()).inDays,
    });
  }).toList();
});
