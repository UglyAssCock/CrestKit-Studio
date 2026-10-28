import 'package:flutter/material.dart';
import '../data/presets.dart';

class BackgroundPainter extends CustomPainter {
  final String backgroundId;

  const BackgroundPainter({required this.backgroundId});

  @override
  void paint(Canvas canvas, Size size) {
    final preset = PresetLibrary.backgrounds.firstWhere(
      (b) => b.id == backgroundId,
      orElse: () => PresetLibrary.backgrounds.first,
    );

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

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (preset.overlayType) {
      case 'stadium':
        final glowPaint = Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -0.7),
            radius: 0.9,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ).createShader(rect);
        canvas.drawRect(rect, glowPaint);
        canvas.drawRect(
          Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
          Paint()..color = const Color(0xFF065F46).withValues(alpha: 0.25),
        );
        break;
      case 'pitch':
        final pad = size.shortestSide * 0.08;
        final pitchRect = Rect.fromLTWH(
            pad, pad, size.width - pad * 2, size.height - pad * 2);
        canvas.drawRect(pitchRect, linePaint);
        canvas.drawLine(
          Offset(pad, size.height / 2),
          Offset(size.width - pad, size.height / 2),
          linePaint,
        );
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide * 0.16,
          linePaint,
        );
        break;
      case 'locker':
        final cols = 6;
        final w = size.width / cols;
        for (int i = 1; i < cols; i++) {
          canvas.drawLine(
              Offset(i * w, 0), Offset(i * w, size.height), linePaint);
        }
        break;
      case 'spotlight':
        final spot = Path()
          ..moveTo(size.width * 0.5, 0)
          ..lineTo(size.width * 0.1, size.height)
          ..lineTo(size.width * 0.9, size.height)
          ..close();
        canvas.drawPath(
          spot,
          Paint()..color = Colors.white.withValues(alpha: 0.06),
        );
        break;
      case 'grid':
        const step = 32.0;
        for (double x = 0; x < size.width; x += step) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        for (double y = 0; y < size.height; y += step) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        break;
      case 'stripes':
        for (double i = -size.height; i < size.width; i += 48) {
          canvas.drawLine(
            Offset(i, 0),
            Offset(i + size.height, size.height),
            linePaint..strokeWidth = 10,
          );
        }
        break;
      case 'geo':
      case 'city':
        canvas.drawCircle(
          Offset(size.width * 0.8, size.height * 0.2),
          size.shortestSide * 0.25,
          linePaint,
        );
        canvas.drawCircle(
          Offset(size.width * 0.2, size.height * 0.8),
          size.shortestSide * 0.3,
          linePaint,
        );
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.backgroundId != backgroundId;
}
