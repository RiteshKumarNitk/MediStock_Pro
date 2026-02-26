import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/core/supabase_client.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/features/inventory/presentation/expiry_alerts_screen.dart';

import 'package:medistock_pro/core/notification_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(expiryAlertsProvider);
    final productsAsync = ref.watch(productsProvider);

    // Check for critical alerts to notify
    alertsAsync.whenData((alerts) => NotificationService.checkAndNotify(alerts));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediStock Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MediStock Pro',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    supabase.auth.currentUser?.email ?? 'User',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => context.go('/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () => context.go('/inventory'),
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber),
              title: const Text('Expiry Alerts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpiryAlertsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildKPICard(
                  context,
                  'Total Products',
                  productsAsync.when(
                    data: (p) => p.length.toString(),
                    loading: () => '...',
                    error: (_, __) => '!',
                  ),
                  Icons.medication,
                  Colors.blue,
                ),
                _buildKPICard(
                  context,
                  'Expiring Soon',
                  alertsAsync.when(
                    data: (a) => a.where((i) => i.daysRemaining > 0).length.toString(),
                    loading: () => '...',
                    error: (_, __) => '!',
                  ),
                  Icons.warning,
                  Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpiryAlertsScreen()),
                  ),
                ),
                _buildKPICard(
                  context,
                  'Expired Stock',
                  alertsAsync.when(
                    data: (a) => a.where((i) => i.daysRemaining <= 0).length.toString(),
                    loading: () => '...',
                    error: (_, __) => '!',
                  ),
                  Icons.cancel,
                  Colors.red,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpiryAlertsScreen()),
                  ),
                ),
                _buildKPICard(
                  context,
                  'Scan Invoice',
                  'AI Scan',
                  Icons.document_scanner,
                  Colors.purple,
                  onTap: () => context.go('/inventory/invoice-scan'),
                ),
                _buildKPICard(
                  context,
                  'Invoice History',
                  'Invoices',
                  Icons.history_edu,
                  Colors.teal,
                  onTap: () => context.go('/inventory/invoices'),
                ),
                _buildKPICard(
                  context,
                  'New Sale (POS)',
                  'Billing',
                  Icons.point_of_sale,
                  Colors.orange,
                  onTap: () => context.go('/inventory/pos'),
                ),
                _buildKPICard(
                  context,
                  'Analytics',
                  'Reports',
                  Icons.analytics,
                  Colors.indigo,
                  onTap: () => context.go('/inventory/reports'),
                ),
                _buildKPICard(
                  context,
                  'Expiry Forecast',
                  'Projection',
                  Icons.calendar_month,
                  Colors.amber,
                  onTap: () => context.go('/inventory/expiry-forecast'),
                ),
              ],
            ),




            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              'Scan Barcode',
              Icons.qr_code_scanner,
              () => context.go('/inventory/scan'),
            ),
            _buildActionItem(
              context,
              'Manage Returns',
              Icons.keyboard_return,
              () => context.go('/inventory/returns'),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: Colors.grey.shade100,
    );
  }
}

