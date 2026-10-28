import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../data/divisions.dart';
import '../data/presets.dart';
import '../data/shields.dart';
import '../models/scene_models.dart';
import '../utils/svg_parser.dart';

class CrestPainter extends CustomPainter {
  final KitSet kit;
  final String? selectedLayerId;
  final String? selectedShapeId;
  final int? selectedNodeIndex;
  final bool showGrid;
  final double gridSize;
  final bool symmetryMode;
  final bool isExport;
  final ui.Image? referenceImage;
  final double referenceOpacity;

  CrestPainter({
    required this.kit,
    this.selectedLayerId,
    this.selectedShapeId,
    this.selectedNodeIndex,
    this.showGrid = true,
    this.gridSize = 10.0,
    this.symmetryMode = false,
    this.isExport = false,
    this.referenceImage,
    this.referenceOpacity = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 100.0;
    canvas.save();
    canvas.translate(
      (size.width - 100.0 * scale) / 2.0,
      (size.height - 100.0 * scale) / 2.0,
    );
    canvas.scale(scale, scale);

    if (!isExport && showGrid) {
      _drawGrid(canvas);
    }

    if (!isExport && referenceImage != null) {
      paintImage(
        canvas: canvas,
        rect: const Rect.fromLTWH(5, 5, 90, 90),
        image: referenceImage!,
        fit: BoxFit.contain,
        opacity: referenceOpacity,
      );
    }

    _drawBaseShieldAndDivision(canvas, kit.crest);

    for (final layer in kit.layers) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes) {
        _drawVectorShape(canvas, shape, layer.opacity);
        if (symmetryMode) {
          _drawSymmetricMirror(canvas, shape, layer.opacity);
        }
      }
    }

    _drawBanners(canvas, kit.crest);

    if (!isExport && symmetryMode) {
      final symPaint = Paint()
        ..color = const Color(0xFF00E5A3).withValues(alpha: 0.7)
        ..strokeWidth = 0.4
        ..style = PaintingStyle.stroke;
      for (double y = 0; y < 100; y += 4) {
        canvas.drawLine(Offset(50, y), Offset(50, y + 2), symPaint);
      }
    }

