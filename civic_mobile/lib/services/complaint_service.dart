import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/complaint.dart';
import '../models/complaint_status_log.dart';
import '../models/paginated_response.dart';
import 'api_client.dart';

class ComplaintService {
  ComplaintService(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<Complaint>> list({int page = 1}) async {
    final response = await _client.get('${ApiConfig.complaints}?page=$page');
    return PaginatedResponse.fromJson(
      _client.decodeObject(response),
      Complaint.fromJson,
    );
  }

  Future<Complaint> retrieve(int id) async {
    final response = await _client.get(ApiConfig.complaintDetail(id));
    return Complaint.fromJson(_client.decodeObject(response));
  }

  /// POST /api/complaints/ as multipart (ImageField + GPS fields).
  ///
  /// Create responses use `ComplaintCreateSerializer` (id, image, description,
  /// lat/lng, address). A follow-up GET loads the full `ComplaintSerializer`.
  Future<Complaint> create({
    required List<int> imageBytes,
    required String imageFilename,
    required String description,
    required double latitude,
    required double longitude,
    String addressText = '',
  }) async {
    Future<http.Response> send() {
      return _client.sendMultipart(
        _buildCreateRequest(
          imageBytes: imageBytes,
          imageFilename: imageFilename,
          description: description,
          latitude: latitude,
          longitude: longitude,
          addressText: addressText,
        ),
      );
    }

    var response = await send();
    if (response.statusCode == 401) {
      final refreshed = await _client.tryRefresh();
      if (refreshed) {
        response = await send();
      }
    }
    _client.ensureSuccess(response);
    final created = Complaint.fromJson(_client.decodeObject(response));
    try {
      return await retrieve(created.id);
    } catch (_) {
      return created;
    }
  }

  http.MultipartRequest _buildCreateRequest({
    required List<int> imageBytes,
    required String imageFilename,
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
  }) {
    final request = http.MultipartRequest('POST', ApiConfig.uri(ApiConfig.complaints));
    request.fields['description'] = description;
    request.fields['latitude'] = latitude.toStringAsFixed(6);
    request.fields['longitude'] = longitude.toStringAsFixed(6);
    request.fields['address_text'] = addressText;
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFilename,
        contentType: _imageMediaType(imageFilename),
      ),
    );
    return request;
  }

  MediaType _imageMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lower.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    return MediaType('image', 'jpeg');
  }

  Future<Complaint> updateStatus({
    required int id,
    required String status,
    String note = '',
  }) async {
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
