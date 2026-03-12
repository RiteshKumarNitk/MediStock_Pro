import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/models/profile.dart';
import 'package:medistock_pro/core/api_client.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

final profileProvider = FutureProvider<Profile?>((ref) async {
  // Try to get from local session first if available, or fetch from API
  final user = await AuthService().getCurrentUser();
  if (user == null) return null;

  // We can fetch profile details from API
  final response = await ApiClient.get('/auth/profile'); 
  if (response.statusCode != 200) {
    // Fallback to local user data if API fails or not implemented
    return Profile.fromJson(user);
  }

  return Profile.fromJson(jsonDecode(response.body));
});
