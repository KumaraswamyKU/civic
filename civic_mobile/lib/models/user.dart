import '../utils/json_helpers.dart';

/// Matches `UserSerializer` from `apps.accounts.serializers`.
class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.departmentId,
    this.departmentName,
  });

  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final int? departmentId;
  final String? departmentName;

  bool get isCitizen => role == 'citizen';
  bool get isDeptAdmin => role == 'dept_admin';
  bool get isSuperAdmin => role == 'super_admin';
  bool get isStaffUser => isDeptAdmin || isSuperAdmin;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'there';
    }
    return parts.first;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: asInt(json['id']),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      role: json['role']?.toString() ?? 'citizen',
      departmentId: asNullableInt(json['department']),
      departmentName: json['department_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'department': departmentId,
      'department_name': departmentName,
    };
  }
}
