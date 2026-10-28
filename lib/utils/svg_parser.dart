import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/scene_models.dart';

class SvgParser {
  static final Map<String, Path> _cache = {};

  static Path parse(String svgPath, {Size targetSize = const Size(100, 100)}) {
    if (svgPath.trim().isEmpty) return Path();
    final key = '${svgPath}_${targetSize.width.toStringAsFixed(1)}_${targetSize.height.toStringAsFixed(1)}';
    if (_cache.containsKey(key)) {
      return Path.from(_cache[key]!);
    }

    final path = Path();
    final tokens = RegExp(r'([MmLlHhVvQqCcTtSsAaZz])|(-?\d*\.?\d+)').allMatches(svgPath);
    final list = tokens.map((m) => m.group(0)!).toList();

    int i = 0;
    String cmd = 'M';
    double cx = 0, cy = 0;
    double startX = 0, startY = 0;

    double nextNum() {
      if (i >= list.length) return 0.0;
      return double.tryParse(list[i++]) ?? 0.0;
    }

    bool isCmd(String s) => RegExp(r'^[MmLlHhVvQqCcTtSsAaZz]$').hasMatch(s);

    while (i < list.length) {
      if (isCmd(list[i])) {
        cmd = list[i++];
      }
      switch (cmd) {
        case 'M':
          cx = nextNum();
          cy = nextNum();
          startX = cx;
          startY = cy;
          path.moveTo(cx, cy);
          cmd = 'L';
          break;
        case 'm':
          cx += nextNum();
          cy += nextNum();
          startX = cx;
          startY = cy;
          path.moveTo(cx, cy);
          cmd = 'l';
          break;
        case 'L':
          cx = nextNum();
          cy = nextNum();
          path.lineTo(cx, cy);
          break;
        case 'l':
          cx += nextNum();
          cy += nextNum();
          path.lineTo(cx, cy);
          break;
        case 'H':
          cx = nextNum();
          path.lineTo(cx, cy);
          break;
        case 'h':
          cx += nextNum();
          path.lineTo(cx, cy);
          break;
        case 'V':
          cy = nextNum();
          path.lineTo(cx, cy);
          break;
        case 'v':
          cy += nextNum();
          path.lineTo(cx, cy);
          break;
        case 'Q':
          final x1 = nextNum();
          final y1 = nextNum();
          cx = nextNum();
          cy = nextNum();
          path.quadraticBezierTo(x1, y1, cx, cy);
          break;
        case 'q':
          final x1 = cx + nextNum();
          final y1 = cy + nextNum();
          cx += nextNum();
          cy += nextNum();
          path.quadraticBezierTo(x1, y1, cx, cy);
          break;
        case 'T':
          cx = nextNum();
          cy = nextNum();
          path.lineTo(cx, cy);
          break;
        case 't':
          cx += nextNum();
          cy += nextNum();
          path.lineTo(cx, cy);
          break;
        case 'C':
          final x1 = nextNum();
          final y1 = nextNum();
          final x2 = nextNum();
          final y2 = nextNum();
          cx = nextNum();
          cy = nextNum();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
          break;
        case 'c':
          final x1 = cx + nextNum();
          final y1 = cy + nextNum();
          final x2 = cx + nextNum();
          final y2 = cy + nextNum();
          cx += nextNum();
          cy += nextNum();
          path.cubicTo(x1, y1, x2, y2, cx, cy);
          break;
        case 'A':
        case 'a':
          final isRel = cmd == 'a';
          final rx = nextNum().abs();
          final ry = nextNum().abs();
          final rot = nextNum() * math.pi / 180.0;
          final largeArc = nextNum() != 0.0;
          final sweep = nextNum() != 0.0;
          final ex = isRel ? cx + nextNum() : nextNum();
          final ey = isRel ? cy + nextNum() : nextNum();
          if ((ex - cx).abs() < 0.01 && (ey - cy).abs() < 0.01) {
            path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: rx));
          } else {
            path.arcToPoint(
              Offset(ex, ey),
              radius: Radius.elliptical(rx == 0 ? 1 : rx, ry == 0 ? 1 : ry),
              rotation: rot,
              largeArc: largeArc,
              clockwise: sweep,
            );
          }
          cx = ex;
          cy = ey;
          break;
        case 'Z':
        case 'z':
          path.close();
          cx = startX;
          cy = startY;
          break;
        default:
          i++;
          break;
      }
    }

    if (targetSize.width != 100.0 || targetSize.height != 100.0) {
      final sx = targetSize.width / 100.0;
      final sy = targetSize.height / 100.0;
      final matrix = Matrix4.identity()..scale(sx, sy);
      final scaled = path.transform(matrix.storage);
      if (_cache.length < 400) _cache[key] = Path.from(scaled);
      return scaled;
    }

    if (_cache.length < 400) _cache[key] = Path.from(path);
    return path;
  }

  static Path nodesToPath(List<VectorNode> nodes, bool closed) {
    final path = Path();
    if (nodes.isEmpty) return path;
    path.moveTo(nodes.first.x, nodes.first.y);
    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final curr = nodes[i];
      if (prev.ctrl2X != null &&
          prev.ctrl2Y != null &&
          curr.ctrl1X != null &&
          curr.ctrl1Y != null) {
        path.cubicTo(
          prev.ctrl2X!,
          prev.ctrl2Y!,
          curr.ctrl1X!,
          curr.ctrl1Y!,
          curr.x,
          curr.y,
        );
      } else if (curr.ctrl1X != null && curr.ctrl1Y != null) {
        path.quadraticBezierTo(curr.ctrl1X!, curr.ctrl1Y!, curr.x, curr.y);
      } else {
        path.lineTo(curr.x, curr.y);
      }
    }
    if (closed && nodes.length > 2) {
      path.close();
    }
    return path;
  }

  static String nodesToSvgPath(List<VectorNode> nodes, bool closed) {
    if (nodes.isEmpty) return '';
    final sb = StringBuffer();
    sb.write(
        'M ${nodes.first.x.toStringAsFixed(1)} ${nodes.first.y.toStringAsFixed(1)} ');
    for (int i = 1; i < nodes.length; i++) {
      final curr = nodes[i];
      if (curr.ctrl1X != null && curr.ctrl1Y != null) {
        sb.write(
            'Q ${curr.ctrl1X!.toStringAsFixed(1)} ${curr.ctrl1Y!.toStringAsFixed(1)} ${curr.x.toStringAsFixed(1)} ${curr.y.toStringAsFixed(1)} ');
      } else {
        sb.write(
            'L ${curr.x.toStringAsFixed(1)} ${curr.y.toStringAsFixed(1)} ');
      }
    }
    if (closed && nodes.length > 2) {
      sb.write('Z');
    }
    return sb.toString().trim();
  }

  static Path dashPath(Path source, double dashLength, double dashGap) {
    if (dashLength <= 0 || dashGap <= 0) return source;
    final dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, math.min(distance + len, metric.length)),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  static List<Color> generateHarmonies(Color base, String mode) {
    final hsv = HSVColor.fromColor(base);
    switch (mode) {
      case 'complementary':
        return [
          base,
          hsv.withHue((hsv.hue + 180) % 360).toColor(),
          hsv.withSaturation((hsv.saturation * 0.6).clamp(0.1, 1.0)).toColor(),
        ];
      case 'analogous':
        return [
          hsv.withHue((hsv.hue + 330) % 360).toColor(),
          base,
          hsv.withHue((hsv.hue + 30) % 360).toColor(),
        ];
      case 'triadic':
        return [
          base,
          hsv.withHue((hsv.hue + 120) % 360).toColor(),
          hsv.withHue((hsv.hue + 240) % 360).toColor(),
        ];
      default:
        return [
          base,
          hsv.withHue((hsv.hue + 150) % 360).toColor(),
          hsv.withHue((hsv.hue + 210) % 360).toColor(),
        ];
    }
  }
}
