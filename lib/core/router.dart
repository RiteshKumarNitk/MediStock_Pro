import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medistock_pro/features/auth/presentation/login_screen.dart';
import 'package:medistock_pro/features/auth/presentation/register_screen.dart';
import 'package:medistock_pro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/inventory_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/add_product_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/scanner_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';

    if (session == null && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    if (session != null && (isLoggingIn || isRegistering)) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductScreen(),
        ),
        GoRoute(
          path: 'scan',
          builder: (context, state) => const ScannerScreen(),
        ),
      ],
    ),
  ],
);
