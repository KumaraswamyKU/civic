import '../config/api_config.dart';
import '../models/department.dart';
import '../models/paginated_response.dart';
import 'api_client.dart';

class DepartmentService {
  DepartmentService(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<Department>> list({int page = 1}) async {
    final response = await _client.get('${ApiConfig.departments}?page=$page');
    return PaginatedResponse.fromJson(
      _client.decodeObject(response),
      Department.fromJson,
    );
  }
}
