import 'package:go_router/go_router.dart';
import 'package:medistock_pro/features/auth/presentation/login_screen.dart';
import 'package:medistock_pro/features/auth/presentation/register_screen.dart';
import 'package:medistock_pro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:medistock_pro/features/dashboard/presentation/reports_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/inventory_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/add_product_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/edit_product_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/scanner_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/scan_invoice_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/returns_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/transactions_screen.dart';
import 'package:medistock_pro/features/auth/presentation/profile_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/pos_screen.dart';
import 'package:medistock_pro/features/inventory/presentation/expiry_forecast_screen.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:medistock_pro/core/main_navigation_shell.dart';

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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddProductScreen(),
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final product = state.extra as Map<String, dynamic>?;
                    if (product == null) return const InventoryScreen();
                    return EditProductScreen(product: product);
                  },
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
                  path: 'ledger',
                  builder: (context, state) => const TransactionsScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pos',
              builder: (context, state) => const POSScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
              routes: [
                GoRoute(
                  path: 'expiry-forecast',
                  builder: (context, state) => const ExpiryForecastScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
