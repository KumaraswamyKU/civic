import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/complaint.dart';

Color priorityColor(String priority) {
  switch (priority) {
    case 'high':
      return Colors.red;
    case 'low':
      return Colors.green;
    default:
      return Colors.orange;
  }
}

IconData issueTypeIcon(String issueType) {
  switch (issueType) {
    case 'garbage':
      return Icons.delete_outline;
    case 'streetlight':
      return Icons.lightbulb_outline;
    case 'water_leakage':
      return Icons.water_damage_outlined;
    default:
      return Icons.help_outline;
  }
}

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback? onTap;

  const ComplaintCard({super.key, required this.complaint, this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = complaint.imageUrl.startsWith('http')
        ? complaint.imageUrl
        : '${ApiConfig.baseUrl}${complaint.imageUrl}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(issueTypeIcon(complaint.issueType))),
        ),
        title: Text(complaint.issueType.replaceAll('_', ' ').toUpperCase()),
        subtitle: Text(
          '${complaint.status.replaceAll('_', ' ')} • ${DateFormat.yMMMd().add_jm().format(complaint.createdAt)}',
        ),
        trailing: Chip(
          label: Text(complaint.priority.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: priorityColor(complaint.priority),
        ),
      ),
    );
  }
}
