import 'dart:math' as math;
import 'dart:ui';
import '../models/scene_models.dart';

class SvgPathParser {
  static final RegExp _tokenRegex = RegExp(
    r'([MmLlHhVvCcSsQqTtAaZz])|([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)',
  );

  static Path parse(String svgPath) {
    final path = Path();
    if (svgPath.trim().isEmpty) return path;

    final tokens = _tokenRegex
        .allMatches(svgPath)
        .map((m) => m.group(0)!)
        .toList(growable: false);

    int i = 0;
    String cmd = '';
    double curX = 0.0;
    double curY = 0.0;
    double startX = 0.0;
    double startY = 0.0;
    double lastCtrlX = 0.0;
    double lastCtrlY = 0.0;

    bool isCommand(String s) =>
        s.length == 1 && 'MmLlHhVvCcSsQqTtAaZz'.contains(s);

    double nextNum() {
      if (i >= tokens.length) return 0.0;
      return double.tryParse(tokens[i++]) ?? 0.0;
    }

    while (i < tokens.length) {
      if (isCommand(tokens[i])) {
        cmd = tokens[i++];
      } else if (cmd.isEmpty) {
        i++;
        continue;
      }

      switch (cmd) {
        case 'M':
          curX = nextNum();
          curY = nextNum();
          startX = curX;
          startY = curY;
          path.moveTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          cmd = 'L';
          break;
        case 'm':
          curX += nextNum();
          curY += nextNum();
          startX = curX;
          startY = curY;
          path.moveTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          cmd = 'l';
          break;
        case 'L':
          curX = nextNum();
          curY = nextNum();
          path.lineTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'l':
          curX += nextNum();
          curY += nextNum();
          path.lineTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'H':
          curX = nextNum();
          path.lineTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'h':
          curX += nextNum();
          path.lineTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'V':
          curY = nextNum();
          path.lineTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'v':
          curY += nextNum();
          path.lineTo(curX, curY);
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'Q':
          final x1 = nextNum();
          final y1 = nextNum();
          curX = nextNum();
          curY = nextNum();
          path.quadraticBezierTo(x1, y1, curX, curY);
          lastCtrlX = x1;
          lastCtrlY = y1;
          break;
        case 'q':
          final x1 = curX + nextNum();
          final y1 = curY + nextNum();
          curX += nextNum();
          curY += nextNum();
          path.quadraticBezierTo(x1, y1, curX, curY);
          lastCtrlX = x1;
          lastCtrlY = y1;
          break;
        case 'T':
          final x1 = 2 * curX - lastCtrlX;
          final y1 = 2 * curY - lastCtrlY;
          curX = nextNum();
          curY = nextNum();
          path.quadraticBezierTo(x1, y1, curX, curY);
          lastCtrlX = x1;
          lastCtrlY = y1;
          break;
        case 't':
          final x1 = 2 * curX - lastCtrlX;
          final y1 = 2 * curY - lastCtrlY;
          curX += nextNum();
          curY += nextNum();
          path.quadraticBezierTo(x1, y1, curX, curY);
          lastCtrlX = x1;
          lastCtrlY = y1;
          break;
        case 'C':
          final x1 = nextNum();
          final y1 = nextNum();
          final x2 = nextNum();
          final y2 = nextNum();
          curX = nextNum();
          curY = nextNum();
          path.cubicTo(x1, y1, x2, y2, curX, curY);
          lastCtrlX = x2;
          lastCtrlY = y2;
          break;
        case 'c':
          final x1 = curX + nextNum();
          final y1 = curY + nextNum();
          final x2 = curX + nextNum();
          final y2 = curY + nextNum();
          curX += nextNum();
          curY += nextNum();
          path.cubicTo(x1, y1, x2, y2, curX, curY);
          lastCtrlX = x2;
          lastCtrlY = y2;
          break;
        case 'S':
          final x1 = 2 * curX - lastCtrlX;
          final y1 = 2 * curY - lastCtrlY;
          final x2 = nextNum();
          final y2 = nextNum();
          curX = nextNum();
          curY = nextNum();
          path.cubicTo(x1, y1, x2, y2, curX, curY);
          lastCtrlX = x2;
          lastCtrlY = y2;
          break;
        case 's':
          final x1 = 2 * curX - lastCtrlX;
          final y1 = 2 * curY - lastCtrlY;
          final x2 = curX + nextNum();
          final y2 = curY + nextNum();
          curX += nextNum();
          curY += nextNum();
          path.cubicTo(x1, y1, x2, y2, curX, curY);
          lastCtrlX = x2;
          lastCtrlY = y2;
          break;
        case 'A':
        case 'a':
          final isRel = cmd == 'a';
          final rx = nextNum().abs();
          final ry = nextNum().abs();
          final xAxisRot = nextNum() * math.pi / 180.0;
          final largeArc = nextNum() != 0.0;
          final sweep = nextNum() != 0.0;
          final endX = isRel ? curX + nextNum() : nextNum();
          final endY = isRel ? curY + nextNum() : nextNum();
          if (rx == 0 || ry == 0) {
            path.lineTo(endX, endY);
          } else {
            path.arcToPoint(
              Offset(endX, endY),
              radius: Radius.elliptical(rx, ry),
              rotation: xAxisRot,
              largeArc: largeArc,
              clockwise: sweep,
            );
          }
          curX = endX;
          curY = endY;
          lastCtrlX = curX;
          lastCtrlY = curY;
          break;
        case 'Z':
        case 'z':
          path.close();
          curX = startX;
          curY = startY;
          lastCtrlX = curX;
          lastCtrlY = curY;
          cmd = '';
          break;
        default:
          i++;
          break;
      }
    }

    return path;
  }

