import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/app_info_row.dart';
import '../widgets/civic_header.dart';
import '../widgets/status_badge.dart';

/// Confirms the Flutter client is running and shows how it will reach Django.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                const CivicHeader(),
                const SizedBox(height: 8),
                Text(
                  'Issue detection and reporting',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: StatusBadge(label: 'Flutter application is running')),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Backend connection',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppInfoRow(label: 'API base URL', value: ApiConfig.baseUrl),
                        const AppInfoRow(label: 'Auth', value: 'SimpleJWT (Bearer)'),
                        AppInfoRow(
                          label: 'Session',
                          value: user == null ? 'Signed out' : '${user.fullName} (${user.role})',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Create citizen account'),
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      final route = user.isStaffUser
                          ? AppRoutes.adminHome
                          : AppRoutes.citizenHome;
                      Navigator.pushNamed(context, route);
                    },
                    child: const Text('Continue to app'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
