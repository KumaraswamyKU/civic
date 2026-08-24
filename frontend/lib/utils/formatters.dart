String formatLabel(String value) {
  if (value.isEmpty) return '—';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String formatComplaintId(int id) => 'Complaint #${id.toString().padLeft(3, '0')}';

String formatConfidence(double? value) {
  if (value == null) return '—';
  return '${(value * 100).toStringAsFixed(1)}%';
}

String formatDate(DateTime? value) {
  if (value == null) return '—';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String formatDateTime(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${formatDate(local)} ${two(local.hour)}:${two(local.minute)}';
}

String formatCoord(double value) => value.toStringAsFixed(6);
