import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/complaint.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

class ComplaintTable extends StatelessWidget {
  const ComplaintTable({
    super.key,
    required this.complaints,
    required this.onOpen,
  });

  final List<Complaint> complaints;
  final ValueChanged<Complaint> onOpen;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (!wide) {
      return Column(
        children: [
          for (final complaint in complaints) ...[
            _ComplaintCard(complaint: complaint, onOpen: () => onOpen(complaint)),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: CivicTokens.surface,
        borderRadius: BorderRadius.circular(CivicTokens.radius),
        border: Border.all(color: CivicTokens.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: const WidgetStatePropertyAll(CivicTokens.surfaceAlt),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Issue')),
            DataColumn(label: Text('Department')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Citizen')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final complaint in complaints)
              DataRow(
                cells: [
                  DataCell(Text(formatComplaintId(complaint.id))),
                  DataCell(Row(
                    children: [
                      _Thumb(url: complaint.imageUrl),
                      const SizedBox(width: 8),
                      Text(formatLabel(complaint.issueType)),
                    ],
                  )),
                  DataCell(Text(complaint.departmentName?.isNotEmpty == true ? complaint.departmentName! : 'Unassigned')),
                  DataCell(PriorityBadge(priority: complaint.priority)),
                  DataCell(StatusBadge(status: complaint.status)),
                  DataCell(Text(complaint.citizenName.isEmpty ? '—' : complaint.citizenName)),
                  DataCell(Text(formatDate(complaint.createdAt))),
                  DataCell(TextButton(onPressed: () => onOpen(complaint), child: const Text('Open'))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint, required this.onOpen});

  final Complaint complaint;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CivicTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CivicTokens.radius),
        side: const BorderSide(color: CivicTokens.border),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(CivicTokens.radius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumb(url: complaint.imageUrl, large: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatLabel(complaint.issueType), style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(complaint.departmentName ?? 'Unassigned', style: const TextStyle(color: CivicTokens.muted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusBadge(status: complaint.status),
                        PriorityBadge(priority: complaint.priority),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${formatComplaintId(complaint.id)} · ${formatDate(complaint.createdAt)}', style: const TextStyle(fontSize: 12, color: CivicTokens.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, this.large = false});

  final String url;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final w = large ? 72.0 : 40.0;
    final h = large ? 88.0 : 48.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: w,
        height: h,
        child: url.isEmpty
            ? const ColoredBox(color: CivicTokens.surfaceAlt, child: Icon(Icons.image_outlined, size: 16))
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: CivicTokens.surfaceAlt, child: Icon(Icons.broken_image_outlined, size: 16)),
              ),
      ),
    );
  }
}