  static String nodesToSvgPath(List<VectorNode> nodes, {bool closed = true}) {
    if (nodes.isEmpty) return '';
    final sb = StringBuffer();
    final first = nodes.first;
    sb.write('M ${first.x.toStringAsFixed(1)}${first.y.toStringAsFixed(1)} ');

    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final curr = nodes[i];
      if (prev.ctrl2X != null &&
          prev.ctrl2Y != null &&
          curr.ctrl1X != null &&
          curr.ctrl1Y != null) {
        sb.write(
          'C ${prev.ctrl2X!.toStringAsFixed(1)}${prev.ctrl2Y!.toStringAsFixed(1)} '
          '${curr.ctrl1X!.toStringAsFixed(1)}${curr.ctrl1Y!.toStringAsFixed(1)} '
          '${curr.x.toStringAsFixed(1)}${curr.y.toStringAsFixed(1)} ',
        );
      } else if (curr.ctrl1X != null && curr.ctrl1Y != null) {
        sb.write(
          'Q ${curr.ctrl1X!.toStringAsFixed(1)}${curr.ctrl1Y!.toStringAsFixed(1)} '
          '${curr.x.toStringAsFixed(1)}${curr.y.toStringAsFixed(1)} ',
        );
      } else {
        sb.write('L ${curr.x.toStringAsFixed(1)}${curr.y.toStringAsFixed(1)} ');
      }
    }

    if (closed && nodes.length > 2) {
      sb.write('Z');
    }
    return sb.toString().trim();
  }

  static List<VectorNode> extractNodesFromPath(String svgPath) {
    final tokens = _tokenRegex
        .allMatches(svgPath)
        .map((m) => m.group(0)!)
        .toList(growable: false);
    final result = <VectorNode>[];
    int i = 0;
    String cmd = '';
    double curX = 0;
    double curY = 0;

    bool isCommand(String s) =>
        s.length == 1 && 'MmLlHhVvCcSsQqTtAaZz'.contains(s);
    double nextNum() =>
        i < tokens.length ? (double.tryParse(tokens[i++]) ?? 0.0) : 0.0;

    while (i < tokens.length) {
      if (isCommand(tokens[i])) {
        cmd = tokens[i++];
      } else if (cmd.isEmpty) {
        i++;
        continue;
      }

      if (cmd == 'M' || cmd == 'L') {
        curX = nextNum();
        curY = nextNum();
        result.add(VectorNode(x: curX, y: curY));
        if (cmd == 'M') cmd = 'L';
      } else if (cmd == 'Q') {
        final cx = nextNum();
        final cy = nextNum();
        curX = nextNum();
        curY = nextNum();
        result.add(VectorNode(x: curX, y: curY, ctrl1X: cx, ctrl1Y: cy));
      } else if (cmd == 'C') {
        final c1x = nextNum();
        final c1y = nextNum();
        final c2x = nextNum();
        final c2y = nextNum();
        curX = nextNum();
        curY = nextNum();
        if (result.isNotEmpty) {
          result.last.ctrl2X = c1x;
          result.last.ctrl2Y = c1y;
        }
        result.add(VectorNode(x: curX, y: curY, ctrl1X: c2x, ctrl1Y: c2y));
      } else if (cmd == 'Z' || cmd == 'z') {
        cmd = '';
      } else {
        i++;
      }
    }
    return result;
  }

  static Path createDashedPath(Path source, double dashLength, double dashGap) {
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

  static Path scalePath(Path unitPath, Size size) {
    final sx = size.width / 100.0;
    final sy = size.height / 100.0;
    final m = Matrix4.identity()..scale(sx, sy);
    return unitPath.transform(m.storage);
  }
}
