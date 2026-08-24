import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class CivicHeader extends StatelessWidget {
  const CivicHeader({
    super.key,
    this.compact = false,
    this.subtitle,
    this.light = false,
  });

  final bool compact;
  final String? subtitle;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final onHero = light;
    final titleStyle = (compact ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.headlineMedium)
        ?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: onHero ? Colors.white : CivicTokens.navy,
        );
    return Column(
      children: [
        CivicMark(size: compact ? 48 : 72, light: light),
        SizedBox(height: compact ? 10 : 16),
        Text('Civic', style: titleStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onHero ? Colors.white.withValues(alpha: 0.82) : CivicTokens.muted,
                ),
          ),
        ],
      ],
    );
  }
}

class CivicMark extends StatelessWidget {
  const CivicMark({super.key, this.size = 40, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.16) : CivicTokens.hero,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: light ? Border.all(color: Colors.white.withValues(alpha: 0.28)) : null,
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}
