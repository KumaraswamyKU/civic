import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/civic_scene.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onOpenReports});

  final VoidCallback? onOpenReports;

  Future<void> _logout(BuildContext context) async {
    await AuthScope.of(context).logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.start, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    final initial = (user?.firstName.isNotEmpty == true) ? user!.firstName[0].toUpperCase() : 'C';
    return Scaffold(
      body: Column(
        children: [
          CivicHeroBackdrop(
            height: 210,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 16, 20, 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Text(
                    initial,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.fullName ?? 'Citizen',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDisplayLabel(user?.role ?? 'citizen')} account',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _AccountRow(icon: Icons.mail_outline, label: 'Email', value: user?.email ?? '—'),
                _AccountRow(icon: Icons.phone_outlined, label: 'Phone', value: user?.phoneNumber ?? '—'),
                _AccountRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Role',
                  value: formatDisplayLabel(user?.role ?? 'citizen'),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: onOpenReports,
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('View my reports'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: CivicTokens.surface,
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
        border: Border.all(color: CivicTokens.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: CivicTokens.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
