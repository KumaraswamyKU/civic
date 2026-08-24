class ComplaintStatusLog {
  const ComplaintStatusLog({
    required this.id,
    required this.oldStatus,
    required this.newStatus,
    required this.note,
    required this.changedByName,
    required this.changedAt,
  });

  final int id;
  final String oldStatus;
  final String newStatus;
  final String note;
  final String changedByName;
  final DateTime changedAt;

  factory ComplaintStatusLog.fromJson(Map<String, dynamic> json) {
    return ComplaintStatusLog(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      oldStatus: json['old_status']?.toString() ?? '',
      newStatus: json['new_status']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      changedByName: json['changed_by_name']?.toString() ?? '',
      changedAt: DateTime.tryParse('${json['changed_at'] ?? ''}') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
