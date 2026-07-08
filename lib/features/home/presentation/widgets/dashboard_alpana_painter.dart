import 'package:flutter/material.dart';

class DashboardAlpanaPainter extends CustomPainter {
  DashboardAlpanaPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: 0.9);

    final c = Offset(size.width * 0.72, size.height * 0.35);
    final r = size.shortestSide * 0.42;
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c, r * 0.72, p);
    canvas.drawCircle(c, r * 0.46, p);
  }

  @override
  bool shouldRepaint(covariant DashboardAlpanaPainter oldDelegate) => oldDelegate.color != color;
}
