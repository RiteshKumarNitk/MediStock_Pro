import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medistock_pro/features/auth/services/auth_service.dart';
import 'package:medistock_pro/features/auth/providers/profile_provider.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/core/notification_service.dart';
import 'package:medistock_pro/features/inventory/presentation/expiry_alerts_screen.dart';

import 'package:medistock_pro/core/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(expiryAlertsProvider);
    final productsAsync = ref.watch(productsProvider);
    final profileAsync = ref.watch(profileProvider);

    // Check for critical alerts to notify
    alertsAsync.whenData((alerts) => NotificationService.checkAndNotify(alerts));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediStock Pro'),
        elevation: 0,
        actions: [
          profileAsync.when(
            data: (profile) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  profile?.name?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            profileAsync.when(
              data: (profile) => UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                accountName: Text(profile?.name ?? 'Premium User', style: const TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: Text(profile?.email ?? 'store@medistock.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    profile?.name?[0].toUpperCase() ?? 'M',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
              ),
              loading: () => const DrawerHeader(child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const DrawerHeader(child: Center(child: Text('Error loading profile'))),
            ),
            _buildDrawerTile(context, 'Dashboard', Icons.dashboard_rounded, '/dashboard', isSelected: true),
            _buildDrawerTile(context, 'Inventory', Icons.inventory_2_rounded, '/inventory'),
            _buildDrawerTile(context, 'Expiry Alerts', Icons.notification_important_rounded, '/inventory/expiry-alerts', isSubPage: true),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              title: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () => _signOut(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsync.when(
              data: (profile) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                  ),
                  Text(
                    profile?.name ?? 'Valued Partner',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 50),
              error: (_, __) => const SizedBox(height: 50),
            ),
            const SizedBox(height: 32),
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1,
              children: [
                _buildKPICard(
                  context,
                   'Active Stock',
                  productsAsync.when(
                    data: (p) => p.length.toString(),
                    loading: () => '...',
                    error: (_, __) => '!',
                  ),
                  Icons.medication_liquid_rounded,
                  AppTheme.primaryColor,
                ),
                _buildKPICard(
                  context,
                  'Expiring Soon',
                  alertsAsync.when(
                    data: (a) => a.where((i) => i.daysRemaining > 0).length.toString(),
                    loading: () => '...',
                    error: (_, __) => '!',
                  ),
                  Icons.auto_graph_rounded,
                  Colors.orangeAccent,
                  onTap: () => context.go('/inventory/expiry-alerts'),
                ),
                _buildKPICard(
                  context,
                  'AI Image Scan',
                  'Process',
                  Icons.document_scanner_rounded,
                  AppTheme.secondaryColor,
                  onTap: () => context.go('/inventory/invoice-scan'),
                ),
                _buildKPICard(
                  context,
                  'New Sale (POS)',
                  'Billing',
                  Icons.point_of_sale_rounded,
                  AppTheme.accentColor,
                  onTap: () => context.go('/inventory/pos'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildPremiumSectionHeader(context, 'Intelligence Tools'),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              'Expiry Forecast',
              'Advanced AI projection for stock management',
              Icons.trending_up_rounded,
              AppTheme.primaryColor,
              () => context.go('/inventory/expiry-forecast'),
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              context,
              'Inventory Analytics',
              'Data-driven insights for your pharmacy',
              Icons.analytics_rounded,
              AppTheme.secondaryColor,
              () => context.go('/inventory/reports'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(BuildContext context, String title, IconData icon, String route, {bool isSelected = false, bool isSubPage = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.black54),
      title: Text(title, style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        if (isSubPage) {
           Navigator.pop(context); // Close drawer
           context.push(route);
        } else {
           context.go(route);
        }
      },
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
      ),
    );
  }

  Widget _buildPremiumSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

