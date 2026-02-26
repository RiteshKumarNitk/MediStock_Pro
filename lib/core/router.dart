import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medistock_pro/features/auth/presentation/login_screen.dart';
import 'package:medistock_pro/features/auth/presentation/register_screen.dart';
import 'package:medistock_pro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/inventory_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/add_product_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/scanner_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/scan_invoice_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/returns_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/invoices_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/pos_screen.dart';
import 'package:medistock_pro/features/dashboard/presentation/reports_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/expiry_forecast_screen.dart';

final router = GoRouter(




  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';

    if (session == null && !isLoggingIn && !isRegistering && state.uri.toString() == '/') {
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
        GoRoute(
          path: 'invoice-scan',
          builder: (context, state) => const ScanInvoiceScreen(),
        ),
        GoRoute(
          path: 'returns',
          builder: (context, state) => const ReturnsManagementScreen(),
        ),
        GoRoute(
          path: 'invoices',
          builder: (context, state) => const InvoicesScreen(),
        ),
        GoRoute(
          path: 'pos',
          builder: (context, state) => const POSScreen(),
        ),
        GoRoute(
          path: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: 'expiry-forecast',
          builder: (context, state) => const ExpiryForecastScreen(),
        ),
      ],
    ),




  ],
);