    if (!isExport && selectedShapeId != null) {
      final sel = _findSelectedShape();
      if (sel != null) {
        _drawSelectionHandles(canvas, sel);
      }
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.2;
    final step = gridSize.clamp(2.0, 25.0);
    for (double v = 0; v <= 100; v += step) {
      canvas.drawLine(Offset(v, 0), Offset(v, 100), gridPaint);
      canvas.drawLine(Offset(0, v), Offset(100, v), gridPaint);
    }
    final guidePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.22)
      ..strokeWidth = 0.35;
    canvas.drawLine(const Offset(50, 0), const Offset(50, 100), guidePaint);
    canvas.drawLine(const Offset(0, 50), const Offset(100, 50), guidePaint);
  }

  void _drawBaseShieldAndDivision(Canvas canvas, CrestConfig crest) {
    final shieldAsset = ShieldLibrary.byId(crest.shieldId);
    final shieldPath = SvgParser.parse(shieldAsset.path);

    final basePaint = Paint()
      ..color = Color(crest.shieldPrimaryColor)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, basePaint);

    final divAsset = DivisionLibrary.byId(crest.divisionId);
    if (divAsset.path.isNotEmpty && divAsset.id != 'solid') {
      final divPath = SvgParser.parse(divAsset.path);
      canvas.save();
      canvas.clipPath(shieldPath);
      final divPaint1 = Paint()
        ..color = Color(crest.divisionColor1)
        ..style = PaintingStyle.fill;
      canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), divPaint1);

      final divPaint2 = Paint()
        ..color = Color(crest.divisionColor2)
        ..style = PaintingStyle.fill;
      canvas.drawPath(divPath, divPaint2);
      canvas.restore();
    }

    if (crest.hasBordure) {
      final bordurePaint = Paint()
        ..color = Color(crest.bordureColor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = crest.shieldStrokeWidth
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(shieldPath, bordurePaint);
    }

    for (int i = 1; i <= crest.outlineCount; i++) {
      final factor = 1.0 - (i - 1) * 0.045;
      canvas.save();
      canvas.translate(50, 50);
      canvas.scale(factor, factor);
      canvas.translate(-50, -50);
      final ringPaint = Paint()
        ..color = i.isOdd
            ? Color(crest.shieldStrokeColor)
            : Color(crest.shieldSecondaryColor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (crest.shieldStrokeWidth * 0.65).clamp(0.6, 5.0)
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(shieldPath, ringPaint);
      canvas.restore();
    }
  }

  void _drawVectorShape(
      Canvas canvas, VectorShape shape, double layerOpacity) {
    final totalOpacity = (shape.opacity * layerOpacity).clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(shape.tx, shape.ty);
    canvas.rotate(shape.rotation);
    canvas.scale(
      shape.flipH ? -shape.scaleX : shape.scaleX,
      shape.flipV ? -shape.scaleY : shape.scaleY,
    );
    canvas.translate(-50, -50);

    if (shape.textContent != null && shape.textContent!.isNotEmpty) {
      _drawShapeText(canvas, shape, totalOpacity);
      canvas.restore();
      return;
    }

    final rawPath = shape.nodes.isNotEmpty
        ? SvgParser.nodesToPath(shape.nodes, shape.closed)
        : SvgParser.parse(shape.svgPath);

    if (shape.closed) {
      final fillPaint = Paint()..style = PaintingStyle.fill;
      if (shape.fillType == FillType.solid || shape.gradientStops.length < 2) {
        fillPaint.color =
            Color(shape.fillColor).withValues(alpha: totalOpacity);
      } else if (shape.fillType == FillType.linearGradient) {
        final rad = shape.gradientAngle * math.pi / 180.0;
        final p1 = Offset(50 - 45 * math.cos(rad), 50 - 45 * math.sin(rad));
        final p2 = Offset(50 + 45 * math.cos(rad), 50 + 45 * math.sin(rad));
        fillPaint.shader = ui.Gradient.linear(
          p1,
          p2,
          shape.gradientStops
              .map((s) => s.color.withValues(alpha: totalOpacity))
              .toList(),
          shape.gradientStops.map((s) => s.offset).toList(),
        );
      } else {
        fillPaint.shader = ui.Gradient.radial(
          const Offset(50, 50),
          48.0,
          shape.gradientStops
              .map((s) => s.color.withValues(alpha: totalOpacity))
              .toList(),
          shape.gradientStops.map((s) => s.offset).toList(),
        );
      }
      canvas.drawPath(rawPath, fillPaint);
    }

    if (shape.strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = Color(shape.strokeColor).withValues(alpha: totalOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = shape.strokeWidth
        ..strokeCap = StrokeCap.values[shape.strokeCapIndex.clamp(0, 2)]
        ..strokeJoin = StrokeJoin.values[shape.strokeJoinIndex.clamp(0, 2)];

      final pathToStroke = (shape.dashLength > 0 && shape.dashGap > 0)
          ? SvgParser.dashPath(rawPath, shape.dashLength, shape.dashGap)
          : rawPath;
      canvas.drawPath(pathToStroke, strokePaint);
    }

    canvas.restore();
  }

  void _drawSymmetricMirror(
      Canvas canvas, VectorShape shape, double layerOpacity) {
    final mirrored = shape.copy();
    mirrored.tx = 100.0 - shape.tx;
    mirrored.rotation = -shape.rotation;
    mirrored.flipH = !shape.flipH;
    _drawVectorShape(canvas, mirrored, layerOpacity);
  }

  void _drawShapeText(
      Canvas canvas, VectorShape shape, double totalOpacity) {
    final text = shape.textContent!;
    final stylePreset = PresetLibrary.textStyles.firstWhere(
      (s) => s.id == shape.textStyleId,
      orElse: () => PresetLibrary.textStyles.first,
    );

    if (shape.textWarp == TextWarpMode.none) {
      _paintTextRun(
        canvas,
        text,
        const Offset(50, 50),
        shape.fontSize,
        stylePreset.weight,
        stylePreset.fontStyle,
        shape.letterSpacing,
        Color(shape.fillColor).withValues(alpha: totalOpacity),
        shape.outlineWidth > 0
            ? Color(shape.outlineColor).withValues(alpha: totalOpacity)
            : null,
        shape.outlineWidth,
        shape.doubleOutlineWidth > 0
            ? Color(shape.doubleOutlineColor).withValues(alpha: totalOpacity)
            : null,
        shape.doubleOutlineWidth,
      );
      return;
    }

    final chars = text.split('');
    final n = chars.length;
    if (n == 0) return;

    for (int i = 0; i < n; i++) {
      final t = n == 1 ? 0.0 : (i / (n - 1)) * 2.0 - 1.0;
      canvas.save();
      if (shape.textWarp == TextWarpMode.arcUp) {
        final r = shape.warpIntensity.clamp(12.0, 60.0);
        final angle = t * 0.95;
        final cx = 50.0 + r * math.sin(angle);
        final cy = (50.0 + r * 0.6) - r * math.cos(angle);
        canvas.translate(cx, cy);
        canvas.rotate(angle);
      } else if (shape.textWarp == TextWarpMode.arcDown) {
        final r = shape.warpIntensity.clamp(12.0, 60.0);
        final angle = -t * 0.95;
        final cx = 50.0 - r * math.sin(angle);
        final cy = (50.0 - r * 0.6) + r * math.cos(angle);
        canvas.translate(cx, cy);
        canvas.rotate(angle);
      } else if (shape.textWarp == TextWarpMode.wave) {
        final cx = 50.0 + t * 34.0;
        final cy = 50.0 + math.sin(t * math.pi) * (shape.warpIntensity * 0.25);
        canvas.translate(cx, cy);
      } else if (shape.textWarp == TextWarpMode.circle) {
        final r = shape.warpIntensity.clamp(14.0, 44.0);
        final angle = -math.pi / 2 + (i / n) * 2 * math.pi;
        final cx = 50.0 + r * math.cos(angle);
        final cy = 50.0 + r * math.sin(angle);
        canvas.translate(cx, cy);
        canvas.rotate(angle + math.pi / 2);
      }

      _paintTextRun(
        canvas,
        chars[i],
        Offset.zero,
        shape.fontSize,
        stylePreset.weight,
        stylePreset.fontStyle,
        0.0,
        Color(shape.fillColor).withValues(alpha: totalOpacity),
        shape.outlineWidth > 0
            ? Color(shape.outlineColor).withValues(alpha: totalOpacity)
            : null,
        shape.outlineWidth,
        shape.doubleOutlineWidth > 0
            ? Color(shape.doubleOutlineColor).withValues(alpha: totalOpacity)
            : null,
        shape.doubleOutlineWidth,
      );
      canvas.restore();
    }
  }

  void _paintTextRun(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    FontWeight weight,
    FontStyle fontStyle,
    double letterSpacing,
    Color fillColor,
    Color? outlineColor,
    double outlineWidth,
    Color? doubleOutlineColor,
    double doubleOutlineWidth,
  ) {
    if (doubleOutlineColor != null && doubleOutlineWidth > 0) {
      final tpOuter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: weight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth + doubleOutlineWidth * 2
              ..color = doubleOutlineColor
              ..strokeJoin = StrokeJoin.round,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpOuter.paint(
        canvas,
        center - Offset(tpOuter.width / 2, tpOuter.height / 2),
      );
    }

    if (outlineColor != null && outlineWidth > 0) {
      final tpMid = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: weight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor
              ..strokeJoin = StrokeJoin.round,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpMid.paint(
        canvas,
        center - Offset(tpMid.width / 2, tpMid.height / 2),
      );
    }

    final tpFill = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          color: fillColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpFill.paint(
      canvas,
      center - Offset(tpFill.width / 2, tpFill.height / 2),
    );
  }

  void _drawBanners(Canvas canvas, CrestConfig crest) {
    final bannerFill = Paint()
      ..color = Color(crest.bannerColor)
      ..style = PaintingStyle.fill;
    final bannerStroke = Paint()
      ..color = Color(crest.shieldPrimaryColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    if (crest.topBannerText.trim().isNotEmpty) {
      final topPath = crest.arcBannerText
          ? SvgParser.parse('M 14 14 Q 50 3 86 14 L 82 23 Q 50 12 18 23 Z')
          : SvgParser.parse('M 14 6 L 86 6 L 82 16 L 18 16 Z');
      canvas.drawPath(topPath, bannerFill);
      canvas.drawPath(topPath, bannerStroke);
      _paintTextRun(
        canvas,
        crest.topBannerText,
        Offset(50, crest.arcBannerText ? 13.0 : 11.0),
        5.5,
        FontWeight.w900,
        FontStyle.normal,
        0.8,
        Color(crest.bannerTextColor),
        null,
        0,
        null,
        0,
      );
    }

    if (crest.bottomBannerText.trim().isNotEmpty) {
      final botPath = crest.arcBannerText
          ? SvgParser.parse('M 18 82 Q 50 92 82 82 L 86 91 Q 50 101 14 91 Z')
          : SvgParser.parse('M 18 85 L 82 85 L 86 94 L 14 94 Z');
      canvas.drawPath(botPath, bannerFill);
      canvas.drawPath(botPath, bannerStroke);
      _paintTextRun(
        canvas,
        crest.bottomBannerText,
        Offset(50, crest.arcBannerText ? 89.5 : 89.5),
        4.8,
        FontWeight.w900,
        FontStyle.normal,
        1.0,
        Color(crest.bannerTextColor),
        null,
        0,
        null,
        0,
      );
    }
  }

  VectorShape? _findSelectedShape() {
    for (final l in kit.layers) {
      for (final s in l.shapes) {
        if (s.id == selectedShapeId) return s;
      }
    }
    return null;
  }

  void _drawSelectionHandles(Canvas canvas, VectorShape shape) {
    canvas.save();
    canvas.translate(shape.tx, shape.ty);
    canvas.rotate(shape.rotation);
    final w = 45.0 * shape.scaleX.abs();
    final h = 45.0 * shape.scaleY.abs();
    final rect = Rect.fromCenter(center: Offset.zero, width: w * 2, height: h * 2);

    final boxPaint = Paint()
      ..color = const Color(0xFF00E5A3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRect(rect, boxPaint);

    final handleFill = Paint()..color = const Color(0xFF00E5A3);
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      canvas.drawCircle(corner, 1.8, handleFill);
    }

    canvas.drawLine(
        Offset(0, -h), Offset(0, -h - 6), boxPaint);
    canvas.drawCircle(Offset(0, -h - 6), 2.0, Paint()..color = Colors.amber);

    if (shape.nodes.isNotEmpty) {
      canvas.scale(
        shape.flipH ? -shape.scaleX : shape.scaleX,
        shape.flipV ? -shape.scaleY : shape.scaleY,
      );
      canvas.translate(-50, -50);
      for (int i = 0; i < shape.nodes.length; i++) {
        final n = shape.nodes[i];
        final isSel = selectedNodeIndex == i;
        if (n.ctrl1X != null && n.ctrl1Y != null) {
          canvas.drawLine(
            Offset(n.x, n.y),
            Offset(n.ctrl1X!, n.ctrl1Y!),
            Paint()
              ..color = Colors.cyanAccent
              ..strokeWidth = 0.6,
          );
          canvas.drawCircle(
            Offset(n.ctrl1X!, n.ctrl1Y!),
            2.0,
            Paint()..color = Colors.cyanAccent,
          );
        }
        canvas.drawCircle(
          Offset(n.x, n.y),
          isSel ? 3.2 : 2.2,
          Paint()..color = isSel ? Colors.amber : Colors.white,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CrestPainter oldDelegate) => true;
}
