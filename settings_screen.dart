import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/providers/auth_provider.dart';
import 'package:forex_signals_app/providers/settings_provider.dart';
import 'package:forex_signals_app/screens/auth/login_screen.dart';
import 'package:forex_signals_app/screens/profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out', style: TextStyle(color: AppColors.sell))),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  title: const Text('Profile'),
                  subtitle: Text(user?.email ?? ''),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Notifications'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
              title: const Text('Push Notifications'),
              subtitle: const Text('Get notified instantly when a new AI signal is generated', style: TextStyle(fontSize: 12.5)),
              value: settings.notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) => settings.setNotificationsEnabled(value),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  title: Text('AI Forex Signal System'),
                  subtitle: Text('Version 1.0.0', style: TextStyle(fontSize: 12.5)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.shield_outlined, color: AppColors.primary),
                  title: Text('Risk Disclaimer'),
                  subtitle: Text(
                    'Signals are AI-generated analytical estimates, not financial advice.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.sell),
              title: const Text('Log Out', style: TextStyle(color: AppColors.sell, fontWeight: FontWeight.w600)),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }
}
