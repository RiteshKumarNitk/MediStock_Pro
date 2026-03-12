import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/models/profile.dart';
import 'package:medistock_pro/core/neon_client.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = await AuthService().getCurrentUser();
  if (user == null) return null;

  final result = await neonClient.query(
    'SELECT * FROM medi_profiles WHERE id = @id',
    substitutionValues: {'id': user['id']},
  );

  if (result.isEmpty) return null;
  return Profile.fromJson(result[0].toColumnMap());
});
