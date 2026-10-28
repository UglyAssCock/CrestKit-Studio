import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import '../data/shields.dart';
import '../data/divisions.dart';
import '../utils/svg_parser.dart';

class CrestPainter extends CustomPainter {
  final CrestConfig crest;
  final List<VectorLayer> layers;

  const CrestPainter({
    required this.crest,
    required this.layers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final ox = (size.width - side) / 2.0;
    final oy = (size.height - side) / 2.0;

    canvas.save();
    canvas.translate(ox, oy);
    final s = Size(side, side);

    final shieldAsset = ShieldLibrary.byId(crest.shieldId);
    final divAsset = DivisionLibrary.byId(crest.divisionId);
    final shieldPath = SvgParser.parse(shieldAsset.path, targetSize: s);

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = Color(crest.divisionColor1)
        ..style = PaintingStyle.fill,
    );

    if (divAsset.id != 'solid' && divAsset.path.isNotEmpty) {
      canvas.save();
      canvas.clipPath(shieldPath);
      final divPath = SvgParser.parse(divAsset.path, targetSize: s);
      canvas.drawPath(
        divPath,
        Paint()
          ..color = Color(crest.divisionColor2)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }

    if (crest.hasBordure) {
      canvas.save();
      canvas.clipPath(shieldPath);
      canvas.drawPath(
        shieldPath,
        Paint()
          ..color = Color(crest.bordureColor)
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.055,
      );
      canvas.restore();
    }

    paintVectorLayersOnly(canvas, s, layers);

    for (int i = 0; i < crest.outlineCount; i++) {
      final scale = 1.0 - (i * 0.035);
      canvas.save();
      canvas.translate(side / 2, side / 2);
      canvas.scale(scale, scale);
      canvas.translate(-side / 2, -side / 2);
      canvas.drawPath(
        shieldPath,
        Paint()
          ..color = Color(crest.shieldStrokeColor)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (crest.shieldStrokeWidth / 100.0) * side
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }

    if (crest.topBannerText.trim().isNotEmpty) {
      final topBannerPath = SvgParser.parse(
        'M 12 14 Q 50 4 88 14 L 84 23 Q 50 13 16 23 Z',
        targetSize: s,
      );
      canvas.drawPath(
        topBannerPath,
        Paint()..color = Color(crest.bannerColor),
      );
      canvas.drawPath(
        topBannerPath,
        Paint()
          ..color = Color(crest.shieldStrokeColor)
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.012,
      );
      SvgParser.drawWarpedText(
        canvas: canvas,
        text: crest.topBannerText,
        center: Offset(side * 0.5, side * 0.145),
        fontSize: side * 0.055,
        styleId: 'block',
        fillColor: Color(crest.bannerTextColor),
        outlineColor: Colors.transparent,
        outlineWidth: 0,
        doubleOutlineColor: Colors.transparent,
        doubleOutlineWidth: 0,
        warpMode:
            crest.arcBannerText ? TextWarpMode.arcUp : TextWarpMode.none,
        warpIntensity: side * 0.09,
      );
    }

    if (crest.bottomBannerText.trim().isNotEmpty) {
      final botBannerPath = SvgParser.parse(
        'M 16 82 Q 50 92 84 82 L 88 91 Q 50 100 12 91 Z',
        targetSize: s,
      );
      canvas.drawPath(
        botBannerPath,
        Paint()..color = Color(crest.bannerColor),
      );
      canvas.drawPath(
        botBannerPath,
        Paint()
          ..color = Color(crest.shieldStrokeColor)
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.012,
      );
      SvgParser.drawWarpedText(
        canvas: canvas,
        text: crest.bottomBannerText,
        center: Offset(side * 0.5, side * 0.89),
        fontSize: side * 0.05,
        styleId: 'block',
        fillColor: Color(crest.bannerTextColor),
        outlineColor: Colors.transparent,
        outlineWidth: 0,
        doubleOutlineColor: Colors.transparent,
        doubleOutlineWidth: 0,
        warpMode:
            crest.arcBannerText ? TextWarpMode.arcDown : TextWarpMode.none,
        warpIntensity: side * 0.08,
      );
    }

    canvas.restore();
  }

  static void paintVectorLayersOnly(
    Canvas canvas,
    Size s,
    List<VectorLayer> layers,
  ) {
    final side = s.shortestSide;
    for (final layer in layers) {
      if (!layer.visible || layer.opacity <= 0) continue;
      for (final shape in layer.shapes) {
        if (shape.opacity <= 0) continue;
        final combinedOpacity = (layer.opacity * shape.opacity).clamp(0.0, 1.0);

        canvas.save();
        final cx = (shape.tx / 100.0) * side;
        final cy = (shape.ty / 100.0) * side;
        canvas.translate(cx, cy);
        canvas.rotate(shape.rotation * math.pi / 180.0);
        canvas.scale(
          shape.scaleX * (shape.flipH ? -1.0 : 1.0),
          shape.scaleY * (shape.flipV ? -1.0 : 1.0),
        );
        canvas.translate(-side / 2.0, -side / 2.0);

        if (shape.textContent != null && shape.textContent!.trim().isNotEmpty) {
          SvgParser.drawWarpedText(
            canvas: canvas,
            text: shape.textContent!,
            center: Offset(side / 2, side / 2),
            fontSize: (shape.fontSize / 100.0) * side,
            styleId: shape.textStyleId,
            fillColor: Color(shape.fillColor).withValues(alpha: combinedOpacity),
            outlineColor:
                Color(shape.outlineColor).withValues(alpha: combinedOpacity),
            outlineWidth: (shape.outlineWidth / 100.0) * side,
            doubleOutlineColor: Color(shape.doubleOutlineColor)
                .withValues(alpha: combinedOpacity),
            doubleOutlineWidth: (shape.doubleOutlineWidth / 100.0) * side,
            warpMode: shape.textWarp,
            warpIntensity: (shape.warpIntensity / 100.0) * side,
            letterSpacing: shape.letterSpacing,
          );
          canvas.restore();
          continue;
        }

        final path = SvgParser.parse(shape.svgPath, targetSize: s);
        final rect = Offset.zero & s;

        if (shape.closed) {
          final fillPaint = Paint()..style = PaintingStyle.fill;
          if (shape.fillType == FillType.solid) {
            fillPaint.color =
                Color(shape.fillColor).withValues(alpha: combinedOpacity);
          } else if (shape.fillType == FillType.linearGradient &&
              shape.gradientStops.length >= 2) {
            final rad = shape.gradientAngle * math.pi / 180.0;
            fillPaint.shader = LinearGradient(
              begin: Alignment(-math.cos(rad), -math.sin(rad)),
              end: Alignment(math.cos(rad), math.sin(rad)),
              colors: shape.gradientStops
                  .map((g) => g.color.withValues(alpha: combinedOpacity))
                  .toList(),
              stops: shape.gradientStops.map((g) => g.offset).toList(),
            ).createShader(rect);
          } else if (shape.fillType == FillType.radialGradient &&
              shape.gradientStops.length >= 2) {
            fillPaint.shader = RadialGradient(
              colors: shape.gradientStops
                  .map((g) => g.color.withValues(alpha: combinedOpacity))
                  .toList(),
              stops: shape.gradientStops.map((g) => g.offset).toList(),
            ).createShader(rect);
          }
          canvas.drawPath(path, fillPaint);
        }

        if (shape.strokeWidth > 0) {
          final strokePaint = Paint()
            ..color =
                Color(shape.strokeColor).withValues(alpha: combinedOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = (shape.strokeWidth / 100.0) * side
            ..strokeCap = StrokeCap
                .values[shape.strokeCapIndex.clamp(0, StrokeCap.values.length - 1)]
            ..strokeJoin = StrokeJoin.values[
                shape.strokeJoinIndex.clamp(0, StrokeJoin.values.length - 1)];

          final drawPath = shape.dashLength > 0
              ? SvgParser.createDashedPath(
                  path,
                  (shape.dashLength / 100.0) * side,
                  (shape.dashGap / 100.0) * side,
                )
              : path;
          canvas.drawPath(drawPath, strokePaint);
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CrestPainter oldDelegate) => true;
}
