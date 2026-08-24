import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      'in_progress' => (CivicTokens.amberContainer, CivicTokens.amber, Icons.timelapse),
      'resolved' => (CivicTokens.successContainer, CivicTokens.success, Icons.check_circle_outline),
      'rejected' => (CivicTokens.dangerContainer, CivicTokens.danger, Icons.highlight_off),
      _ => (CivicTokens.infoContainer, CivicTokens.info, Icons.fiber_manual_record),
    };
    return _Chip(label: formatLabel(status), background: colors.$1, foreground: colors.$2, icon: colors.$3);
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final colors = switch (priority) {
      'high' => (CivicTokens.dangerContainer, CivicTokens.danger, Icons.priority_high),
      'low' => (CivicTokens.surfaceAlt, CivicTokens.muted, Icons.low_priority),
      _ => (CivicTokens.amberContainer, CivicTokens.amber, Icons.flag_outlined),
    };
    return _Chip(
      label: formatLabel(priority).toUpperCase(),
      background: colors.$1,
      foreground: colors.$2,
      icon: colors.$3,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

IconData issueTypeIcon(String issueType) {
  switch (issueType) {
    case 'garbage':
      return Icons.delete_outline;
    case 'streetlight':
      return Icons.lightbulb_outline;
    case 'water_leakage':
      return Icons.water_drop_outlined;
    default:
      return Icons.report_outlined;
  }
}
