class Complaint {
  final int id;
  final String imageUrl;
  final String description;
  final double latitude;
  final double longitude;
  final String issueType;
  final double? confidence;
  final String priority;
  final String status;
  final String? departmentName;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.issueType,
    required this.confidence,
    required this.priority,
    required this.status,
    required this.departmentName,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      imageUrl: json['image'] ?? '',
      description: json['description'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0,
      issueType: json['issue_type'] ?? 'unknown',
      confidence: json['classification_confidence'] != null
          ? double.tryParse(json['classification_confidence'].toString())
          : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'reported',
      departmentName: json['department_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
