import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../providers/complaints_provider.dart';
import '../widgets/complaint_card.dart';
import '../widgets/feedback_views.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({
    super.key,
    required this.complaints,
    required this.onReport,
  });

  final ComplaintsProvider complaints;
  final VoidCallback onReport;

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  String _filter = 'all';

  static const _filters = [
    ('all', 'All'),
    ('reported', 'Reported'),
    ('in_progress', 'In progress'),
    ('resolved', 'Resolved'),
  ];

  List<Complaint> get _visible {
    if (_filter == 'all') {
      return widget.complaints.items;
    }
    return widget.complaints.items.where((item) => item.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final complaints = widget.complaints;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: complaints,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: complaints.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text('My reports', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    "Track the civic issues you've reported.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: CivicTokens.muted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _MiniStat(label: 'Total', value: '${complaints.count}')),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(label: 'Active', value: '${complaints.activeCount}')),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(label: 'Resolved', value: '${complaints.resolvedCount}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in _filters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter.$2),
                              selected: _filter == filter.$1,
                              onSelected: (_) => setState(() => _filter = filter.$1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (complaints.loading && complaints.items.isEmpty)
                    const SkeletonCards()
                  else if (complaints.error != null && complaints.items.isEmpty)
                    ErrorState(
                      message: 'Something went wrong while contacting Civic.',
                      onRetry: complaints.refresh,
                    )
                  else if (_visible.isEmpty)
                    EmptyState(
                      title: 'No matching reports',
                      message: _filter == 'all'
                          ? "You haven't reported a civic issue. When you spot something that needs attention, you can report it here."
                          : 'No complaints with this status yet.',
                      actionLabel: 'Report an issue',
                      onAction: widget.onReport,
                    )
                  else ...[
                    for (final complaint in _visible) ...[
                      ComplaintCard(complaint: complaint),
                      const SizedBox(height: 10),
                    ],
                    if (_filter == 'all' && complaints.hasNext)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton(
                          onPressed: complaints.loadingMore ? null : complaints.loadMore,
                          child: Text(complaints.loadingMore ? 'Loading…' : 'Load more'),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: CivicTokens.surface,
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
        border: Border.all(color: CivicTokens.border),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
