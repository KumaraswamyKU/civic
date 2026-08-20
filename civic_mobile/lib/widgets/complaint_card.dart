import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  final Complaint complaint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${complaint.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge.forStatus(complaint.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatApiLabel(complaint.issueType),
                style: theme.textTheme.bodyLarge,
              ),
              if (complaint.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  complaint.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  StatusBadge.forPriority(complaint.priority),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      complaint.departmentName?.isNotEmpty == true
                          ? complaint.departmentName!
                          : 'Unassigned',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    formatDateTime(complaint.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
