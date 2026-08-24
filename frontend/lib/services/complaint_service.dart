import '../config/api_config.dart';
import '../models/complaint.dart';
import '../models/complaint_status_log.dart';
import '../models/paginated_response.dart';
import 'api_client.dart';

class ComplaintQuery {
  const ComplaintQuery({
    this.page = 1,
    this.status,
    this.priority,
    this.departmentId,
    this.issueType,
    this.search,
    this.ordering = '-created_at',
  });

  final int page;
  final String? status;
  final String? priority;
  final int? departmentId;
  final String? issueType;
  final String? search;
  final String ordering;

  String toQueryString() {
    final params = <String, String>{
      'page': '$page',
      'ordering': ordering,
    };
    if (status != null && status!.isNotEmpty) params['status'] = status!;
    if (priority != null && priority!.isNotEmpty) params['priority'] = priority!;
    if (departmentId != null) params['department'] = '$departmentId';
    if (issueType != null && issueType!.isNotEmpty) params['issue_type'] = issueType!;
    if (search != null && search!.trim().isNotEmpty) params['search'] = search!.trim();
    return params.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&');
  }
}

class ComplaintService {
  ComplaintService(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<Complaint>> list(ComplaintQuery query) async {
    final response = await _client.get('${ApiConfig.complaints}?${query.toQueryString()}');
    return PaginatedResponse.fromJson(_client.decodeObject(response), Complaint.fromJson);
  }

  Future<Complaint> retrieve(int id) async {
    final response = await _client.get(ApiConfig.complaintDetail(id));
    return Complaint.fromJson(_client.decodeObject(response));
  }

  Future<Complaint> updateStatus({required int id, required String status, String note = ''}) async {
    final response = await _client.patchJson(
      ApiConfig.complaintStatus(id),
      body: {'status': status, 'note': note},
    );
    return Complaint.fromJson(_client.decodeObject(response));
  }

  Future<List<ComplaintStatusLog>> history(int id) async {
    final response = await _client.get(ApiConfig.complaintHistory(id));
    return _client.decodeList(response).map((row) {
      return ComplaintStatusLog.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();
  }
}
