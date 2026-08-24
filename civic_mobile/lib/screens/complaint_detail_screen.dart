import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../models/complaint_status_log.dart';
import '../providers/auth_provider.dart';
import '../utils/error_messages.dart';
import '../utils/formatters.dart';
import '../utils/issue_visual.dart';
import '../widgets/civic_network_image.dart';
import '../widgets/feedback_views.dart';
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
      appBar: AppBar(title: Text(formatComplaintId(widget.complaintId))),
      body: FutureBuilder<_DetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(label: 'Loading complaint…');
          }
          if (snapshot.hasError) {
            return ErrorState(
              title: 'Unable to load this complaint',
              message: userFacingError(snapshot.error!),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final complaint = snapshot.data!.complaint;
          final history = snapshot.data!.history;
          final place = locationSnippet(complaint.addressText);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CivicNetworkImage(
                    url: complaint.imageUrl,
                    fit: BoxFit.contain,
                    background: CivicTokens.hero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AiPanel(complaint: complaint),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Report status',
                child: StatusPipeline(status: complaint.status),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Priority',
                child: StatusBadge.forPriority(complaint.priority),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Description',
                child: Text(
                  complaint.description.isEmpty ? 'No description provided.' : complaint.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Location',
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: CivicTokens.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.isNotEmpty
                            ? (complaint.addressText.isEmpty ? place : complaint.addressText)
                            : '${formatCoordinate(complaint.latitude)}, ${formatCoordinate(complaint.longitude)}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Report history', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              if (history.isEmpty)
                Text('Complaint reported', style: Theme.of(context).textTheme.bodyMedium)
              else
                for (final log in history) _HistoryTile(log: log),
            ],
          );
        },
      ),
    );
  }
}

class _AiPanel extends StatelessWidget {
  const _AiPanel({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CivicTokens.hero,
        borderRadius: BorderRadius.circular(CivicTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI DETECTED',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(issueTypeIcon(complaint.issueType), color: CivicTokens.mint, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  formatDisplayLabel(complaint.issueType),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${formatConfidence(complaint.classificationConfidence)}  ·  AI confidence',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Assigned automatically to',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
          ),
          Text(
            complaint.departmentName?.isNotEmpty == true
                ? complaint.departmentName!
                : 'No department yet',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicTokens.surface,
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
        border: Border.all(color: CivicTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: CivicTokens.muted,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 10, color: CivicTokens.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateShort(log.changedAt), style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '${formatDisplayLabel(log.oldStatus)} → ${formatDisplayLabel(log.newStatus)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (log.note.isNotEmpty) Text(log.note),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
