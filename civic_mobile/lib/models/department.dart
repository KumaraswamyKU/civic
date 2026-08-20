import '../utils/json_helpers.dart';

/// Matches `DepartmentSerializer`.
class Department {
  const Department({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: asInt(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
