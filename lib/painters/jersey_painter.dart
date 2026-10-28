import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import '../data/jerseys.dart';
import '../data/patterns.dart';
import '../utils/svg_parser.dart';
import 'crest_painter.dart';

enum JerseyViewMode { front, back, sleeve, shortsAndSocks, fullKit }

class JerseyPainter extends CustomPainter {
  final JerseyConfig jersey;
  final CrestConfig crest;
  final List<VectorLayer> layers;
  final JerseyViewMode viewMode;
  final String? highlightedZone;

  const JerseyPainter({
    required this.jersey,
    required this.crest,
    required this.layers,
    this.viewMode = JerseyViewMode.front,
    this.highlightedZone,
  });

  static String? hitTestZone(Offset norm, JerseyViewMode mode) {
    if (mode == JerseyViewMode.shortsAndSocks) {
      return norm.dy < 56 ? 'shorts' : 'socks';
    }
    if (norm.dy < 22 && norm.dx > 36 && norm.dx < 64) {
      return 'collar';
    }
    if (norm.dx < 26 || norm.dx > 74) {
      return 'sleeves';
    }
    if (norm.dx < 32 || norm.dx > 68) {
      return 'side_panels';
    }
    if (norm.dy < 26) {
      return 'yoke';
    }
    return 'body';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final ox = (size.width - side) / 2.0;
    final oy = (size.height - side) / 2.0;

    canvas.save();
    canvas.translate(ox, oy);

    switch (viewMode) {
      case JerseyViewMode.front:
        _paintShirt(canvas, Size(side, side), isBack: false);
        break;
      case JerseyViewMode.back:
        _paintShirt(canvas, Size(side, side), isBack: true);
        break;
      case JerseyViewMode.sleeve:
        _paintSleeveDetail(canvas, Size(side, side));
        break;
      case JerseyViewMode.shortsAndSocks:
        _paintShortsAndSocks(canvas, Size(side, side));
        break;
      case JerseyViewMode.fullKit:
        canvas.save();
        canvas.translate(0, side * 0.04);
        canvas.scale(0.48, 0.48);
        _paintShirt(canvas, Size(side, side), isBack: false);
        canvas.restore();

        canvas.save();
        canvas.translate(side * 0.52, side * 0.04);
        canvas.scale(0.48, 0.48);
        _paintShirt(canvas, Size(side, side), isBack: true);
        canvas.restore();

        canvas.save();
        canvas.translate(side * 0.25, side * 0.50);
        canvas.scale(0.50, 0.50);
        _paintShortsAndSocks(canvas, Size(side, side));
        canvas.restore();
        break;
    }

    canvas.restore();
  }

  void _paintShirt(Canvas canvas, Size s, {required bool isBack}) {
    final tpl = JerseyLibrary.templateById(jersey.templateId);
    final collar = JerseyLibrary.collarById(jersey.collarId);
    final cuff = JerseyLibrary.cuffById(jersey.cuffId);
    final trim = JerseyLibrary.trimById(jersey.trimId);

    final bodyPath = SvgParser.parse(
      isBack ? tpl.bodyBackPath : tpl.bodyFrontPath,
      targetSize: s,
    );
    final sleevesPath = SvgParser.parse(
      isBack ? tpl.sleevesBackPath : tpl.sleevesFrontPath,
      targetSize: s,
    );
    final sidePath = SvgParser.parse(tpl.sidePanelsPath, targetSize: s);
    final yokePath = SvgParser.parse(tpl.yokePath, targetSize: s);

    final bodyColor = Color(jersey.zoneColors['body'] ?? 0xFFDC2626);
    final sleevesColor = Color(jersey.zoneColors['sleeves'] ?? 0xFFFFFFFF);
    final sideColor = Color(jersey.zoneColors['side_panels'] ?? 0xFFB91C1C);
    final yokeColor = Color(jersey.zoneColors['yoke'] ?? 0xFF991B1B);
    final collarColor = Color(jersey.zoneColors['collar'] ?? 0xFF0F172A);
    final innerCollarColor =
        Color(jersey.zoneColors['inner_collar'] ?? 0xFF7F1D1D);
    final cuffColor = Color(jersey.zoneColors['cuffs'] ?? 0xFFDC2626);
    final trimColor = Color(jersey.zoneColors['trim'] ?? 0xFFD4AF37);

    canvas.drawPath(bodyPath, Paint()..color = bodyColor);

    _paintBodyPattern(canvas, s, bodyPath);

    canvas.drawPath(yokePath, Paint()..color = yokeColor);
    canvas.drawPath(sidePath, Paint()..color = sideColor);
    canvas.drawPath(sleevesPath, Paint()..color = sleevesColor);

    if (trim.primaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(trim.primaryPath, targetSize: s),
        Paint()..color = trimColor,
      );
    }

