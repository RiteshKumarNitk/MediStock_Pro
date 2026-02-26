import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:medistock_pro/core/router.dart';

const String _supabaseUrl = 'https://qmprhelhuxcbzkkdgprf.supabase.co';
const String _supabaseAnonKey = 'sb_publishable_6FR-7ZpHLhpVV9eYGEv-zw_SGG_Oz_2';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Starting App Initialization...');

  try {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    debugPrint('Supabase Initialized Successfully');
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'MediStock Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}