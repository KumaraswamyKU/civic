import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../models/complaint_status_log.dart';
import '../providers/auth_controller.dart';
import '../utils/formatters.dart';
import '../widgets/ops_widgets.dart';
import '../widgets/status_badge.dart';

class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final int complaintId;

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  Future<_Detail>? _future;
  bool _started = false;
  String _status = 'reported';
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = _load();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<_Detail> _load() async {
    final services = context.read<AuthController>().services;
    final complaint = await services.complaints.retrieve(widget.complaintId);
    final history = await services.complaints.history(widget.complaintId);
    _status = complaint.status;
    return _Detail(complaint: complaint, history: history);
  }

  Future<void> _saveStatus() async {
    setState(() => _saving = true);
    try {
      await context.read<AuthController>().services.complaints.updateStatus(
            id: widget.complaintId,
            status: _status,
            note: _note.text.trim(),
          );
      _note.clear();
      setState(() => _future = _load());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(formatComplaintId(widget.complaintId))),
      body: FutureBuilder<_Detail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(label: 'Loading complaint…');
          }
          if (snapshot.hasError) {
            return ErrorState(message: '${snapshot.error}', onRetry: () => setState(() => _future = _load()));
          }
          final complaint = snapshot.data!.complaint;
          final history = snapshot.data!.history;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(CivicTokens.radius),
                    child: ColoredBox(
                      color: CivicTokens.hero,
                      child: complaint.imageUrl.isEmpty
                          ? const Center(child: Icon(Icons.image_outlined, color: Colors.white70, size: 48))
                          : Image.network(
                              complaint.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(child: Text('Photo unavailable', style: TextStyle(color: Colors.white))),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AiCard(complaint: complaint),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoCard(title: 'Department', child: Text(complaint.departmentName?.isNotEmpty == true ? complaint.departmentName! : 'Unassigned')),
                  _InfoCard(
                    title: 'Priority',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriorityBadge(priority: complaint.priority),
                        if (complaint.priority == 'high')
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('HIGH PRIORITY · Requires attention', style: TextStyle(color: CivicTokens.danger, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),
                  _InfoCard(
                    title: 'Citizen',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(complaint.citizenName.isEmpty ? '—' : complaint.citizenName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(complaint.citizenEmail.isEmpty ? '—' : complaint.citizenEmail),
                      ],
                    ),
                  ),
                  _InfoCard(
                    title: 'Location',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${formatCoord(complaint.latitude)}, ${formatCoord(complaint.longitude)}'),
                        Text(complaint.addressText.isEmpty ? 'No address provided' : complaint.addressText),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Description',
                child: Text(complaint.description.isEmpty ? 'No description provided.' : complaint.description),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Update status',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _status,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'reported', child: Text('Reported')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In progress')),
                        DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      ],
                      onChanged: _saving ? null : (value) => setState(() => _status = value ?? _status),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _note,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        hintText: 'Enter an update for the citizen…',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _saving ? null : _saveStatus,
                      child: Text(_saving ? 'Updating…' : 'Update status'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Report history', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 12),
              if (history.isEmpty)
                const Text('No status changes have been recorded yet.')
              else
                for (final log in history) _HistoryRow(log: log),
            ],
          );
        },
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CivicTokens.hero,
        borderRadius: BorderRadius.circular(CivicTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI CLASSIFICATION', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(issueTypeIcon(complaint.issueType), color: CivicTokens.mint, size: 28),
              const SizedBox(width: 10),
              Text(formatLabel(complaint.issueType), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Confidence  ${formatConfidence(complaint.confidence)}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Automatically assigned to ${complaint.departmentName?.isNotEmpty == true ? complaint.departmentName! : 'no department yet'}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CivicTokens.surface,
          borderRadius: BorderRadius.circular(CivicTokens.radius),
          border: Border.all(color: CivicTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: CivicTokens.muted, letterSpacing: 0.6)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.log});

  final ComplaintStatusLog log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 10, color: CivicTokens.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateTime(log.changedAt), style: const TextStyle(color: CivicTokens.muted, fontSize: 12)),
                Text('${formatLabel(log.oldStatus)} → ${formatLabel(log.newStatus)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                if (log.note.isNotEmpty) Text('"${log.note}"'),
                if (log.changedByName.isNotEmpty) Text(log.changedByName, style: const TextStyle(color: CivicTokens.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Detail {
  const _Detail({required this.complaint, required this.history});

  final Complaint complaint;
  final List<ComplaintStatusLog> history;
}
