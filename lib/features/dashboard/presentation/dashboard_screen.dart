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
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MediStock Pro', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          profileAsync.when(
            data: (profile) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Hero(
                tag: 'profile_pill',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          profile?.name?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile?.name?.split(' ')[0] ?? 'User',
                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      drawer: _buildPremiumDrawer(context, ref, profileAsync),
      body: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.05),
                Colors.white,
                AppTheme.secondaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernGreeting(context, profileAsync),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Business Health'),
                const SizedBox(height: 12),
                _buildKPIGrid(productsAsync, alertsAsync),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Smart Replenishment Alerts'),
                const SizedBox(height: 12),
                _buildReorderAlerts(ref),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Quick Actions Hub'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Intelligence Tools'),
                const SizedBox(height: 12),
                _buildToolCard(
                  context,
                  'Expiry Forecasting',
                  'AI-powered projection for upcoming stock clearances',
                  Icons.trending_up_rounded,
                  AppTheme.primaryColor,
                  () => context.go('/reports/expiry-forecast'),
                ),
                const SizedBox(height: 12),
                _buildToolCard(
                  context,
                  'Smart Inventory',
                  'Deep analytics on stock movements and trends',
                  Icons.analytics_rounded,
                  AppTheme.secondaryColor,
                  () => context.go('/reports'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernGreeting(BuildContext context, AsyncValue<dynamic> profileAsync) {
    return _FadeIn(
      delay: 0,
      child: profileAsync.when(
        data: (profile) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTROL CENTER',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w200),
                children: [
                  const TextSpan(text: 'Hello, '),
                  TextSpan(
                    text: profile?.name ?? 'Valued Partner',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const SizedBox(height: 60),
        error: (_, __) => const SizedBox(height: 60),
      ),
    );
  }

  Widget _buildKPIGrid(AsyncValue<dynamic> products, AsyncValue<dynamic> alerts) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _FadeIn(
          delay: 100,
          child: _buildGlassKPICard(
            'Active Stock',
            products.when(data: (p) => p.length.toString(), loading: () => '...', error: (_, __) => '!'),
            Icons.medication_rounded,
            AppTheme.primaryColor,
          ),
        ),
        _FadeIn(
          delay: 200,
          child: _buildGlassKPICard(
            'Safety Alerts',
            alerts.when(data: (a) => a.length.toString(), loading: () => '...', error: (_, __) => '!'),
            Icons.warning_amber_rounded,
            AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FadeIn(
            delay: 300,
            child: _buildActionBtn(
              context,
              'SCAN INVOICE',
              Icons.document_scanner_rounded,
              AppTheme.secondaryColor,
              () => context.go('/inventory/invoice-scan'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FadeIn(
            delay: 400,
            child: _buildActionBtn(
              context,
              'NEW BILL',
              Icons.point_of_sale_rounded,
              AppTheme.primaryColor,
              () => context.go('/inventory/pos'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Container(
                  width: 30,
                  height: 4,
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.toString() == 'null' ? '0' : value.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumDrawer(BuildContext context, WidgetRef ref, AsyncValue<dynamic> profileAsync) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 40, 0, 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            profileAsync.when(
              data: (profile) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(profile?.name?[0].toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.name ?? 'Partner', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                          Text(profile?.email ?? 'store@medistock.com', style: TextStyle(color: Colors.grey.shade500, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Profile Error'),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNavTile(context, 'Dashboard', Icons.grid_view_rounded, '/dashboard', isSelected: true),
                  _buildNavTile(context, 'Inventory Master', Icons.inventory_2_rounded, '/inventory'),
                  _buildNavTile(context, 'Critical Alerts', Icons.notification_important_rounded, '/inventory/expiry-alerts'),
                  _buildNavTile(context, 'Sales History', Icons.receipt_long_rounded, '/inventory/reports'),
                ],
              ),
            ),
            const Divider(indent: 32, endIndent: 32),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
                  title: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                  onTap: () => _signOut(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, String title, IconData icon, String route, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  Widget _buildReorderAlerts(WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockProvider);

    return lowStockAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 12),
                Text('All stock levels are optimal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ],
            ),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _FadeIn(
                delay: 100 + (index * 50),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name']?.toString() ?? 'Medication',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${item['total_qty']} units',
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reorder request sent to supplier!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: const Text('REORDER NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return _FadeIn(
      delay: 50,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black54, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, String desc, IconData icon, Color color, VoidCallback onTap, {int delay = 500}) {
    return _FadeIn(
      delay: delay,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          subtitle: Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  final Widget child;
  final int delay;

  const _FadeIn({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

