import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/civic_header.dart';
import '../widgets/civic_scene.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user;
    return Scaffold(
      backgroundColor: CivicTokens.hero,
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: CivicHeroBackdrop(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const CivicHeader(
                      light: true,
                      subtitle: 'Better city. Better community.',
                    ),
                    const Spacer(),
                    Text(
                      'Report local issues.\nTrack progress.\nMake an impact.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: CivicTokens.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  children: [
                    const Center(child: _Pill(icon: Icons.photo_camera_outlined, label: 'Report local issues')),
                    const SizedBox(height: 8),
                    const Center(child: _Pill(icon: Icons.timeline, label: 'Track progress')),
                    const SizedBox(height: 8),
                    const Center(child: _Pill(icon: Icons.diversity_3_outlined, label: 'Make an impact')),
                    const SizedBox(height: 28),
                    if (auth.restoring)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                      child: const Text('Sign in'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text('Create account'),
                    ),
                    if (user != null)
                      TextButton(
                        onPressed: () {
                          final route = user.isStaffUser ? AppRoutes.adminHome : AppRoutes.citizenHome;
                          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
                        },
                        child: Text('Continue as ${user.firstName}'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: CivicTokens.surface,
        borderRadius: BorderRadius.circular(CivicTokens.radiusPill),
        border: Border.all(color: CivicTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CivicTokens.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
