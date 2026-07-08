import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/app_colors.dart';

class SplashFestiveBackdrop extends StatelessWidget {
  const SplashFestiveBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandSecondary.withValues(alpha: 0.95),
            AppColors.brandPrimary.withValues(alpha: 0.92),
            scheme.surface.withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, 0.55, 1],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class SplashDhunuchiSmokeOverlay extends StatelessWidget {
  const SplashDhunuchiSmokeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          scheme.surface.withValues(alpha: 0.0),
          scheme.surface.withValues(alpha: 0.35),
          scheme.surface.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.srcOver,
      child: CustomPaint(
        painter: SplashSmokePainter(color: AppColors.ivory.withValues(alpha: 0.75)),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class SplashSmokePainter extends CustomPainter {
  const SplashSmokePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;

    void puff(Offset c, double r) => canvas.drawCircle(c, r, paint);

    puff(Offset(w * 0.22, h * 0.62), w * 0.18);
    puff(Offset(w * 0.35, h * 0.52), w * 0.24);
    puff(Offset(w * 0.55, h * 0.58), w * 0.22);
    puff(Offset(w * 0.72, h * 0.50), w * 0.26);
    puff(Offset(w * 0.60, h * 0.40), w * 0.20);
    puff(Offset(w * 0.40, h * 0.38), w * 0.22);
  }

  @override
  bool shouldRepaint(covariant SplashSmokePainter oldDelegate) => oldDelegate.color != color;
}

class SplashAlpanaHint extends StatelessWidget {
  const SplashAlpanaHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.18,
      child: CustomPaint(
        painter: SplashAlpanaPainter(stroke: AppColors.goldGlow),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class SplashAlpanaPainter extends CustomPainter {
  const SplashAlpanaPainter({required this.stroke});

  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = stroke.withValues(alpha: 0.9);

    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.36;
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c, r * 0.72, p);
    canvas.drawCircle(c, r * 0.46, p);

    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      final o1 = Offset(c.dx + r * 0.92 * cos(a), c.dy + r * 0.92 * sin(a));
      final o2 = Offset(c.dx + r * 0.60 * cos(a), c.dy + r * 0.60 * sin(a));
      canvas.drawLine(o2, o1, p);
    }
  }

  @override
  bool shouldRepaint(covariant SplashAlpanaPainter oldDelegate) => oldDelegate.stroke != stroke;
}

class SplashMukhomondolPainter extends CustomPainter {
  SplashMukhomondolPainter({required this.eyeColor, required this.stroke, required this.glow});

  final Color eyeColor;
  final Color stroke;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    final glowPaint = Paint()
      ..color = glow.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(c.dx, c.dy - h * 0.08), w * 0.36, glowPaint);

    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final eyeFill = Paint()..color = eyeColor.withValues(alpha: 0.95);

    final leftRect = Rect.fromCenter(center: Offset(c.dx - w * 0.20, c.dy - h * 0.10), width: w * 0.40, height: h * 0.22);
    final rightRect = Rect.fromCenter(center: Offset(c.dx + w * 0.20, c.dy - h * 0.10), width: w * 0.40, height: h * 0.22);
    canvas.drawArc(leftRect, 0.20, 2.74, false, p);
    canvas.drawArc(rightRect, 0.20, 2.74, false, p);

    canvas.drawCircle(Offset(c.dx - w * 0.20, c.dy - h * 0.10), w * 0.03, eyeFill);
    canvas.drawCircle(Offset(c.dx + w * 0.20, c.dy - h * 0.10), w * 0.03, eyeFill);

    final bindi = Paint()..color = AppColors.brandTertiary.withValues(alpha: 0.95);
    canvas.drawCircle(Offset(c.dx, c.dy + h * 0.04), w * 0.022, bindi);
  }

  @override
  bool shouldRepaint(covariant SplashMukhomondolPainter oldDelegate) =>
      oldDelegate.eyeColor != eyeColor || oldDelegate.stroke != stroke || oldDelegate.glow != glow;
}
