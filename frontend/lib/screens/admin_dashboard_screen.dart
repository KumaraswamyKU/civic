import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _apiService = ApiService();
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _apiService.fetchDashboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          final byStatus = Map<String, dynamic>.from(data['by_status'] ?? {});
          final byPriority = Map<String, dynamic>.from(data['by_priority'] ?? {});

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatTile(label: 'Total complaints', value: '${data['total_complaints']}'),
              _StatTile(
                label: 'Avg. resolution time',
                value: data['avg_resolution_hours'] != null
                    ? '${data['avg_resolution_hours']} hrs'
                    : 'N/A',
              ),
              const SizedBox(height: 24),
              Text('By status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: byStatus.isEmpty
                    ? const Center(child: Text('No data yet'))
                    : PieChart(PieChartData(sections: _pieSections(byStatus))),
              ),
              const SizedBox(height: 24),
              Text('By priority', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: byPriority.isEmpty
                    ? const Center(child: Text('No data yet'))
                    : BarChart(_barData(byPriority)),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _pieSections(Map<String, dynamic> data) {
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];
    int i = 0;
    return data.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: (e.value as num).toDouble(),
        title: '${e.key}\n${e.value}',
        radius: 70,
        titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  BarChartData _barData(Map<String, dynamic> data) {
    final keys = data.keys.toList();
    return BarChartData(
      barGroups: List.generate(keys.length, (i) {
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: (data[keys[i]] as num).toDouble(), width: 28, color: Colors.indigo),
        ]);
      }),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(keys[idx]));
            },
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
