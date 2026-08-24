import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/complaints_provider.dart';
import '../widgets/civic_scene.dart';
import '../widgets/complaint_card.dart';
import '../widgets/feedback_views.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({
    super.key,
    required this.complaints,
    required this.onReport,
    required this.onSeeAllReports,
  });

  final ComplaintsProvider complaints;
  final VoidCallback onReport;
  final VoidCallback onSeeAllReports;

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    return Scaffold(
      body: ListenableBuilder(
        listenable: complaints,
        builder: (context, _) {
          return RefreshIndicator(
            color: CivicTokens.mint,
            backgroundColor: CivicTokens.hero,
            onRefresh: complaints.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _Hero(user: user, onReport: onReport)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  sliver: SliverList.list(
                    children: [
                      const SizedBox(height: 8),
                      Text('Your civic impact', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ImpactTile(
                              value: '${complaints.count}',
                              label: 'Reports',
                              color: CivicTokens.infoContainer,
                              accent: CivicTokens.info,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ImpactTile(
                              value: '${complaints.activeCount}',
                              label: 'Active',
                              color: CivicTokens.amberContainer,
                              accent: CivicTokens.amber,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ImpactTile(
                              value: '${complaints.resolvedCount}',
                              label: 'Resolved',
                              color: CivicTokens.successContainer,
                              accent: CivicTokens.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SectionHeader(
                        title: 'Recent reports',
                        actionLabel: 'See all',
                        onAction: onSeeAllReports,
                      ),
                      _HomeReports(
                        complaints: complaints,
                        onReport: onReport,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.user, required this.onReport});

  final User? user;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final name = user?.firstName ?? 'there';
    return CivicHeroBackdrop(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Make your city\nbetter, one report\nat a time.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 18),
          _ReportCta(onReport: onReport),
        ],
      ),
    );
  }
}

class _ReportCta extends StatelessWidget {
  const _ReportCta({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CivicTokens.surface,
      borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
      child: InkWell(
        onTap: onReport,
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CivicTokens.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.photo_camera_outlined, color: CivicTokens.hero),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report a civic issue', style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text(
                      'See something that needs attention? Tell your city.',
                      style: TextStyle(color: CivicTokens.muted, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: CivicTokens.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({
    required this.value,
    required this.label,
    required this.color,
    required this.accent,
  });

  final String value;
  final String label;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(CivicTokens.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _HomeReports extends StatelessWidget {
  const _HomeReports({
    required this.complaints,
    required this.onReport,
  });

  final ComplaintsProvider complaints;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    if (complaints.loading && complaints.items.isEmpty) {
      return const SkeletonCards();
    }
    if (complaints.error != null && complaints.items.isEmpty) {
      return ErrorState(
        message: 'Something went wrong while contacting Civic.',
        onRetry: complaints.refresh,
      );
    }
    if (complaints.items.isEmpty) {
      return EmptyState(
        title: 'No reports yet',
        message: "You haven't reported a civic issue. When you spot something that needs attention, you can report it here.",
        actionLabel: 'Report an issue',
        onAction: onReport,
      );
    }

    final recent = complaints.items.take(4).toList();
    return Column(
      children: [
        for (final complaint in recent) ...[
          ComplaintCard(complaint: complaint),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
