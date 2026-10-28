import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import '../data/presets.dart';

class SvgParser {
  static Path parse(String svgPath, {Size targetSize = const Size(100, 100)}) {
    final path = Path();
    if (svgPath.trim().isEmpty) return path;

    final sx = targetSize.width / 100.0;
    final sy = targetSize.height / 100.0;

    final tokens = RegExp(r'[a-zA-Z]|[-+]?\d*\.?\d+')
        .allMatches(svgPath)
        .map((m) => m.group(0)!)
        .toList();

    int i = 0;
    String cmd = '';
    double cx = 0, cy = 0;
    double startX = 0, startY = 0;

    double nextNum() {
      if (i >= tokens.length) return 0.0;
      return double.tryParse(tokens[i++]) ?? 0.0;
    }

    bool hasMoreNumbers() {
      if (i >= tokens.length) return false;
      return double.tryParse(tokens[i]) != null;
    }

    while (i < tokens.length) {
      final token = tokens[i];
      if (RegExp(r'^[a-zA-Z]$').hasMatch(token)) {
        cmd = token;
        i++;
      }

      switch (cmd) {
        case 'M':
          cx = nextNum();
          cy = nextNum();
          startX = cx;
          startY = cy;
          path.moveTo(cx * sx, cy * sy);
          cmd = 'L';
          break;
        case 'm':
          cx += nextNum();
          cy += nextNum();
          startX = cx;
          startY = cy;
          path.moveTo(cx * sx, cy * sy);
          cmd = 'l';
          break;
        case 'L':
          while (hasMoreNumbers()) {
            cx = nextNum();
            cy = nextNum();
            path.lineTo(cx * sx, cy * sy);
          }
          break;
        case 'l':
          while (hasMoreNumbers()) {
            cx += nextNum();
            cy += nextNum();
            path.lineTo(cx * sx, cy * sy);
          }
          break;
        case 'H':
          while (hasMoreNumbers()) {
            cx = nextNum();
            path.lineTo(cx * sx, cy * sy);
          }
          break;
        case 'V':
          while (hasMoreNumbers()) {
            cy = nextNum();
            path.lineTo(cx * sx, cy * sy);
          }
          break;
        case 'Q':
          while (hasMoreNumbers()) {
            final x1 = nextNum();
            final y1 = nextNum();
            cx = nextNum();
            cy = nextNum();
            path.quadraticBezierTo(x1 * sx, y1 * sy, cx * sx, cy * sy);
          }
          break;
        case 'T':
          while (hasMoreNumbers()) {
            cx = nextNum();
            cy = nextNum();
            path.lineTo(cx * sx, cy * sy);
          }
          break;
        case 'C':
          while (hasMoreNumbers()) {
            final x1 = nextNum();
            final y1 = nextNum();
            final x2 = nextNum();
            final y2 = nextNum();
            cx = nextNum();
            cy = nextNum();
            path.cubicTo(
                x1 * sx, y1 * sy, x2 * sx, y2 * sy, cx * sx, cy * sy);
          }
          break;
        case 'A':
          while (hasMoreNumbers()) {
            final rx = nextNum() * sx;
            final ry = nextNum() * sy;
            final rot = nextNum() * math.pi / 180.0;
            final largeArc = nextNum() != 0;
            final sweep = nextNum() != 0;
            final ex = nextNum();
            final ey = nextNum();
            if ((ex - cx).abs() < 0.01 && (ey - cy).abs() < 0.01) {
              cx = ex;
              cy = ey;
              continue;
            }
            path.arcToPoint(
              Offset(ex * sx, ey * sy),
              radius: Radius.elliptical(
                  rx <= 0 ? 1 : rx, ry <= 0 ? 1 : ry),
              rotation: rot,
              largeArc: largeArc,
              clockwise: sweep,
            );
            cx = ex;
            cy = ey;
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          cx = startX;
          cy = startY;
          cmd = '';
          break;
        default:
          i++;
          break;
      }
    }
    return path;
  }

  static String nodesToSvgPath(List<VectorNode> nodes, bool closed) {
    if (nodes.isEmpty) return '';
    final sb = StringBuffer();
    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      if (i == 0) {
        sb.write('M ${n.x.toStringAsFixed(1)} ${n.y.toStringAsFixed(1)} ');
      } else if (n.ctrl1X != null && n.ctrl1Y != null) {
        sb.write(
            'Q ${n.ctrl1X!.toStringAsFixed(1)} ${n.ctrl1Y!.toStringAsFixed(1)} ${n.x.toStringAsFixed(1)} ${n.y.toStringAsFixed(1)} ');
      } else {
        sb.write('L ${n.x.toStringAsFixed(1)} ${n.y.toStringAsFixed(1)} ');
      }
    }
    if (closed) sb.write('Z');
    return sb.toString().trim();
  }

  static List<VectorNode> svgPathToNodes(String svgPath) {
    final nodes = <VectorNode>[];
    final matches =
        RegExp(r'([MLQ])\s*([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)').allMatches(svgPath);
    for (final m in matches) {
      final x = double.tryParse(m.group(2)!) ?? 50.0;
      final y = double.tryParse(m.group(3)!) ?? 50.0;
      nodes.add(VectorNode(x: x, y: y));
    }
    if (nodes.isEmpty) {
      return [
        VectorNode(x: 25, y: 25),
        VectorNode(x: 75, y: 25),
        VectorNode(x: 75, y: 75),
        VectorNode(x: 25, y: 75),
      ];
    }
    return nodes;
  }

