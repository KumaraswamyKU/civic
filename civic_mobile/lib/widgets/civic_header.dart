import 'package:flutter/material.dart';

class CivicHeader extends StatelessWidget {
  const CivicHeader({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = compact ? 40.0 : 72.0;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(compact ? 12 : 20),
          ),
          child: Icon(
            Icons.location_city_rounded,
            color: theme.colorScheme.onPrimary,
            size: compact ? 24 : 40,
          ),
        ),
        SizedBox(height: compact ? 8 : 16),
        Text(
          'Civic',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
