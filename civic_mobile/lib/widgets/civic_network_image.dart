import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class CivicNetworkImage extends StatelessWidget {
  const CivicNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.background,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(CivicTokens.radiusMd);
    final theme = Theme.of(context);
    final bg = background ?? CivicTokens.surfaceAlt;

    Widget placeholder({required IconData icon, required String label}) {
      return ColoredBox(
        color: bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: CivicTokens.muted),
              const SizedBox(height: 6),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: bg,
        child: SizedBox(
          height: height,
          width: width,
          child: url.isEmpty
              ? placeholder(icon: Icons.image_outlined, label: 'No photo')
              : Image.network(
                  url,
                  fit: fit,
                  width: width ?? double.infinity,
                  height: height,
                  semanticLabel: 'Complaint photo',
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stack) {
                    return placeholder(icon: Icons.broken_image_outlined, label: 'Photo unavailable');
                  },
                ),
        ),
      ),
    );
  }
}
