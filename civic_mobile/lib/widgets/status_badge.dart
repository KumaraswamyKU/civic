import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  factory StatusBadge.forStatus(String status) {
    return StatusBadge(
      label: formatDisplayLabel(status),
      icon: _statusIcon(status),
      background: _statusBackground(status),
      foreground: _statusForeground(status),
    );
  }

  factory StatusBadge.forPriority(String priority) {
    return StatusBadge(
      label: formatDisplayLabel(priority).toUpperCase(),
      icon: Icons.flag_outlined,
      background: _priorityBackground(priority),
      foreground: _priorityForeground(priority),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = background ?? CivicTokens.mint;
    final fg = foreground ?? CivicTokens.hero;
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(CivicTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPipeline extends StatelessWidget {
  const StatusPipeline({super.key, required this.status});

  final String status;

  static const _steps = ['reported', 'in_progress', 'resolved'];

  @override
  Widget build(BuildContext context) {
    final current = status == 'rejected' ? -1 : _steps.indexOf(status);
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          _StepRow(
            label: formatDisplayLabel(_steps[i]),
            active: current >= i && current != -1,
            current: current == i,
            isLast: i == _steps.length - 1,
          ),
        ],
        if (status == 'rejected') ...[
          const SizedBox(height: 8),
          StatusBadge.forStatus('rejected'),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.active,
    required this.current,
    required this.isLast,
  });

  final String label;
  final bool active;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = active ? CivicTokens.primary : CivicTokens.muted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              current ? Icons.radio_button_checked : (active ? Icons.check_circle : Icons.circle_outlined),
              size: 18,
              color: color,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: active ? CivicTokens.mintDeep : CivicTokens.border,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: current ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'in_progress':
      return Icons.timelapse;
    case 'resolved':
      return Icons.check_circle_outline;
    case 'rejected':
      return Icons.highlight_off;
    case 'reported':
    default:
      return Icons.fiber_manual_record;
  }
}

Color _statusBackground(String status) {
  switch (status) {
    case 'in_progress':
      return CivicTokens.amberContainer;
    case 'resolved':
      return CivicTokens.successContainer;
    case 'rejected':
      return CivicTokens.dangerContainer;
    case 'reported':
    default:
      return CivicTokens.infoContainer;
  }
}

Color _statusForeground(String status) {
  switch (status) {
    case 'in_progress':
      return CivicTokens.amber;
    case 'resolved':
      return CivicTokens.success;
    case 'rejected':
      return CivicTokens.danger;
    case 'reported':
    default:
      return CivicTokens.info;
  }
}

Color _priorityBackground(String priority) {
  switch (priority) {
    case 'high':
      return CivicTokens.dangerContainer;
    case 'low':
      return CivicTokens.surfaceAlt;
    case 'medium':
    default:
      return CivicTokens.amberContainer;
  }
}

Color _priorityForeground(String priority) {
  switch (priority) {
    case 'high':
      return CivicTokens.danger;
    case 'low':
      return CivicTokens.muted;
    case 'medium':
    default:
      return CivicTokens.amber;
  }
}
