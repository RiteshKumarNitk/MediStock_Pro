import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/neon_client.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

// ... (ExpiryAlert class remains same)

final expiryAlertsProvider = FutureProvider<List<ExpiryAlert>>((ref) async {
  final tenantId = await AuthService().getTenantId();
  if (tenantId == null) return [];

  // Assuming medi_expiry_alerts is a view in Neon DB
  final result = await neonClient.query(
    'SELECT * FROM medi_expiry_alerts WHERE tenant_id = @tenantId ORDER BY days_remaining ASC',
    substitutionValues: {'tenantId': tenantId},
  );
  
  return result.map((row) => ExpiryAlert.fromJson(row.toColumnMap())).toList();
});
