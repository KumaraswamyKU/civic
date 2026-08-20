import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
  });

  final String label;
  final Color? background;
  final Color? foreground;

  factory StatusBadge.forStatus(String status) {
    return StatusBadge(
      label: formatApiLabel(status),
      background: _statusBackground(status),
      foreground: _statusForeground(status),
    );
  }

  factory StatusBadge.forPriority(String priority) {
    return StatusBadge(
      label: formatApiLabel(priority),
      background: _priorityBackground(priority),
      foreground: _priorityForeground(priority),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground ?? theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color _statusBackground(String status) {
  switch (status) {
    case 'in_progress':
      return const Color(0xFFFFF3CD);
    case 'resolved':
      return const Color(0xFFD1E7DD);
    case 'rejected':
      return const Color(0xFFF8D7DA);
    case 'reported':
    default:
      return const Color(0xFFDCEBFF);
  }
}

Color _statusForeground(String status) {
  switch (status) {
    case 'in_progress':
      return const Color(0xFF664D03);
    case 'resolved':
      return const Color(0xFF0F5132);
    case 'rejected':
      return const Color(0xFF842029);
    case 'reported':
    default:
      return const Color(0xFF084298);
  }
}

Color _priorityBackground(String priority) {
  switch (priority) {
    case 'high':
      return const Color(0xFFF8D7DA);
    case 'low':
      return const Color(0xFFE2E3E5);
    case 'medium':
    default:
      return const Color(0xFFFFF3CD);
  }
}

Color _priorityForeground(String priority) {
  switch (priority) {
    case 'high':
      return const Color(0xFF842029);
    case 'low':
      return const Color(0xFF41464B);
    case 'medium':
    default:
      return const Color(0xFF664D03);
  }
}
