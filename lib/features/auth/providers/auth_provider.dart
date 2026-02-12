import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session;
});
