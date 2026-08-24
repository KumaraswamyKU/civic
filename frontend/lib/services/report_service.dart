import '../config/api_config.dart';
import '../models/dashboard_summary.dart';
import 'api_client.dart';

class ReportService {
  ReportService(this._client);

  final ApiClient _client;

  Future<DashboardSummary> fetchSummary() async {
    final response = await _client.get(ApiConfig.reportSummary);
    return DashboardSummary.fromJson(_client.decodeObject(response));
  }

  Future<List<int>> downloadCsv() async {
    final response = await _client.get(ApiConfig.reportExportCsv);
    _client.ensureSuccess(response);
    return response.bodyBytes;
  }
}
