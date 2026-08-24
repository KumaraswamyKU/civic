class Department {
  const Department({required this.id, required this.code, required this.name});

  final int id;
  final String code;
  final String name;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
