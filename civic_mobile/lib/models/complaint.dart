import '../config/api_config.dart';
import '../utils/json_helpers.dart';

/// Matches `ComplaintSerializer` from `apps.complaints.serializers`.
class Complaint {
  const Complaint({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.issueType,
    this.classificationConfidence,
    required this.priority,
    required this.status,
    this.departmentId,
    this.departmentName,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  final int id;
  final int citizenId;
  final String citizenName;
  final String imageUrl;
  final String description;
  final double latitude;
  final double longitude;
  final String addressText;
  final String issueType;
  final double? classificationConfidence;
  final String priority;
  final String status;
  final int? departmentId;
  final String? departmentName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: asInt(json['id']),
      citizenId: asInt(json['citizen']),
      citizenName: json['citizen_name']?.toString() ?? '',
      imageUrl: ApiConfig.resolveMediaUrl(json['image']?.toString()),
      description: json['description']?.toString() ?? '',
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      addressText: json['address_text']?.toString() ?? '',
      issueType: json['issue_type']?.toString() ?? 'unknown',
      classificationConfidence: asNullableDouble(json['classification_confidence']),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'reported',
      departmentId: asNullableInt(json['department']),
      departmentName: json['department_name']?.toString(),
      createdAt: asDateTime(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: asDateTime(json['updated_at']),
      resolvedAt: asDateTime(json['resolved_at']),
    );
  }
}
