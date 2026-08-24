import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/complaint.dart';
import '../models/department.dart';
import '../models/paginated_response.dart';
import '../providers/auth_controller.dart';
import '../services/complaint_service.dart';
import '../widgets/complaint_table.dart';
import '../widgets/ops_widgets.dart';
import 'complaint_detail_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key, this.initialDepartmentId});

  final int? initialDepartmentId;

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _search = TextEditingController();
  int _page = 1;
  String _status = '';
  String _priority = '';
  String _issueType = '';
  int? _departmentId;
  String _ordering = '-created_at';
  Future<PaginatedResponse<Complaint>>? _future;
  List<Department> _departments = [];
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _departmentId = widget.initialDepartmentId;
    _loadDepartments();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final depts = await context.read<AuthController>().services.departments.list();
      if (mounted) setState(() => _departments = depts);
    } catch (_) {}
  }

  void _reload() {
    final services = context.read<AuthController>().services;
    setState(() {
      _future = services.complaints.list(ComplaintQuery(
        page: _page,
        status: _status.isEmpty ? null : _status,
        priority: _priority.isEmpty ? null : _priority,
        issueType: _issueType.isEmpty ? null : _issueType,
        departmentId: _departmentId,
        search: _search.text,
        ordering: _ordering,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const PageHeader(
          title: 'Complaints',
          subtitle: 'Search, filter, and process civic reports.',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  hintText: 'Search ID, citizen, description…',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) {
                  _page = 1;
                  _reload();
                },
              ),
            ),
            _Filter(
              label: 'Status',
              value: _status,
              items: const {'': 'All', 'reported': 'Reported', 'in_progress': 'In progress', 'resolved': 'Resolved', 'rejected': 'Rejected'},
              onChanged: (v) {
                _status = v;
                _page = 1;
                _reload();
              },
            ),
            _Filter(
              label: 'Priority',
              value: _priority,
              items: const {'': 'All', 'high': 'High', 'medium': 'Medium', 'low': 'Low'},
              onChanged: (v) {
                _priority = v;
                _page = 1;
                _reload();
              },
            ),
            _Filter(
              label: 'Issue',
              value: _issueType,
              items: const {'': 'All', 'garbage': 'Garbage', 'streetlight': 'Streetlight', 'water_leakage': 'Water leakage', 'unknown': 'Unknown'},
              onChanged: (v) {
                _issueType = v;
                _page = 1;
                _reload();
              },
            ),
            if (user?.isSuperAdmin == true)
              DropdownButton<int?>(
                value: _departmentId,
                hint: const Text('Department'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All departments')),
                  for (final dept in _departments)
                    DropdownMenuItem(value: dept.id, child: Text(dept.name)),
                ],
                onChanged: (value) {
                  _departmentId = value;
                  _page = 1;
                  _reload();
                },
              ),
            DropdownButton<String>(
              value: _ordering,
              items: const [
                DropdownMenuItem(value: '-created_at', child: Text('Newest')),
                DropdownMenuItem(value: 'created_at', child: Text('Oldest')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _ordering = value;
                _page = 1;
                _reload();
              },
            ),
            FilledButton(
              onPressed: () {
                _page = 1;
                _reload();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<PaginatedResponse<Complaint>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState(label: 'Loading complaints…');
            }
            if (snapshot.hasError) {
              return ErrorState(message: '${snapshot.error}', onRetry: _reload);
            }
            final page = snapshot.data!;
            if (page.results.isEmpty) {
              return const EmptyState(title: 'No complaints found', message: 'Try a different search or filter.');
            }
            return Column(
              children: [
                ComplaintTable(
                  complaints: page.results,
                  onOpen: (complaint) async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ComplaintDetailScreen(complaintId: complaint.id)),
                    );
                    _reload();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${page.count} total'),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: page.hasPrevious
                          ? () {
                              _page -= 1;
                              _reload();
                            }
                          : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: page.hasNext
                          ? () {
                              _page += 1;
                              _reload();
                            }
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      hint: Text(label),
      items: [
        for (final entry in items.entries) DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
