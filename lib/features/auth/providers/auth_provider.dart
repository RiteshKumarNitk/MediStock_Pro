import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(authServiceProvider).getCurrentUser();
});
