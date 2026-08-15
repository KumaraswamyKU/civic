import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/complaint.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _auth.getAccessToken();
    return {'Authorization': 'Bearer $token'};
  }

  Future<List<Complaint>> fetchComplaints() async {
    final res = await http.get(Uri.parse(ApiConfig.complaints), headers: await _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Failed to load complaints.');
    }
    final data = jsonDecode(res.body);
    final results = data is Map && data.containsKey('results') ? data['results'] : data;
    return (results as List).map((e) => Complaint.fromJson(e)).toList();
  }

  Future<Complaint> submitComplaint({
    required File imageFile,
    required String description,
    required double latitude,
    required double longitude,
    String addressText = '',
  }) async {
    final uri = Uri.parse(ApiConfig.complaints);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _authHeaders());
    request.fields['description'] = description;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['address_text'] = addressText;
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 201) {
      throw Exception('Failed to submit complaint: ${res.body}');
    }
    return Complaint.fromJson(jsonDecode(res.body));
  }

  Future<void> updateComplaintStatus(int id, String status, {String note = ''}) async {
    final uri = Uri.parse('${ApiConfig.complaints}$id/status/');
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    final res = await http.patch(uri, headers: headers, body: jsonEncode({'status': status, 'note': note}));
    if (res.statusCode != 200) {
      throw Exception('Failed to update status.');
    }
  }

  Future<Map<String, dynamic>> fetchDashboardSummary() async {
    final res = await http.get(Uri.parse(ApiConfig.reportSummary), headers: await _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Failed to load dashboard summary.');
    }
    return jsonDecode(res.body);
  }
}
