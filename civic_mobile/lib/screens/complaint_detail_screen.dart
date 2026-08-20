import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/complaint_status_log.dart';
import '../providers/auth_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_info_row.dart';
import '../widgets/status_badge.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final int complaintId;

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Future<_DetailData>? _future;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _future = _load();
  }

  Future<_DetailData> _load() async {
    final services = AuthScope.of(context).services;
    final complaint = await services.complaints.retrieve(widget.complaintId);
    final history = await services.complaints.history(widget.complaintId);
    return _DetailData(complaint: complaint, history: history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complaint #${widget.complaintId}')),
      body: FutureBuilder<_DetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${snapshot.error}'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _future = _load());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = snapshot.data!;
          final complaint = data.complaint;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (complaint.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    complaint.imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return const SizedBox(
                        height: 80,
                        child: Center(child: Text('Image could not be loaded.')),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge.forStatus(complaint.status),
                  StatusBadge.forPriority(complaint.priority),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AppInfoRow(label: 'ID', value: '${complaint.id}'),
                      AppInfoRow(label: 'Citizen', value: complaint.citizenName),
                      AppInfoRow(label: 'Citizen ID', value: '${complaint.citizenId}'),
                      AppInfoRow(label: 'Issue type', value: formatApiLabel(complaint.issueType)),
                      AppInfoRow(
                        label: 'Confidence',
                        value: formatConfidence(complaint.classificationConfidence),
                      ),
                      AppInfoRow(label: 'Priority', value: formatApiLabel(complaint.priority)),
                      AppInfoRow(label: 'Status', value: formatApiLabel(complaint.status)),
                      AppInfoRow(
                        label: 'Department',
                        value: complaint.departmentName?.isNotEmpty == true
                            ? complaint.departmentName!
                            : '—',
                      ),
                      AppInfoRow(
                        label: 'Department ID',
                        value: complaint.departmentId?.toString() ?? '—',
                      ),
                      AppInfoRow(
                        label: 'Description',
                        value: complaint.description.isEmpty ? '—' : complaint.description,
                      ),
                      AppInfoRow(label: 'Latitude', value: formatCoordinate(complaint.latitude)),
                      AppInfoRow(label: 'Longitude', value: formatCoordinate(complaint.longitude)),
                      AppInfoRow(
                        label: 'Address',
                        value: complaint.addressText.isEmpty ? '—' : complaint.addressText,
                      ),
                      AppInfoRow(label: 'Created', value: formatDateTime(complaint.createdAt)),
                      AppInfoRow(label: 'Updated', value: formatDateTime(complaint.updatedAt)),
                      AppInfoRow(label: 'Resolved', value: formatDateTime(complaint.resolvedAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Status history',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (data.history.isEmpty)
                const Text('No status changes have been recorded yet.')
              else
                for (final log in data.history) _HistoryTile(log: log),
            ],
          );
        },
      ),
    );
  }
}

class _DetailData {
  const _DetailData({required this.complaint, required this.history});

  final Complaint complaint;
  final List<ComplaintStatusLog> history;
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.log});

  final ComplaintStatusLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          '${formatApiLabel(log.oldStatus)} → ${formatApiLabel(log.newStatus)}',
        ),
        subtitle: Text(
          [
            if (log.changedByName.isNotEmpty) log.changedByName,
            formatDateTime(log.changedAt),
            if (log.note.isNotEmpty) log.note,
          ].join(' · '),
        ),
      ),
    );
  }
}