  static String createPolygonPath(int sides, double radius) {
    final sb = StringBuffer();
    for (int i = 0; i < sides; i++) {
      final a = (-90.0 + (360.0 / sides) * i) * math.pi / 180.0;
      final x = 50.0 + radius * math.cos(a);
      final y = 50.0 + radius * math.sin(a);
      sb.write(
          '${i == 0 ? 'M' : 'L'} ${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} ');
    }
    sb.write('Z');
    return sb.toString();
  }

  static String createStarPath(int points, double outerR, double innerR) {
    final sb = StringBuffer();
    final total = points * 2;
    for (int i = 0; i < total; i++) {
      final r = i.isEven ? outerR : innerR;
      final a = (-90.0 + (360.0 / total) * i) * math.pi / 180.0;
      final x = 50.0 + r * math.cos(a);
      final y = 50.0 + r * math.sin(a);
      sb.write(
          '${i == 0 ? 'M' : 'L'} ${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} ');
    }
    sb.write('Z');
    return sb.toString();
  }

  static Path createDashedPath(Path source, double dashLength, double dashGap) {
    if (dashLength <= 0) return source;
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        dest.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + math.max(1.0, dashGap);
      }
    }
    return dest;
  }

  static void drawWarpedText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double fontSize,
    required String styleId,
    required Color fillColor,
    required Color outlineColor,
    required double outlineWidth,
    required Color doubleOutlineColor,
    required double doubleOutlineWidth,
    required TextWarpMode warpMode,
    required double warpIntensity,
    double letterSpacing = 1.2,
  }) {
    final preset = PresetLibrary.textStyles.firstWhere(
      (t) => t.id == styleId,
      orElse: () => PresetLibrary.textStyles.first,
    );

    if (warpMode == TextWarpMode.none || text.length <= 1) {
      _drawSingleGlyphOrString(
        canvas: canvas,
        text: text,
        pos: center,
        fontSize: fontSize,
        preset: preset,
        fillColor: fillColor,
        outlineColor: outlineColor,
        outlineWidth: outlineWidth,
        doubleOutlineColor: doubleOutlineColor,
        doubleOutlineWidth: doubleOutlineWidth,
        letterSpacing: letterSpacing,
      );
      return;
    }

    final chars = text.split('');
    final n = chars.length;
    final radius = warpIntensity <= 8 ? fontSize * 2.5 : warpIntensity;

    for (int i = 0; i < n; i++) {
      final t = n == 1 ? 0.0 : (i / (n - 1)) - 0.5;
      canvas.save();

      if (warpMode == TextWarpMode.arcUp) {
        final sweep = math.min(math.pi * 0.75, n * 0.14);
        final angle = t * sweep;
        final gx = center.dx + radius * math.sin(angle);
        final gy = center.dy + radius * (1.0 - math.cos(angle)) * 0.55;
        canvas.translate(gx, gy);
        canvas.rotate(angle * 0.65);
      } else if (warpMode == TextWarpMode.arcDown) {
        final sweep = math.min(math.pi * 0.75, n * 0.14);
        final angle = t * sweep;
        final gx = center.dx + radius * math.sin(angle);
        final gy = center.dy - radius * (1.0 - math.cos(angle)) * 0.55;
        canvas.translate(gx, gy);
        canvas.rotate(-angle * 0.65);
      } else if (warpMode == TextWarpMode.wave) {
        final gx = center.dx + t * n * fontSize * 0.68;
        final gy = center.dy + math.sin(t * math.pi * 2) * (fontSize * 0.28);
        canvas.translate(gx, gy);
      } else if (warpMode == TextWarpMode.circle) {
        final angle = -math.pi / 2 + (i / n) * math.pi * 2;
        final gx = center.dx + radius * math.cos(angle);
        final gy = center.dy + radius * math.sin(angle);
        canvas.translate(gx, gy);
        canvas.rotate(angle + math.pi / 2);
      }

      _drawSingleGlyphOrString(
        canvas: canvas,
        text: chars[i],
        pos: Offset.zero,
        fontSize: fontSize,
        preset: preset,
        fillColor: fillColor,
        outlineColor: outlineColor,
        outlineWidth: outlineWidth,
        doubleOutlineColor: doubleOutlineColor,
        doubleOutlineWidth: doubleOutlineWidth,
        letterSpacing: 0,
      );
      canvas.restore();
    }
  }

  static void _drawSingleGlyphOrString({
    required Canvas canvas,
    required String text,
    required Offset pos,
    required double fontSize,
    required TextStylePreset preset,
    required Color fillColor,
    required Color outlineColor,
    required double outlineWidth,
    required Color doubleOutlineColor,
    required double doubleOutlineWidth,
    required double letterSpacing,
  }) {
    if (doubleOutlineWidth > 0 && outlineWidth > 0) {
      final tpOuter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: preset.weight,
            fontStyle: preset.fontStyle,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth + doubleOutlineWidth * 2
              ..strokeJoin = StrokeJoin.round
              ..color = doubleOutlineColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpOuter.paint(
        canvas,
        pos - Offset(tpOuter.width / 2, tpOuter.height / 2),
      );
    }

    if (outlineWidth > 0) {
      final tpMid = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: preset.weight,
            fontStyle: preset.fontStyle,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpMid.paint(
        canvas,
        pos - Offset(tpMid.width / 2, tpMid.height / 2),
      );
    }

    final tpFill = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: preset.weight,
          fontStyle: preset.fontStyle,
          letterSpacing: letterSpacing,
          color: fillColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpFill.paint(
      canvas,
      pos - Offset(tpFill.width / 2, tpFill.height / 2),
    );
  }
}
