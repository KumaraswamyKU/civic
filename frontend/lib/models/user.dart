class AppUser {
  AppUser({
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

  bool get isDeptAdmin => role == 'dept_admin';
  bool get isCitizen => role == 'citizen';
  bool get isSuperAdmin => role == 'super_admin';
  bool get isStaff => isDeptAdmin || isSuperAdmin;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'Operator';
    }
    return parts.first;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      role: json['role']?.toString() ?? 'citizen',
      departmentId: json['department'] is int
          ? json['department'] as int
          : int.tryParse('${json['department'] ?? ''}'),
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
