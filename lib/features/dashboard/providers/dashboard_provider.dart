import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';

class ExpiryAlert {
  final String productName;
  final String batchNo;
  final DateTime expiryDate;
  final int quantity;
  final int daysRemaining;

  ExpiryAlert({
    required this.productName,
    required this.batchNo,
    required this.expiryDate,
    required this.quantity,
    required this.daysRemaining,
  });

  factory ExpiryAlert.fromJson(Map<String, dynamic> json) {
    return ExpiryAlert(
      productName: json['product_name'] ?? 'Unknown',
      batchNo: json['batch_no'] ?? 'Unknown',
      expiryDate: DateTime.parse(json['expiry_date']),
      quantity: json['quantity'] ?? 0,
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }
}

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final data = await supabase
      .from('expiry_alerts')
      .select()
      .order('days_remaining', ascending: true);
  
  return (data as List).map((e) => ExpiryAlert.fromJson(e)).toList();
});
