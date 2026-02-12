import 'package:supabase_flutter/supabase_flutter.dart';


// TODO: Replace with your actual Supabase URL and Anon Key
const String _supabaseUrl = 'https://gileyahzdpoyjgrztxow.supabase.co';

const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpbGV5YWh6ZHBveWpncnp0eG93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NzE2MTQsImV4cCI6MjA3NzI0NzYxNH0.b9RNGS-r4B91y96nxdUjK_jNtaG_5Dm-KwBSKtlPMYs';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );
}
