import 'package:medistock_pro/features/auth/services/auth_service.dart';

final authService = AuthService();

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final user = await authService.getCurrentUser();
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';

    if (user == null && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    if (user != null && (isLoggingIn || isRegistering)) {
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

