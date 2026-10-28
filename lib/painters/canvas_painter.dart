import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/presets.dart';

class BackgroundPainter extends CustomPainter {
  final BackgroundPreset preset;
  final bool showMannequinOutline;

  const BackgroundPainter({
    required this.preset,
    this.showMannequinOutline = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c1 = Color(preset.colors.first);
    final c2 = Color(preset.colors.last);

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c1, c2],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    switch (preset.overlayType) {
      case 'stadium':
        _drawStadiumLights(canvas, size);
        break;
      case 'pitch':
        _drawPitchLines(canvas, size);
        break;
      case 'locker':
        _drawLockerPanels(canvas, size);
        break;
      case 'spotlight':
        _drawSpotlight(canvas, size);
        break;
      case 'grid':
        _drawBlueprintGrid(canvas, size);
        break;
      case 'stripes':
        _drawDiagonalStripes(canvas, size);
        break;
      case 'geo':
        _drawBroadcastGeo(canvas, size);
        break;
      case 'city':
        _drawCityCage(canvas, size);
        break;
      default:
        break;
    }

    if (showMannequinOutline) {
      _drawVectorMannequin(canvas, size);
    }
  }

  void _drawStadiumLights(Canvas canvas, Size size) {
    final beamPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.75),
        radius: 0.9,
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, beamPaint);

    final dotPaint = Paint()..color = Colors.white.withOpacity(0.28);
    for (int i = 0; i < 14; i++) {
      final x = size.width * (0.08 + i * 0.064);
      canvas.drawCircle(Offset(x, size.height * 0.08), 3.0, dotPaint);
      canvas.drawCircle(Offset(x, size.height * 0.10), 2.2, dotPaint);
    }

    final turfRect = Rect.fromLTWH(
      0,
      size.height * 0.78,
      size.width,
      size.height * 0.22,
    );
    canvas.drawRect(
      turfRect,
      Paint()..color = const Color(0xFF065F46).withOpacity(0.35),
    );
  }

  void _drawPitchLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 2.0;

    final margin = size.width * 0.06;
    final pitchRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2,
    );
    canvas.drawRect(pitchRect, linePaint);
    canvas.drawLine(
      Offset(margin, size.height / 2),
      Offset(size.width - margin, size.height / 2),
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.16,
      linePaint,
    );
  }

  void _drawLockerPanels(Canvas canvas, Size size) {
    final panelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2.0;
    final colW = size.width / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(colW * i, 0),
        Offset(colW * i, size.height),
        panelPaint,
      );
    }
    canvas.drawLine(
      Offset(0, size.height * 0.18),
      Offset(size.width, size.height * 0.18),
      panelPaint,
    );
  }

  void _drawSpotlight(Canvas canvas, Size size) {
    final cone = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width * 0.92, size.height)
      ..lineTo(size.width * 0.08, size.height)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.16),
            Colors.white.withOpacity(0.02),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  void _drawBlueprintGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  void _drawDiagonalStripes(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 18.0;
    for (double i = -size.height; i < size.width + size.height; i += 44) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        p,
      );
    }
  }

  void _drawBroadcastGeo(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF00E5A3).withOpacity(0.14)
      ..strokeWidth = 2.0;
    for (int i = 1; i <= 4; i++) {
      final r = size.width * (0.14 * i);
      final path = Path();
      for (int k = 0; k < 6; k++) {
        final a = (k * 60) * math.pi / 180.0;
        final dx = size.width / 2 + r * math.cos(a);
        final dy = size.height / 2 + r * math.sin(a);
        if (k == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }
      path.close();
      canvas.drawPath(path, p);
    }
  }

  void _drawCityCage(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.2;
    const step = 34.0;
    for (double d = -size.height; d < size.width + size.height; d += step) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), p);
      canvas.drawLine(Offset(d, 0), Offset(d - size.height, size.height), p);
    }
  }

  void _drawVectorMannequin(Canvas canvas, Size size) {
    final mPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.24)
      ..strokeWidth = 2.0;
    // Neck & Head Silhouette
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.06), 14, mPaint);
    // Stand Base
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.88),
      Offset(size.width * 0.5, size.height * 0.96),
      mPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.96),
      Offset(size.width * 0.64, size.height * 0.96),
      mPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.preset.id != preset.id ||
      oldDelegate.showMannequinOutline != showMannequinOutline;
}
