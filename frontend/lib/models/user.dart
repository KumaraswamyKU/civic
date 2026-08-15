class AppUser {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // citizen | dept_admin | super_admin
  final int? departmentId;
  final String? departmentName;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.departmentId,
    this.departmentName,
  });

  bool get isDeptAdmin => role == 'dept_admin';
  bool get isCitizen => role == 'citizen';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'citizen',
      departmentId: json['department'],
      departmentName: json['department_name'],
    );
  }
}
