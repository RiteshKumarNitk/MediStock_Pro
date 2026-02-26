import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/models/profile.dart';
import 'package:medistock_pro/core/supabase_client.dart';

final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final response = await supabase
      .from('medi_profiles')
      .select()
      .eq('id', user.id)
      .single();

  return Profile.fromJson(response);
});
