String formatApiLabel(String value) {
  if (value.isEmpty) {
    return '—';
  }
  return value.replaceAll('_', ' ');
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
