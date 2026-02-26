import 'package:supabase_flutter/supabase_flutter.dart';


// TODO: Replace with your actual Supabase URL and Anon Key
const String _supabaseUrl = 'https://qmprhelhuxcbzkkdgprf.supabase.co';

const String _supabaseAnonKey = 'sb_publishable_6FR-7ZpHLhpVV9eYGEv-zw_SGG_Oz_2';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );
}
