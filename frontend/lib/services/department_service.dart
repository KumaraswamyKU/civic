import '../config/api_config.dart';
import '../models/department.dart';
import 'api_client.dart';

class DepartmentService {
  DepartmentService(this._client);

  final ApiClient _client;

  Future<List<Department>> list() async {
    final response = await _client.get(ApiConfig.departments);
    return _client.decodeList(response).map((row) {
      return Department.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();
  }
}
