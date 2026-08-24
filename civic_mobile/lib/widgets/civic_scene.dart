import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class CivicHeroBackdrop extends StatelessWidget {
  const CivicHeroBackdrop({
    super.key,
    required this.child,
    this.height,
    this.padding,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CivicTokens.hero, CivicTokens.heroEnd, Color(0xFF146B58)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _CityMapPainter())),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

class CivicEmptyArt extends StatelessWidget {
  const CivicEmptyArt({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 96.0 : 140.0;
    return SizedBox(
      width: size + 40,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: CivicTokens.mint.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: const BoxDecoration(
              color: CivicTokens.hero,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 42),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: CivicTokens.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityMapPainter extends CustomPainter {
  const _CityMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final map = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.07);

    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.18), 54, fill);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.78), 40, fill);

    final path = Path()
      ..moveTo(20, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.35, size.width * 0.55, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.82, size.width - 12, size.height * 0.48);
    canvas.drawPath(path, map);

    final skyline = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.78)
      ..lineTo(size.width * 0.08, size.height * 0.78)
      ..lineTo(size.width * 0.08, size.height * 0.62)
      ..lineTo(size.width * 0.16, size.height * 0.62)
      ..lineTo(size.width * 0.16, size.height * 0.72)
      ..lineTo(size.width * 0.24, size.height * 0.52)
      ..lineTo(size.width * 0.34, size.height * 0.52)
      ..lineTo(size.width * 0.34, size.height * 0.68)
      ..lineTo(size.width * 0.46, size.height * 0.68)
      ..lineTo(size.width * 0.46, size.height * 0.44)
      ..lineTo(size.width * 0.58, size.height * 0.44)
      ..lineTo(size.width * 0.58, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.58)
      ..lineTo(size.width * 0.82, size.height * 0.58)
      ..lineTo(size.width * 0.82, size.height * 0.74)
      ..lineTo(size.width, size.height * 0.74)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(skyline, Paint()..color = Colors.black.withValues(alpha: 0.18));

    final pin = Paint()..color = CivicTokens.mint.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.28), 5, pin);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.38), 4, pin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
