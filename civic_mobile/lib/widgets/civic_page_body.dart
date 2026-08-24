import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// Centers content when a desktop frame is not used.
class CivicPageBody extends StatelessWidget {
  const CivicPageBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: CivicTokens.maxContentWidth),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}
