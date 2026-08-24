String formatApiLabel(String value) {
  if (value.isEmpty) {
    return '—';
  }
  return value.replaceAll('_', ' ');
}

/// Title-cased label for UI chips and headings (`in_progress` → `In Progress`).
String formatDisplayLabel(String value) {
  final raw = formatApiLabel(value);
  if (raw == '—') {
    return raw;
  }
  return raw
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String formatDateShort(DateTime? value) {
  if (value == null) {
    return '—';
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String formatComplaintId(int id) {
  return 'Complaint #${id.toString().padLeft(3, '0')}';
}

String formatDateTime(DateTime? value) {
  if (value == null) {
    return '—';
  }
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

String formatCoordinate(double value) => value.toStringAsFixed(6);

String formatConfidence(double? value) {
  if (value == null) {
    return '—';
  }
  return '${(value * 100).toStringAsFixed(1)}%';
}
