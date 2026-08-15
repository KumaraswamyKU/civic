import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/complaint_card.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'upload_complaint_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  late Future<List<Complaint>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _apiService.fetchComplaints();
  }

  void _refresh() {
    setState(() => _complaintsFuture = _apiService.fetchComplaints());
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDeptAdmin = widget.user.isDeptAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDeptAdmin
            ? '${widget.user.departmentName ?? 'Department'} Admin'
            : 'My Reported Issues'),
        actions: [
          if (isDeptAdmin)
            IconButton(
              icon: const Icon(Icons.dashboard_outlined),
              tooltip: 'Dashboard',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
            ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<Complaint>>(
          future: _complaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final complaints = snapshot.data ?? [];
            if (complaints.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No complaints yet.')),
                ],
              );
            }
            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, i) => ComplaintCard(complaint: complaints[i]),
            );
          },
        ),
      ),
      floatingActionButton: widget.user.isCitizen
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Report issue'),
              onPressed: () async {
                final submitted = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const UploadComplaintScreen()),
                );
                if (submitted == true) _refresh();
              },
            )
          : null,
    );
  }
}
