import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/civic_page_body.dart';

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
      body: SafeArea(
        child: CivicPageBody(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              user == null
                  ? 'Sign in as a department admin to continue.'
                  : 'Signed in as ${user.fullName}. Department tools will use the existing reports API.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
