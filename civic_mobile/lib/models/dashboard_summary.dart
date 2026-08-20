import '../utils/json_helpers.dart';

/// Matches `DashboardSummaryView` JSON from `apps.reports.views`.
class DashboardSummary {
  const DashboardSummary({
    required this.generatedAt,
    required this.totalComplaints,
    required this.byStatus,
    required this.byPriority,
    required this.byIssueType,
    required this.byDepartment,
    this.avgResolutionHours,
  });

  final DateTime? generatedAt;
  final int totalComplaints;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;
  final Map<String, int> byIssueType;
  final Map<String, int> byDepartment;
  final double? avgResolutionHours;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      generatedAt: asDateTime(json['generated_at']),
      totalComplaints: asInt(json['total_complaints']),
      byStatus: asCountMap(json['by_status']),
      byPriority: asCountMap(json['by_priority']),
      byIssueType: asCountMap(json['by_issue_type']),
      byDepartment: asCountMap(json['by_department']),
      avgResolutionHours: asNullableDouble(json['avg_resolution_hours']),
    );
  }
}
