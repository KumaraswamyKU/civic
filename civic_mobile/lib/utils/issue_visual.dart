import 'package:flutter/material.dart';

IconData issueTypeIcon(String issueType) {
  switch (issueType) {
    case 'garbage':
      return Icons.delete_outline_rounded;
    case 'streetlight':
      return Icons.lightbulb_outline_rounded;
    case 'water_leakage':
      return Icons.water_drop_outlined;
    default:
      return Icons.report_outlined;
  }
}

String locationSnippet(String address) {
  final trimmed = address.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final parts = trimmed.split(',').map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
  if (parts.length >= 2) {
    return parts[parts.length - 2];
  }
  return parts.first;
}
