import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await AuthScope.of(context).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.start,
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            user == null
                ? 'Sign in as a department admin to load GET /api/reports/summary/.'
                : 'Signed in as ${user.fullName} (${user.role}). Summary and CSV export are wired in ReportService.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
