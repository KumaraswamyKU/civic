import '../utils/json_helpers.dart';

/// DRF `PageNumberPagination` envelope (`count`, `next`, `previous`, `results`).
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  bool get hasNext => next != null && next!.isNotEmpty;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final raw = json['results'];
    final items = <T>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map<String, dynamic>) {
          items.add(itemFromJson(row));
        } else if (row is Map) {
          items.add(itemFromJson(Map<String, dynamic>.from(row)));
        }
      }
    }
    return PaginatedResponse<T>(
      count: asInt(json['count'], fallback: items.length),
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: items,
    );
  }
}
