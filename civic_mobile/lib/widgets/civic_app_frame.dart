import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// Keeps a phone-sized Civic composition on large Windows windows.
class CivicAppFrame extends StatelessWidget {
  const CivicAppFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= CivicTokens.phoneFrameBreakpoint) {
      return child;
    }

    final phoneWidth = CivicTokens.phoneWidth;
    final phoneHeight = math.min(CivicTokens.phoneHeight, media.size.height - 36);

    return ColoredBox(
      color: CivicTokens.canvas,
      child: Center(
        child: Container(
          width: phoneWidth,
          height: phoneHeight,
          decoration: BoxDecoration(
            color: CivicTokens.background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(phoneWidth, phoneHeight),
              padding: media.padding.copyWith(
                left: 0,
                right: 0,
                top: math.min(media.padding.top, 12),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
