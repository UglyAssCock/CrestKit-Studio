import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../data/divisions.dart';
import '../data/jerseys.dart';
import '../data/patterns.dart';
import '../data/presets.dart';
import '../data/shields.dart';
import '../models/scene_models.dart';
import '../utils/svg_parser.dart';

class JerseyPainter extends CustomPainter {
  final StudioProject project;
  final KitSet kit;
  final String viewMode; // 'front', 'back', 'sleeve', 'shorts_socks', 'full', 'flat_lay', 'mannequin'
  final String? highlightedZone;
  final bool transparentBackground;

  JerseyPainter({
    required this.project,
    required this.kit,
    this.viewMode = 'front',
    this.highlightedZone,
    this.transparentBackground = false,
  });

  static String? hitTestZone(Offset localPos, Size size, KitSet kit, String viewMode) {
    final scale = math.min(size.width, size.height) / 100.0;
    final ox = (size.width - 100.0 * scale) / 2.0;
    final oy = (size.height - 100.0 * scale) / 2.0;
    final pt = Offset((localPos.dx - ox) / scale, (localPos.dy - oy) / scale);

    if (viewMode == 'shorts_socks') {
      if (pt.dy < 52) return 'shorts';
      return 'socks';
    }

    final tmpl = JerseyLibrary.templateById(kit.jersey.templateId);
    final collar = JerseyLibrary.collarById(kit.jersey.collarId);
    final cuff = JerseyLibrary.cuffById(kit.jersey.cuffId);
    final trim = JerseyLibrary.trimById(kit.jersey.trimId);

    if (collar.primaryPath.isNotEmpty &&
        SvgParser.parse(collar.primaryPath).contains(pt)) {
      return 'collar';
    }
    if (cuff.primaryPath.isNotEmpty &&
        SvgParser.parse(cuff.primaryPath).contains(pt)) {
      return 'cuffs';
    }
    if (trim.primaryPath.isNotEmpty &&
        SvgParser.parse(trim.primaryPath).contains(pt)) {
      return 'trim';
    }
    if (tmpl.sidePanelsPath.isNotEmpty &&
        SvgParser.parse(tmpl.sidePanelsPath).contains(pt)) {
      return 'side_panels';
    }
    if (tmpl.yokePath.isNotEmpty &&
        SvgParser.parse(tmpl.yokePath).contains(pt)) {
      return 'yoke';
    }
    if (SvgParser.parse(tmpl.sleevesFrontPath).contains(pt)) {
      return 'sleeves';
    }
    if (SvgParser.parse(tmpl.bodyFrontPath).contains(pt)) {
      return 'body';
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!transparentBackground) {
      _drawBackground(canvas, size);
    }

    final scale = math.min(size.width, size.height) / 100.0;
    canvas.save();
    canvas.translate(
      (size.width - 100.0 * scale) / 2.0,
      (size.height - 100.0 * scale) / 2.0,
    );
    canvas.scale(scale, scale);

    if (viewMode == 'front') {
      _drawShirt(canvas, isBack: false);
    } else if (viewMode == 'back') {
      _drawShirt(canvas, isBack: true);
    } else if (viewMode == 'sleeve') {
      _drawSleeveCloseup(canvas);
    } else if (viewMode == 'shorts_socks') {
      _drawShortsAndSocks(canvas);
    } else if (viewMode == 'full' ||
        viewMode == 'flat_lay' ||
        viewMode == 'mannequin') {
      if (viewMode == 'mannequin') {
        _drawMannequinSilhouette(canvas);
      }
      canvas.save();
      canvas.translate(2, 2);
      canvas.scale(0.56, 0.56);
      _drawShirt(canvas, isBack: false);
      canvas.restore();

      canvas.save();
      canvas.translate(44, 2);
      canvas.scale(0.54, 0.54);
      _drawShirt(canvas, isBack: true);
      canvas.restore();

      canvas.save();
      canvas.translate(20, 52);
      canvas.scale(0.60, 0.46);
      _drawShortsAndSocks(canvas);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bg = PresetLibrary.backgrounds.firstWhere(
      (b) => b.id == project.backgroundId,
      orElse: () => PresetLibrary.backgrounds.first,
    );
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        bg.colors.map((c) => Color(c)).toList(),
      );
    canvas.drawRect(rect, bgPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (bg.overlayType == 'pitch') {
      canvas.drawRect(rect.deflate(20), linePaint);
      canvas.drawLine(
        Offset(20, size.height / 2),
        Offset(size.width - 20, size.height / 2),
        linePaint,
      );
      canvas.drawCircle(size.center(Offset.zero), size.shortestSide * 0.18, linePaint);
    } else if (bg.overlayType == 'stadium' || bg.overlayType == 'spotlight') {
      final glow = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, size.height * 0.15),
          size.shortestSide * 0.7,
          [
            Colors.white.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        );
      canvas.drawRect(rect, glow);
    } else if (bg.overlayType == 'grid') {
      for (double x = 0; x < size.width; x += 28) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
      for (double y = 0; y < size.height; y += 28) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    } else if (bg.overlayType == 'geo' || bg.overlayType == 'stripes') {
      for (double i = -size.height; i < size.width; i += 40) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          linePaint,
        );
      }
    }
  }

  void _drawMannequinSilhouette(Canvas canvas) {
    final manPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(30, 5), 4.5, manPaint);
    canvas.drawCircle(const Offset(71, 5), 4.5, manPaint);
  }

  Color _zoneColor(String key, int fallback) =>
      Color(kit.jersey.zoneColors[key] ?? fallback);

  void _drawShirt(Canvas canvas, {required bool isBack}) {
    final j = kit.jersey;
    final tmpl = JerseyLibrary.templateById(j.templateId);
    final collar = JerseyLibrary.collarById(j.collarId);
    final cuff = JerseyLibrary.cuffById(j.cuffId);
    final trim = JerseyLibrary.trimById(j.trimId);

    final bodyPath = SvgParser.parse(isBack ? tmpl.bodyBackPath : tmpl.bodyFrontPath);
    final sleevesPath =
        SvgParser.parse(isBack ? tmpl.sleevesBackPath : tmpl.sleevesFrontPath);
    final sidesPath = SvgParser.parse(tmpl.sidePanelsPath);
    final yokePath = SvgParser.parse(tmpl.yokePath);

    canvas.drawPath(
      sleevesPath,
      Paint()..color = _zoneColor('sleeves', 0xFFFFFFFF),
    );
    canvas.drawPath(
      bodyPath,
      Paint()..color = _zoneColor('body', 0xFFDC2626),
    );

    _drawPatternOnBody(canvas, bodyPath, j.bodyPattern);

    if (tmpl.yokePath.isNotEmpty) {
      canvas.drawPath(
        yokePath,
        Paint()..color = _zoneColor('yoke', 0xFF991B1B),
      );
    }

    if (tmpl.sidePanelsPath.isNotEmpty) {
      canvas.drawPath(
        sidesPath,
        Paint()..color = _zoneColor('side_panels', 0xFFB91C1C),
      );
    }

    if (trim.primaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(trim.primaryPath),
        Paint()..color = _zoneColor('trim', 0xFFD4AF37),
      );
    }

    if (cuff.primaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(cuff.primaryPath),
        Paint()..color = _zoneColor('cuffs', 0xFFDC2626),
      );
    }

    if (!isBack && collar.secondaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(collar.secondaryPath),
        Paint()..color = _zoneColor('inner_collar', 0xFF7F1D1D),
      );
    }
    if (collar.primaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(collar.primaryPath),
        Paint()..color = _zoneColor('collar', 0xFF0F172A),
      );
    }

    if (j.fabricShading) {
      _drawFabricFolds(canvas, bodyPath);
    }

    final seamPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;
    canvas.drawPath(sleevesPath, seamPaint);
    canvas.drawPath(bodyPath, seamPaint);

    if (!isBack) {
      if (j.showChestCrest) {
        double cx = 60.0;
        if (j.chestCrestPosition == 'center') cx = 50.0;
        if (j.chestCrestPosition == 'right') cx = 40.0;
        _drawMiniCrest(canvas, Offset(cx, 31), 11.0);
      }
      if (j.showSleeveCrest) {
        _drawMiniCrest(canvas, const Offset(17, 32), 6.0);
      }
      if (j.sponsorText.isNotEmpty) {
        _drawJerseyText(
          canvas,
          j.sponsorText,
          const Offset(50, 48),
          5.6,
          Color(j.sponsorColor),
          null,
          0,
          null,
          0,
          TextWarpMode.none,
        );
      }
      if (j.showFrontNumber && j.playerNumber.isNotEmpty) {
        _drawJerseyText(
          canvas,
          j.playerNumber,
          const Offset(50, 64),
          13.0,
          Color(j.numberFillColor),
          Color(j.numberOutlineColor),
          j.numberOutlineWidth * 0.4,
          Color(j.numberDoubleOutlineColor),
          j.numberDoubleOutlineWidth * 0.4,
          TextWarpMode.none,
        );
      }
    } else {
      if (j.playerName.isNotEmpty) {
        _drawJerseyText(
          canvas,
          j.playerName,
          const Offset(50, 27),
          6.8,
          Color(j.numberFillColor),
          Color(j.numberOutlineColor),
          j.numberOutlineWidth * 0.3,
          null,
          0,
          j.nameWarp,
        );
      }
      if (j.playerNumber.isNotEmpty) {
        _drawJerseyText(
          canvas,
          j.playerNumber,
          const Offset(50, 54),
          28.0,
          Color(j.numberFillColor),
          Color(j.numberOutlineColor),
          j.numberOutlineWidth * 0.6,
          Color(j.numberDoubleOutlineColor),
          j.numberDoubleOutlineWidth * 0.6,
          TextWarpMode.none,
        );
      }
    }
  }

  void _drawPatternOnBody(
      Canvas canvas, Path bodyClip, PatternConfig patCfg) {
    if (patCfg.patternId == 'solid') return;
    final patAsset = PatternLibrary.byId(patCfg.patternId);

    canvas.save();
    canvas.clipPath(bodyClip);

    if (patAsset.isGradient) {
      final Rect bounds = const Rect.fromLTWH(20, 10, 60, 80);
      final Paint gradPaint = Paint();
      if (patAsset.id == 'gradient_radial') {
        gradPaint.shader = ui.Gradient.radial(
          const Offset(50, 50),
          42.0 * patCfg.scale,
          [
            Color(patCfg.primaryColor).withValues(alpha: patCfg.opacity),
            Color(patCfg.secondaryColor).withValues(alpha: patCfg.opacity),
          ],
        );
      } else {
        final isHoriz = patAsset.id == 'gradient_horizontal';
        gradPaint.shader = ui.Gradient.linear(
          isHoriz ? const Offset(24, 50) : const Offset(50, 12),
          isHoriz ? const Offset(76, 50) : const Offset(50, 88),
          [
            Color(patCfg.primaryColor).withValues(alpha: patCfg.opacity),
            Color(patCfg.secondaryColor).withValues(alpha: patCfg.opacity),
          ],
        );
      }
      canvas.drawRect(bounds, gradPaint);
      canvas.restore();
      return;
    }

    if (patAsset.svgPath.isNotEmpty) {
      canvas.translate(50 + patCfg.offsetX, 50 + patCfg.offsetY);
      canvas.rotate(patCfg.rotation * math.pi / 180.0);
      canvas.scale(patCfg.scale, patCfg.scale);
      canvas.translate(-50, -50);

      final patPath = SvgParser.parse(patAsset.svgPath);
      final patPaint = Paint()
        ..color = Color(patCfg.secondaryColor).withValues(alpha: patCfg.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(patPath, patPaint);
    }

    canvas.restore();
  }

  void _drawFabricFolds(Canvas canvas, Path bodyClip) {
    canvas.save();
    canvas.clipPath(bodyClip);
    final shadePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(26, 50),
        const Offset(74, 50),
        [
          Colors.black.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.10),
          Colors.black.withValues(alpha: 0.20),
        ],
        const [0.0, 0.25, 0.5, 0.75, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(20, 10, 60, 80), shadePaint);
    canvas.restore();
  }

  void _drawSleeveCloseup(Canvas canvas) {
    final j = kit.jersey;
    final tmpl = JerseyLibrary.templateById(j.templateId);
    final sleevePath = SvgParser.parse(tmpl.sleeveSinglePath);

    canvas.drawPath(
      sleevePath,
      Paint()..color = _zoneColor('sleeves', 0xFFFFFFFF),
    );
    _drawPatternOnBody(canvas, sleevePath, j.bodyPattern);

    final cuffBand = Path()..addRect(const Rect.fromLTWH(18, 76, 64, 8));
    canvas.drawPath(
      cuffBand,
      Paint()..color = _zoneColor('cuffs', 0xFFDC2626),
    );

    canvas.drawPath(
      sleevePath,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    _drawMiniCrest(canvas, const Offset(50, 46), 24.0);
  }

  void _drawShortsAndSocks(Canvas canvas) {
    final j = kit.jersey;
    final shortsAsset = JerseyLibrary.shortsById(j.shortsStyleId);
    final socksAsset = JerseyLibrary.socksById(j.socksStyleId);

    canvas.save();
    canvas.translate(0, -6);
    canvas.scale(0.85, 0.65);
    final shortsPath = SvgParser.parse(shortsAsset.primaryPath);
    canvas.drawPath(
      shortsPath,
      Paint()..color = _zoneColor('shorts', 0xFF0F172A),
    );
    if (shortsAsset.secondaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(shortsAsset.secondaryPath),
        Paint()..color = _zoneColor('shorts_trim', 0xFFD4AF37),
      );
    }
    canvas.drawPath(
      shortsPath,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    _drawMiniCrest(canvas, const Offset(64, 58), 9.0);
    if (j.showShortsNumber && j.playerNumber.isNotEmpty) {
      _drawJerseyText(
        canvas,
        j.playerNumber,
        const Offset(36, 58),
        9.5,
        Color(j.numberFillColor),
        Color(j.numberOutlineColor),
        0.5,
        null,
        0,
        TextWarpMode.none,
      );
    }
    canvas.restore();

    canvas.save();
    canvas.translate(8, 46);
    canvas.scale(0.85, 0.56);
    final socksPath = SvgParser.parse(socksAsset.primaryPath);
    canvas.drawPath(
      socksPath,
      Paint()..color = _zoneColor('socks', 0xFFDC2626),
    );
    if (socksAsset.secondaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(socksAsset.secondaryPath),
        Paint()..color = _zoneColor('socks_turnover', 0xFFFFFFFF),
      );
    }
    canvas.drawPath(
      socksPath,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.restore();
  }

  void _drawMiniCrest(Canvas canvas, Offset center, double size) {
    canvas.save();
    canvas.translate(center.dx - size / 2, center.dy - size / 2);
    canvas.scale(size / 100.0, size / 100.0);

    final crest = kit.crest;
    final shieldPath = SvgParser.parse(ShieldLibrary.byId(crest.shieldId).path);
    canvas.drawPath(
      shieldPath,
      Paint()..color = Color(crest.shieldPrimaryColor),
    );

    final div = DivisionLibrary.byId(crest.divisionId);
    if (div.path.isNotEmpty && div.id != 'solid') {
      canvas.save();
      canvas.clipPath(shieldPath);
      canvas.drawPath(
        SvgParser.parse(div.path),
        Paint()..color = Color(crest.divisionColor2),
      );
      canvas.restore();
    }

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = Color(crest.shieldStrokeColor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0,
    );

    for (final layer in kit.layers) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes) {
        if (shape.textContent != null) continue;
        canvas.save();
        canvas.translate(shape.tx, shape.ty);
        canvas.rotate(shape.rotation);
        canvas.scale(shape.scaleX, shape.scaleY);
        canvas.translate(-50, -50);
        canvas.drawPath(
          SvgParser.parse(shape.svgPath),
          Paint()..color = Color(shape.fillColor),
        );
        canvas.restore();
      }
    }
    canvas.restore();
  }

  void _drawJerseyText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color fill,
    Color? outline,
    double outlineWidth,
    Color? doubleOutline,
    double doubleOutlineWidth,
    TextWarpMode warp,
  ) {
    final preset = PresetLibrary.textStyles.firstWhere(
      (s) => s.id == kit.jersey.numberStyleId,
      orElse: () => PresetLibrary.textStyles.first,
    );

    if (warp == TextWarpMode.arcUp && text.length > 1) {
      final chars = text.split('');
      final n = chars.length;
      for (int i = 0; i < n; i++) {
        final t = (i / (n - 1)) * 2.0 - 1.0;
        final angle = t * 0.45;
        final r = 28.0;
        final cx = center.dx + r * math.sin(angle);
        final cy = (center.dy + r * 0.85) - r * math.cos(angle);
        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(angle);
        _paintSingleText(
          canvas,
          chars[i],
          Offset.zero,
          fontSize,
          preset,
          fill,
          outline,
          outlineWidth,
          doubleOutline,
          doubleOutlineWidth,
        );
        canvas.restore();
      }
      return;
    }

    _paintSingleText(
      canvas,
      text,
      center,
      fontSize,
      preset,
      fill,
      outline,
      outlineWidth,
      doubleOutline,
      doubleOutlineWidth,
    );
  }

  void _paintSingleText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    TextStylePreset preset,
    Color fill,
    Color? outline,
    double outlineWidth,
    Color? doubleOutline,
    double doubleOutlineWidth,
  ) {
    if (doubleOutline != null && doubleOutlineWidth > 0) {
      final tp2 = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: preset.weight,
            fontStyle: preset.fontStyle,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth + doubleOutlineWidth * 2
              ..color = doubleOutline
              ..strokeJoin = StrokeJoin.round,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, center - Offset(tp2.width / 2, tp2.height / 2));
    }

    if (outline != null && outlineWidth > 0) {
      final tp1 = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: preset.weight,
            fontStyle: preset.fontStyle,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outline
              ..strokeJoin = StrokeJoin.round,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp1.paint(canvas, center - Offset(tp1.width / 2, tp1.height / 2));
    }

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: preset.weight,
          fontStyle: preset.fontStyle,
          color: fill,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant JerseyPainter oldDelegate) => true;
}
