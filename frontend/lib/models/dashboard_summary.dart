class DashboardSummary {
  const DashboardSummary({
    required this.totalComplaints,
    required this.byStatus,
    required this.byPriority,
    required this.byIssueType,
    required this.byDepartment,
    this.avgResolutionHours,
  });

  final int totalComplaints;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;
  final Map<String, int> byIssueType;
  final Map<String, int> byDepartment;
  final double? avgResolutionHours;

  int statusCount(String key) => byStatus[key] ?? 0;
  int priorityCount(String key) => byPriority[key] ?? 0;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalComplaints: _asInt(json['total_complaints']),
      byStatus: _countMap(json['by_status']),
      byPriority: _countMap(json['by_priority']),
      byIssueType: _countMap(json['by_issue_type']),
      byDepartment: _countMap(json['by_department']),
      avgResolutionHours: json['avg_resolution_hours'] == null
          ? null
          : double.tryParse('${json['avg_resolution_hours']}'),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static Map<String, int> _countMap(dynamic value) {
    if (value is! Map) return {};
    return value.map((key, count) => MapEntry(key.toString(), _asInt(count)));
  }
}
