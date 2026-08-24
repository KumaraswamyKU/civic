import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../models/dashboard_summary.dart';
import '../providers/auth_controller.dart';
import '../widgets/ops_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<DashboardSummary>? _future;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = context.read<AuthController>().services.reports.fetchSummary();
  }

  void _reload() {
    setState(() => _future = context.read<AuthController>().services.reports.fetchSummary());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _future,
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const PageHeader(
              title: 'Civic Operations Center',
              subtitle: 'Overview of civic complaints and departmental workload.',
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LoadingState(label: 'Loading overview…')
            else if (snapshot.hasError)
              ErrorState(message: '${snapshot.error}', onRetry: _reload)
            else
              _DashboardBody(summary: snapshot.data!),
          ],
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final depts = summary.byDepartment.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxDept = depts.isEmpty ? 1 : depts.first.value.clamp(1, 1 << 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _box(StatCard(label: 'Total', value: '${summary.totalComplaints}', accent: CivicTokens.navy)),
            _box(StatCard(label: 'Reported', value: '${summary.statusCount('reported')}', background: CivicTokens.infoContainer, accent: CivicTokens.info)),
            _box(StatCard(label: 'In progress', value: '${summary.statusCount('in_progress')}', background: CivicTokens.amberContainer, accent: CivicTokens.amber)),
            _box(StatCard(label: 'Resolved', value: '${summary.statusCount('resolved')}', background: CivicTokens.successContainer, accent: CivicTokens.success)),
            _box(StatCard(label: 'High priority', value: '${summary.priorityCount('high')}', background: CivicTokens.dangerContainer, accent: CivicTokens.danger)),
          ],
        ),
        const SizedBox(height: 28),
        const Text('Department workload', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 12),
        if (depts.isEmpty)
          const EmptyState(title: 'No department data', message: 'Complaints will appear here after ML assignment.')
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CivicTokens.surface,
              borderRadius: BorderRadius.circular(CivicTokens.radius),
              border: Border.all(color: CivicTokens.border),
            ),
            child: Column(
              children: [
                for (final entry in depts) ...[
                  Row(
                    children: [
                      SizedBox(width: 180, child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: entry.value / maxDept,
                            minHeight: 10,
                            color: CivicTokens.primary,
                            backgroundColor: CivicTokens.surfaceAlt,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 36, child: Text('${entry.value}', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w800))),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        if (summary.avgResolutionHours != null) ...[
          const SizedBox(height: 16),
          Text('Average resolution time: ${summary.avgResolutionHours} hours', style: const TextStyle(color: CivicTokens.muted)),
        ],
      ],
    );
  }

  Widget _box(Widget child) {
    return SizedBox(width: 210, child: child);
  }
}
