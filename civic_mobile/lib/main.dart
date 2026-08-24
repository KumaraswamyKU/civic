import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/admin_home_screen.dart';
import 'screens/citizen_shell_screen.dart';
import 'screens/complaint_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/report_issue_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/start_screen.dart';
import 'services/app_services.dart';
import 'utils/app_routes.dart';
import 'widgets/civic_app_frame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CivicApp(auth: AuthProvider(AppServices())));
}

class CivicApp extends StatefulWidget {
  const CivicApp({super.key, required this.auth});

  final AuthProvider auth;

  @override
  State<CivicApp> createState() => _CivicAppState();
}

class _CivicAppState extends State<CivicApp> {
  @override
  void initState() {
    super.initState();
    widget.auth.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: widget.auth,
      child: MaterialApp(
        title: 'Civic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: (context, child) => CivicAppFrame(child: child ?? const SizedBox.shrink()),
        initialRoute: AppRoutes.start,
        routes: {
          AppRoutes.start: (_) => const StartScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.signup: (_) => const SignupScreen(),
          AppRoutes.citizenHome: (_) => const CitizenShellScreen(),
          AppRoutes.adminHome: (_) => const AdminHomeScreen(),
          AppRoutes.reportIssue: (_) => const ReportIssueScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.complaintDetail) {
            final id = settings.arguments;
            if (id is int) {
              return MaterialPageRoute(
                builder: (_) => ComplaintDetailScreen(complaintId: id),
                settings: settings,
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