    if (cuff.primaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(cuff.primaryPath, targetSize: s),
        Paint()..color = cuffColor,
      );
    }

    if (!isBack && collar.secondaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(collar.secondaryPath, targetSize: s),
        Paint()..color = innerCollarColor,
      );
    }
    if (collar.primaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(collar.primaryPath, targetSize: s),
        Paint()..color = collarColor,
      );
    }

    if (jersey.fabricShading) {
      final foldPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.16),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(Offset.zero & s);
      canvas.drawPath(bodyPath, foldPaint);
    }

    final seamPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.008;
    canvas.drawPath(bodyPath, seamPaint);
    canvas.drawPath(sleevesPath, seamPaint);

    if (!isBack) {
      if (jersey.showChestCrest) {
        final crestSize = s.width * 0.12;
        double cx = s.width * 0.58;
        if (jersey.chestCrestPosition == 'center') cx = s.width * 0.44;
        if (jersey.chestCrestPosition == 'right') cx = s.width * 0.30;
        canvas.save();
        canvas.translate(cx, s.height * 0.26);
        CrestPainter(crest: crest, layers: layers)
            .paint(canvas, Size(crestSize, crestSize));
        canvas.restore();
      }

      if (jersey.sponsorText.trim().isNotEmpty) {
        SvgParser.drawWarpedText(
          canvas: canvas,
          text: jersey.sponsorText,
          center: Offset(s.width * 0.5, s.height * 0.48),
          fontSize: s.width * 0.052,
          styleId: jersey.numberStyleId,
          fillColor: Color(jersey.sponsorColor),
          outlineColor: Colors.black,
          outlineWidth: 1.0,
          doubleOutlineColor: Colors.transparent,
          doubleOutlineWidth: 0.0,
          warpMode: TextWarpMode.none,
          warpIntensity: 0,
        );
      }

      if (jersey.showFrontNumber && jersey.playerNumber.trim().isNotEmpty) {
        SvgParser.drawWarpedText(
          canvas: canvas,
          text: jersey.playerNumber,
          center: Offset(s.width * 0.5, s.height * 0.62),
          fontSize: s.width * 0.11,
          styleId: jersey.numberStyleId,
          fillColor: Color(jersey.numberFillColor),
          outlineColor: Color(jersey.numberOutlineColor),
          outlineWidth: jersey.numberOutlineWidth,
          doubleOutlineColor: Color(jersey.numberDoubleOutlineColor),
          doubleOutlineWidth: jersey.numberDoubleOutlineWidth,
          warpMode: TextWarpMode.none,
          warpIntensity: 0,
        );
      }
    } else {
      if (jersey.playerName.trim().isNotEmpty) {
        SvgParser.drawWarpedText(
          canvas: canvas,
          text: jersey.playerName,
          center: Offset(s.width * 0.5, s.height * 0.29),
          fontSize: s.width * 0.062,
          styleId: jersey.numberStyleId,
          fillColor: Color(jersey.numberFillColor),
          outlineColor: Color(jersey.numberOutlineColor),
          outlineWidth: jersey.numberOutlineWidth * 0.6,
          doubleOutlineColor: Color(jersey.numberDoubleOutlineColor),
          doubleOutlineWidth: 0,
          warpMode: jersey.nameWarp,
          warpIntensity: s.width * 0.18,
        );
      }

      if (jersey.playerNumber.trim().isNotEmpty) {
        SvgParser.drawWarpedText(
          canvas: canvas,
          text: jersey.playerNumber,
          center: Offset(s.width * 0.5, s.height * 0.54),
          fontSize: s.width * 0.26,
          styleId: jersey.numberStyleId,
          fillColor: Color(jersey.numberFillColor),
          outlineColor: Color(jersey.numberOutlineColor),
          outlineWidth: jersey.numberOutlineWidth,
          doubleOutlineColor: Color(jersey.numberDoubleOutlineColor),
          doubleOutlineWidth: jersey.numberDoubleOutlineWidth,
          warpMode: TextWarpMode.none,
          warpIntensity: 0,
        );
      }
    }
  }

  void _paintBodyPattern(Canvas canvas, Size s, Path clipPath) {
    final patConfig = jersey.bodyPattern;
    final patAsset = PatternLibrary.byId(patConfig.patternId);
    if (patAsset.id == 'solid') return;

    canvas.save();
    canvas.clipPath(clipPath);

    if (patAsset.isGradient) {
      final rect = Offset.zero & s;
      final c1 = Color(patConfig.primaryColor);
      final c2 = Color(patConfig.secondaryColor);
      final shader = patAsset.id == 'gradient_radial'
          ? RadialGradient(colors: [c2, c1]).createShader(rect)
          : LinearGradient(
              begin: patAsset.id == 'gradient_horizontal'
                  ? Alignment.centerLeft
                  : Alignment.topCenter,
              end: patAsset.id == 'gradient_horizontal'
                  ? Alignment.centerRight
                  : Alignment.bottomCenter,
              colors: [c1, c2],
            ).createShader(rect);
      canvas.drawRect(rect, Paint()..shader = shader);
      canvas.restore();
      return;
    }

    if (patAsset.svgPath.isNotEmpty) {
      canvas.translate(s.width / 2 + patConfig.offsetX, s.height / 2 + patConfig.offsetY);
      canvas.rotate(patConfig.rotation * math.pi / 180.0);
      canvas.scale(patConfig.scale, patConfig.scale);
      canvas.translate(-s.width / 2, -s.height / 2);

      final pPath = SvgParser.parse(patAsset.svgPath, targetSize: s);
      canvas.drawPath(
        pPath,
        Paint()
          ..color = Color(patConfig.secondaryColor)
              .withValues(alpha: patConfig.opacity),
      );
    }

    canvas.restore();
  }

  void _paintSleeveDetail(Canvas canvas, Size s) {
    final tpl = JerseyLibrary.templateById(jersey.templateId);
    final path = SvgParser.parse(tpl.sleeveSinglePath, targetSize: s);
    canvas.drawPath(
      path,
      Paint()..color = Color(jersey.zoneColors['sleeves'] ?? 0xFFFFFFFF),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    if (jersey.showSleeveCrest) {
      final badgeSize = s.width * 0.24;
      canvas.save();
      canvas.translate((s.width - badgeSize) / 2, s.height * 0.36);
      CrestPainter(crest: crest, layers: layers)
          .paint(canvas, Size(badgeSize, badgeSize));
      canvas.restore();
    }
  }

  void _paintShortsAndSocks(Canvas canvas, Size s) {
    final shorts = JerseyLibrary.shortsById(jersey.shortsStyleId);
    final socks = JerseyLibrary.socksById(jersey.socksStyleId);

    canvas.save();
    canvas.translate(0, -s.height * 0.08);
    canvas.scale(1.0, 0.65);
    final shPath = SvgParser.parse(shorts.primaryPath, targetSize: s);
    canvas.drawPath(
      shPath,
      Paint()..color = Color(jersey.zoneColors['shorts'] ?? 0xFF0F172A),
    );
    if (shorts.secondaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(shorts.secondaryPath, targetSize: s),
        Paint()..color = Color(jersey.zoneColors['shorts_trim'] ?? 0xFFD4AF37),
      );
    }
    canvas.drawPath(
      shPath,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.restore();

    if (jersey.showShortsNumber && jersey.playerNumber.isNotEmpty) {
      SvgParser.drawWarpedText(
        canvas: canvas,
        text: jersey.playerNumber,
        center: Offset(s.width * 0.64, s.height * 0.32),
        fontSize: s.width * 0.07,
        styleId: jersey.numberStyleId,
        fillColor: Color(jersey.numberFillColor),
        outlineColor: Color(jersey.numberOutlineColor),
        outlineWidth: 1.2,
        doubleOutlineColor: Colors.transparent,
        doubleOutlineWidth: 0,
        warpMode: TextWarpMode.none,
        warpIntensity: 0,
      );
    }

    canvas.save();
    canvas.translate(0, s.height * 0.45);
    canvas.scale(1.0, 0.55);
    final skPath = SvgParser.parse(socks.primaryPath, targetSize: s);
    canvas.drawPath(
      skPath,
      Paint()..color = Color(jersey.zoneColors['socks'] ?? 0xFFDC2626),
    );
    if (socks.secondaryPath.isNotEmpty) {
      canvas.drawPath(
        SvgParser.parse(socks.secondaryPath, targetSize: s),
        Paint()
          ..color = Color(jersey.zoneColors['socks_turnover'] ?? 0xFFFFFFFF),
      );
    }
    canvas.drawPath(
      skPath,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant JerseyPainter oldDelegate) => true;
}
