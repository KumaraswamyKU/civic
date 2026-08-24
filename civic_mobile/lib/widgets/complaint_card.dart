import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../utils/issue_visual.dart';
import 'civic_network_image.dart';
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
    final department = complaint.departmentName?.isNotEmpty == true
        ? complaint.departmentName!
        : 'Unassigned';
    final place = locationSnippet(complaint.addressText);

    return Material(
      color: CivicTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
        side: const BorderSide(color: CivicTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () => Navigator.pushNamed(
                  context,
                  AppRoutes.complaintDetail,
                  arguments: complaint.id,
                ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CivicNetworkImage(
                url: complaint.imageUrl,
                width: CivicTokens.thumbnailWidth,
                height: CivicTokens.thumbnailHeight,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(CivicTokens.radiusSm),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(issueTypeIcon(complaint.issueType), size: 18, color: CivicTokens.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            formatDisplayLabel(complaint.issueType),
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusBadge.forStatus(complaint.status),
                        StatusBadge.forPriority(complaint.priority),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      [
                        formatComplaintId(complaint.id),
                        formatDateShort(complaint.createdAt),
                        if (place.isNotEmpty) place,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.chevron_right_rounded, color: CivicTokens.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
