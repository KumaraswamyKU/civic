import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../screens/citizen_home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reports_list_screen.dart';
import '../utils/app_routes.dart';

class CitizenShellScreen extends StatefulWidget {
  const CitizenShellScreen({super.key});

  @override
  State<CitizenShellScreen> createState() => _CitizenShellScreenState();
}

class _CitizenShellScreenState extends State<CitizenShellScreen> {
  int _index = 0;
  ComplaintsProvider? _complaints;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_complaints != null) {
      return;
    }
    final provider = ComplaintsProvider(AuthScope.of(context).services.complaints);
    _complaints = provider;
    provider.refresh();
  }

  @override
  void dispose() {
    _complaints?.dispose();
    super.dispose();
  }

  Future<void> _openReport() async {
    final result = await Navigator.pushNamed(context, AppRoutes.reportIssue);
    if (!mounted) {
      return;
    }
    await _complaints?.refresh();
    if (result is Complaint && mounted) {
      await Navigator.pushNamed(
        context,
        AppRoutes.complaintDetail,
        arguments: result.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaints = _complaints;
    if (complaints == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      CitizenHomeScreen(
        complaints: complaints,
        onReport: _openReport,
        onSeeAllReports: () => setState(() => _index = 1),
      ),
      ReportsListScreen(complaints: complaints, onReport: _openReport),
      ProfileScreen(onOpenReports: () => setState(() => _index = 1)),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Material(
        color: CivicTokens.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: CivicTokens.navHeight,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                  label: 'Reports',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? CivicTokens.mint : Colors.transparent,
                borderRadius: BorderRadius.circular(CivicTokens.radiusPill),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                color: selected ? CivicTokens.hero : CivicTokens.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? CivicTokens.hero : CivicTokens.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
