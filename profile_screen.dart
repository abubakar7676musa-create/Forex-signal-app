import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forex_signals_app/core/theme/app_theme.dart';
import 'package:forex_signals_app/core/utils/formatters.dart';
import 'package:forex_signals_app/providers/auth_provider.dart';
import 'package:forex_signals_app/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  late TextEditingController _nameController;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() => _saving = true);
    try {
      final updated = await _userService.updateProfile(fullName: _nameController.text.trim());
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(updated);
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account'),
        content: const Text('This will deactivate your account. You will be logged out immediately. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.sell)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.deleteAccount();
        if (!mounted) return;
        await context.read<AuthProvider>().logout();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(
                            (user.fullName?.isNotEmpty == true ? user.fullName![0] : user.email[0]).toUpperCase(),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                        if (user.role == 'admin') ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Text('ADMIN', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Full Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              IconButton(
                                icon: Icon(_editing ? Icons.close_rounded : Icons.edit_outlined, size: 18),
                                onPressed: () => setState(() => _editing = !_editing),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _editing
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(isDense: true),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: _saving
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                          : const Icon(Icons.check_rounded, color: AppColors.buy),
                                      onPressed: _saving ? null : _saveName,
                                    ),
                                  ],
                                )
                              : Text(user.fullName ?? 'Not set', style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Member Since', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(Formatters.fullDate(user.createdAt), style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Favorite Pairs', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 8),
                          user.favoritePairs.isEmpty
                              ? const Text('None selected', style: TextStyle(fontSize: 14, color: AppColors.textSecondary))
                              : Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: user.favoritePairs.map((p) => Chip(label: Text(p, style: const TextStyle(fontSize: 11.5)))).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: _confirmDeleteAccount,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.sell, size: 18),
                    label: const Text('Delete Account', style: TextStyle(color: AppColors.sell)),
                  ),
                ],
              ),
            ),
    );
  }
}
