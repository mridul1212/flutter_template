import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_map_projection.dart';

/// Festive offline map canvas for Bangladesh Durga Puja mondops.
class MondopOfflineMapPainter extends CustomPainter {
  MondopOfflineMapPainter({
    required this.projection,
    required this.selectedId,
    required this.scheme,
  });

  final MondopMapProjection projection;
  final String? selectedId;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.cream,
          AppColors.ivory,
          scheme.primary.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, bg);

    _drawGrid(canvas, size);
    _drawRegionLabel(canvas, size);
    _drawRoutes(canvas);
    _drawMarkers(canvas);
    final user = projection.userPosition;
    if (user != null) {
      _drawUser(canvas, projection.project(user.latitude, user.longitude));
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.outlineMuted.withValues(alpha: 0.45)
      ..strokeWidth = 0.8;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  void _drawRegionLabel(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Bangladesh • Durga Puja Mondops (offline demo)',
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.35),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 32);
    tp.paint(canvas, const Offset(16, 12));
  }

  void _drawRoutes(Canvas canvas) {
    final mondops = projection.mondops;
    if (mondops.length < 2) return;
    final a = projection.project(mondops[0].mondop.lat, mondops[0].mondop.lng);
    final b = projection.project(mondops[1].mondop.lat, mondops[1].mondop.lng);
    final route = Paint()
      ..color = AppColors.brandTertiary.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(a, b, route);
  }

  void _drawMarkers(Canvas canvas) {
    for (final item in projection.mondops) {
      final m = item.mondop;
      final c = projection.project(m.lat, m.lng);
      final selected = m.id == selectedId;
      final radius = selected ? 16.0 : 13.0;

      canvas.drawCircle(
        c,
        radius + 4,
        Paint()..color = scheme.primary.withValues(alpha: selected ? 0.28 : 0.18),
      );
      canvas.drawCircle(c, radius, Paint()..color = scheme.primary);
      canvas.drawCircle(c, radius - 2, Paint()..color = scheme.onPrimary);

      final tp = TextPainter(
        text: TextSpan(
          text: '${m.index}',
          style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w900, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawUser(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 10, Paint()..color = Colors.blue.withValues(alpha: 0.25));
    canvas.drawCircle(c, 7, Paint()..color = Colors.blue);
    canvas.drawCircle(c, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant MondopOfflineMapPainter oldDelegate) {
    return oldDelegate.projection != projection ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.scheme != scheme;
  }
}
