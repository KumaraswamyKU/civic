import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_controller.dart';
import 'screens/citizen_gate_screen.dart';
import 'screens/login_screen.dart';
import 'screens/operations_shell.dart';
import 'services/app_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CivicOpsApp(auth: AuthController(AppServices())));
}

class CivicOpsApp extends StatefulWidget {
  const CivicOpsApp({super.key, required this.auth});

  final AuthController auth;

  @override
  State<CivicOpsApp> createState() => _CivicOpsAppState();
}

class _CivicOpsAppState extends State<CivicOpsApp> {
  @override
  void initState() {
    super.initState();
    widget.auth.restore();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.auth,
      child: MaterialApp(
        title: 'Civic Operations Center',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _Gate(),
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.user;
    if (user == null) {
      return const LoginScreen();
    }
    if (!user.isStaff) {
      return const CitizenGateScreen();
    }
    return const OperationsShell();
  }
}
