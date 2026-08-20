import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../utils/app_routes.dart';
import '../utils/session_guard.dart';
import '../widgets/app_info_row.dart';
import '../widgets/complaint_card.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  ComplaintsProvider? _complaints;
  bool _handledUnauthorized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_complaints != null) {
      return;
    }
    final provider = ComplaintsProvider(AuthScope.of(context).services.complaints);
    _complaints = provider;
    provider.addListener(_onComplaintsChanged);
    provider.refresh();
  }

  void _onComplaintsChanged() {
    final error = _complaints?.lastException;
    if (!_handledUnauthorized && error != null && error.isUnauthorized && mounted) {
      _handledUnauthorized = true;
      showAppError(context, error);
    }
  }

  @override
  void dispose() {
    _complaints?.removeListener(_onComplaintsChanged);
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
    final user = AuthScope.of(context).user;
    final complaints = _complaints;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My reports'),
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
      body: user == null || complaints == null
          ? const Center(child: Text('Sign in to view your complaints.'))
          : ListenableBuilder(
              listenable: complaints,
              builder: (context, _) {
                return RefreshIndicator(
                  onRefresh: complaints.refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _UserSummary(user: user),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openReport,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Report an Issue'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your complaints',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        complaints.loading
                            ? 'Loading…'
                            : '${complaints.count} from the server',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      if (complaints.loading && complaints.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (complaints.error != null && complaints.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Text(complaints.error!),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: complaints.refresh,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (complaints.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'You have not reported any issues yet.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        for (final complaint in complaints.items) ...[
                          ComplaintCard(
                            complaint: complaint,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.complaintDetail,
                              arguments: complaint.id,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (complaints.hasNext)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: OutlinedButton(
                              onPressed: complaints.loadingMore ? null : complaints.loadMore,
                              child: Text(
                                complaints.loadingMore ? 'Loading…' : 'Load more',
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _UserSummary extends StatelessWidget {
  const _UserSummary({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppInfoRow(label: 'Email', value: user.email),
            AppInfoRow(label: 'Phone', value: user.phoneNumber),
            AppInfoRow(label: 'Role', value: user.role),
          ],
        ),
      ),
    );
  }
}
