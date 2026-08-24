import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_summary.dart';
import '../providers/auth_controller.dart';
import '../utils/csv_download.dart';
import '../widgets/ops_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Future<DashboardSummary>? _future;
  bool _started = false;
  bool _downloading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = context.read<AuthController>().services.reports.fetchSummary();
  }

  Future<void> _export() async {
    setState(() => _downloading = true);
    try {
      final bytes = await context.read<AuthController>().services.reports.downloadCsv();
      if (kIsWeb) {
        await downloadCsvFile(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV download started.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV export is available in the Civic web app.')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _future,
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            PageHeader(
              title: 'Reports',
              subtitle: 'Existing summary and CSV export. Full analytics arrives in Phase 15.',
              actions: [
                FilledButton(
                  onPressed: _downloading ? null : _export,
                  child: Text(_downloading ? 'Preparing…' : 'Export CSV'),
                ),
              ],
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LoadingState()
            else if (snapshot.hasError)
              ErrorState(
                message: '${snapshot.error}',
                onRetry: () => setState(() => _future = context.read<AuthController>().services.reports.fetchSummary()),
              )
            else ...[
              Text('Total complaints: ${snapshot.data!.totalComplaints}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 12),
              Text('By status: ${snapshot.data!.byStatus}'),
              const SizedBox(height: 8),
              Text('By priority: ${snapshot.data!.byPriority}'),
              const SizedBox(height: 8),
              Text('By issue type: ${snapshot.data!.byIssueType}'),
            ],
          ],
        );
      },
    );
  }
}
