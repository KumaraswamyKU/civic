import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/auth_controller.dart';
import 'complaints_screen.dart';
import 'dashboard_screen.dart';
import 'departments_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key});

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final pages = [
      const DashboardScreen(),
      const ComplaintsScreen(),
      const DepartmentsScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    const nav = [
      _Nav('Dashboard', Icons.space_dashboard_outlined),
      _Nav('Complaints', Icons.assignment_outlined),
      _Nav('Departments', Icons.apartment_outlined),
      _Nav('Reports', Icons.bar_chart_outlined),
      _Nav('Settings', Icons.settings_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CIVIC'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${user.firstName} · ${user.isSuperAdmin ? 'Super admin' : user.departmentName ?? 'Department'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const ListTile(title: Text('Civic Operations', style: TextStyle(fontWeight: FontWeight.w800))),
                    for (var i = 0; i < nav.length; i++)
                      ListTile(
                        leading: Icon(nav[i].icon),
                        title: Text(nav[i].label),
                        selected: _index == i,
                        onTap: () {
                          setState(() => _index = i);
                          Navigator.pop(context);
                        },
                      ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign out'),
                      onTap: () => context.read<AuthController>().logout(),
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          if (wide)
            ColoredBox(
              color: CivicTokens.sidebar,
              child: SizedBox(
                width: 236,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    for (var i = 0; i < nav.length; i++)
                      _SideItem(
                        label: nav[i].label,
                        icon: nav[i].icon,
                        selected: _index == i,
                        onTap: () => setState(() => _index = i),
                      ),
                    const Spacer(),
                    _SideItem(
                      label: 'Sign out',
                      icon: Icons.logout,
                      selected: false,
                      onTap: () => context.read<AuthController>().logout(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          Expanded(child: pages[_index]),
        ],
      ),
    );
  }
}

class _Nav {
  const _Nav(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: selected ? CivicTokens.hero : Colors.white70),
        title: Text(label, style: TextStyle(color: selected ? CivicTokens.hero : Colors.white, fontWeight: FontWeight.w700)),
        selected: selected,
        selectedTileColor: CivicTokens.mint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
