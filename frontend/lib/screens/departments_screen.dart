import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/department.dart';
import '../providers/auth_controller.dart';
import '../services/complaint_service.dart';
import '../widgets/ops_widgets.dart';
import 'complaints_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  Future<List<_DeptStats>>? _future;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = _load();
  }

  Future<List<_DeptStats>> _load() async {
    final services = context.read<AuthController>().services;
    final user = context.read<AuthController>().user;
    var departments = await services.departments.list();
    if (user?.isDeptAdmin == true && user?.departmentId != null) {
      departments = departments.where((d) => d.id == user!.departmentId).toList();
    }

    final stats = <_DeptStats>[];
    for (final dept in departments) {
      final total = await services.complaints.list(ComplaintQuery(page: 1, departmentId: user?.isSuperAdmin == true ? dept.id : null));
      final resolved = await services.complaints.list(
        ComplaintQuery(page: 1, departmentId: user?.isSuperAdmin == true ? dept.id : null, status: 'resolved'),
      );
      stats.add(_DeptStats(department: dept, total: total.count, resolved: resolved.count, active: (total.count - resolved.count).clamp(0, 1 << 30)));
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_DeptStats>>(
      future: _future,
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const PageHeader(
              title: 'Departments',
              subtitle: 'Workload by automatically assigned civic department.',
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LoadingState(label: 'Loading departments…')
            else if (snapshot.hasError)
              ErrorState(message: '${snapshot.error}', onRetry: () => setState(() => _future = _load()))
            else if (snapshot.data!.isEmpty)
              const EmptyState(title: 'No departments', message: 'Seed departments from the backend to get started.')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in snapshot.data!)
                    SizedBox(
                      width: 320,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.department.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                              const SizedBox(height: 12),
                              Text('Total: ${item.total}'),
                              Text('Active: ${item.active}'),
                              Text('Resolved: ${item.resolved}'),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(title: Text(item.department.name)),
                                        body: ComplaintsScreen(initialDepartmentId: item.department.id),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('View complaints'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _DeptStats {
  const _DeptStats({
    required this.department,
    required this.total,
    required this.active,
    required this.resolved,
  });

  final Department department;
  final int total;
  final int active;
  final int resolved;
}
