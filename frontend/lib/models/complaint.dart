import '../config/api_config.dart';

class Complaint {
  Complaint({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.citizenEmail,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.issueType,
    required this.confidence,
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
  final String citizenEmail;
  final String imageUrl;
  final String description;
  final double latitude;
  final double longitude;
  final String addressText;
  final String issueType;
  final double? confidence;
  final String priority;
  final String status;
  final int? departmentId;
  final String? departmentName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      citizenId: json['citizen'] is int ? json['citizen'] as int : int.tryParse('${json['citizen']}') ?? 0,
      citizenName: json['citizen_name']?.toString() ?? '',
      citizenEmail: json['citizen_email']?.toString() ?? '',
      imageUrl: ApiConfig.resolveMediaUrl(json['image']?.toString()),
      description: json['description']?.toString() ?? '',
      latitude: double.tryParse('${json['latitude']}') ?? 0,
      longitude: double.tryParse('${json['longitude']}') ?? 0,
      addressText: json['address_text']?.toString() ?? '',
      issueType: json['issue_type']?.toString() ?? 'unknown',
      confidence: json['classification_confidence'] == null
          ? null
          : double.tryParse('${json['classification_confidence']}'),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'reported',
      departmentId: json['department'] is int
          ? json['department'] as int
          : int.tryParse('${json['department'] ?? ''}'),
      departmentName: json['department_name']?.toString(),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
      resolvedAt: DateTime.tryParse('${json['resolved_at'] ?? ''}'),
    );
  }
}
