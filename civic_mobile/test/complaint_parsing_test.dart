import 'package:flutter_test/flutter_test.dart';

import 'package:civic_mobile/models/complaint.dart';
import 'package:civic_mobile/models/complaint_status_log.dart';
import 'package:civic_mobile/models/paginated_response.dart';
import 'package:civic_mobile/utils/formatters.dart';

void main() {
  test('Complaint.fromJson maps ComplaintSerializer fields', () {
    final complaint = Complaint.fromJson({
      'id': 7,
      'citizen': 3,
      'citizen_name': 'Asha',
      'image': '/media/complaints/3/photo.jpg',
      'description': 'Garbage near the park',
      'latitude': '12.971600',
      'longitude': '77.594600',
      'address_text': 'MG Road',
      'issue_type': 'garbage',
      'classification_confidence': 0.91,
      'priority': 'high',
      'status': 'reported',
      'department': 1,
      'department_name': 'Waste Management Department',
      'created_at': '2026-08-20T10:00:00Z',
      'updated_at': '2026-08-20T10:00:00Z',
      'resolved_at': null,
    });

    expect(complaint.id, 7);
    expect(complaint.citizenName, 'Asha');
    expect(complaint.issueType, 'garbage');
    expect(complaint.status, 'reported');
    expect(complaint.priority, 'high');
    expect(complaint.latitude, closeTo(12.9716, 0.000001));
    expect(formatApiLabel(complaint.status), 'reported');
    expect(formatConfidence(complaint.classificationConfidence), '91.0%');
  });

  test('PaginatedResponse reads DRF count/next/previous/results', () {
    final page = PaginatedResponse.fromJson({
      'count': 21,
      'next': 'http://127.0.0.1:8000/api/complaints/?page=2',
      'previous': null,
      'results': [
        {
          'id': 1,
          'citizen': 3,
          'citizen_name': 'Asha',
          'image': '',
          'description': '',
          'latitude': '0',
          'longitude': '0',
          'address_text': '',
          'issue_type': 'unknown',
          'classification_confidence': null,
          'priority': 'medium',
          'status': 'reported',
          'department': null,
          'department_name': null,
          'created_at': '2026-08-20T10:00:00Z',
          'updated_at': null,
          'resolved_at': null,
        },
      ],
    }, Complaint.fromJson);

    expect(page.count, 21);
    expect(page.hasNext, isTrue);
    expect(page.results, hasLength(1));
    expect(page.results.first.id, 1);
  });

  test('ComplaintStatusLog.fromJson maps history serializer fields', () {
    final log = ComplaintStatusLog.fromJson({
      'id': 4,
      'old_status': 'reported',
      'new_status': 'in_progress',
      'note': 'Crew assigned',
      'changed_by_name': 'Admin',
      'changed_at': '2026-08-20T12:00:00Z',
    });
    expect(log.oldStatus, 'reported');
    expect(log.newStatus, 'in_progress');
    expect(formatApiLabel(log.newStatus), 'in progress');
  });
}
