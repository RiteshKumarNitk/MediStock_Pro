import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/features/auth/providers/profile_provider.dart';
import '../../../core/api_client.dart';
import '../../../core/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Store Profile'),
        elevation: 0,
        actions: [
          profileAsync.when(
            data: (profile) => IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditDialog(context, ref, profile?.name ?? ''),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(profile),
              const SizedBox(height: 32),
              _buildInfoSection(context, profile),
              const SizedBox(height: 32),
              _buildStoreSettings(context),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Store Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Store Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await ApiClient.patch('/auth/profile', {'name': controller.text});
                if (response.statusCode == 200) {
                  ref.invalidate(profileProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              } catch (e) {
                debugPrint('Update error: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    final name = profile?.name ?? 'S';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 4),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile?.name ?? 'Secure Store',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        Text(
          'Tenant ID: ${profile?.tenantId ?? 'N/A'}',
          style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BUSINESS INFORMATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: AppTheme.primaryColor)),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.email_outlined, 'Email', profile?.email ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow(Icons.business_outlined, 'Store Name', profile?.name ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow(Icons.verified_user_outlined, 'GSTIN', '27AAACG1234F1Z5'), // Mock data if not in profile
          const Divider(height: 32),
          _buildInfoRow(Icons.location_on_outlined, 'Address', '123, Medical Square, Jaipur'),
        ],
      ),
    );
  }

  Widget _buildStoreSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Colors.grey)),
        ),
        _buildSettingsTile(Icons.notifications_active_outlined, 'Push Notifications', 'Manage reorder alerts'),
        const SizedBox(height: 12),
        _buildSettingsTile(Icons.lock_person_outlined, 'Security', 'Password & 2FA'),
        const SizedBox(height: 12),
        _buildSettingsTile(Icons.palette_outlined, 'Appearance', 'Dark Mode & Theme'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black12),
        onTap: () {},
      ),
    );
  }
}
