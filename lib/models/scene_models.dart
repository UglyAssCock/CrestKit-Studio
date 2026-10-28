import 'dart:convert';
import 'package:flutter/material.dart';

enum VectorTool {
  select,
  pen,
  rect,
  roundRect,
  circle,
  ellipse,
  polygon,
  star,
  line,
  brush,
}

enum FillType { solid, linearGradient, radialGradient }

enum TextWarpMode { none, arcUp, arcDown, wave, circle }

class ColorStopData {
  double offset;
  int colorValue;

  ColorStopData({required this.offset, required this.colorValue});

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'offset': offset,
        'colorValue': colorValue,
      };

  factory ColorStopData.fromJson(Map<String, dynamic> json) => ColorStopData(
        offset: (json['offset'] as num?)?.toDouble() ?? 0.0,
        colorValue: (json['colorValue'] as int?) ?? 0xFFFFFFFF,
      );

  ColorStopData copy() => ColorStopData(offset: offset, colorValue: colorValue);
}

class VectorNode {
  double x;
  double y;
  double? ctrl1X;
  double? ctrl1Y;
  double? ctrl2X;
  double? ctrl2Y;

  VectorNode({
    required this.x,
    required this.y,
    this.ctrl1X,
    this.ctrl1Y,
    this.ctrl2X,
    this.ctrl2Y,
  });

  Offset get position => Offset(x, y);

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'c1x': ctrl1X,
        'c1y': ctrl1Y,
        'c2x': ctrl2X,
        'c2y': ctrl2Y,
      };

  factory VectorNode.fromJson(Map<String, dynamic> json) => VectorNode(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        ctrl1X: (json['c1x'] as num?)?.toDouble(),
        ctrl1Y: (json['c1y'] as num?)?.toDouble(),
        ctrl2X: (json['c2x'] as num?)?.toDouble(),
        ctrl2Y: (json['c2y'] as num?)?.toDouble(),
      );

  VectorNode copy() => VectorNode(
        x: x,
        y: y,
        ctrl1X: ctrl1X,
        ctrl1Y: ctrl1Y,
        ctrl2X: ctrl2X,
        ctrl2Y: ctrl2Y,
      );
}

class VectorShape {
  String id;
  String name;
  String svgPath;
  List<VectorNode> nodes;
  bool closed;
  FillType fillType;
  int fillColor;
  List<ColorStopData> gradientStops;
  double gradientAngle;
  int strokeColor;
  double strokeWidth;
  double dashLength;
  double dashGap;
  int strokeCapIndex;
  int strokeJoinIndex;
  double tx;
  double ty;
  double scaleX;
  double scaleY;
  double rotation;
  bool flipH;
  bool flipV;
  double opacity;
  String? textContent;
  String textStyleId;
  double fontSize;
  double letterSpacing;
  int outlineColor;
  double outlineWidth;
  int doubleOutlineColor;
  double doubleOutlineWidth;
  TextWarpMode textWarp;
  double warpIntensity;

  VectorShape({
    required this.id,
    required this.name,
    required this.svgPath,
    List<VectorNode>? nodes,
    this.closed = true,
    this.fillType = FillType.solid,
    this.fillColor = 0xFFD4AF37,
    List<ColorStopData>? gradientStops,
    this.gradientAngle = 0.0,
    this.strokeColor = 0xFF111827,
    this.strokeWidth = 1.5,
    this.dashLength = 0.0,
    this.dashGap = 0.0,
    this.strokeCapIndex = 1,
    this.strokeJoinIndex = 1,
    this.tx = 50.0,
    this.ty = 50.0,
    this.scaleX = 0.5,
    this.scaleY = 0.5,
    this.rotation = 0.0,
    this.flipH = false,
    this.flipV = false,
    this.opacity = 1.0,
    this.textContent,
    this.textStyleId = 'block',
    this.fontSize = 12.0,
    this.letterSpacing = 1.0,
    this.outlineColor = 0xFF000000,
    this.outlineWidth = 0.0,
    this.doubleOutlineColor = 0xFFFFFFFF,
    this.doubleOutlineWidth = 0.0,
    this.textWarp = TextWarpMode.none,
    this.warpIntensity = 25.0,
  })  : nodes = nodes ?? [],
        gradientStops = gradientStops ??
            [
              ColorStopData(offset: 0.0, colorValue: 0xFFFFD700),
              ColorStopData(offset: 1.0, colorValue: 0xFFB8860B),
            ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'svgPath': svgPath,
        'nodes': nodes.map((e) => e.toJson()).toList(),
        'closed': closed,
        'fillType': fillType.index,
        'fillColor': fillColor,
        'gradientStops': gradientStops.map((e) => e.toJson()).toList(),
        'gradientAngle': gradientAngle,
        'strokeColor': strokeColor,
        'strokeWidth': strokeWidth,
        'dashLength': dashLength,
        'dashGap': dashGap,
        'strokeCapIndex': strokeCapIndex,
        'strokeJoinIndex': strokeJoinIndex,
        'tx': tx,
        'ty': ty,
        'scaleX': scaleX,
        'scaleY': scaleY,
        'rotation': rotation,
        'flipH': flipH,
        'flipV': flipV,
        'opacity': opacity,
        'textContent': textContent,
        'textStyleId': textStyleId,
        'fontSize': fontSize,
        'letterSpacing': letterSpacing,
        'outlineColor': outlineColor,
        'outlineWidth': outlineWidth,
        'doubleOutlineColor': doubleOutlineColor,
        'doubleOutlineWidth': doubleOutlineWidth,
        'textWarp': textWarp.index,
        'warpIntensity': warpIntensity,
      };

  factory VectorShape.fromJson(Map<String, dynamic> json) => VectorShape(
        id: json['id'] as String? ?? 'shape_1',
        name: json['name'] as String? ?? 'Shape',
        svgPath: json['svgPath'] as String? ?? 'M 20 20 L 80 20 L 80 80 L 20 80 Z',
        nodes: (json['nodes'] as List<dynamic>?)
                ?.map((e) => VectorNode.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        closed: json['closed'] as bool? ?? true,
        fillType: FillType.values[(json['fillType'] as int?) ?? 0],
        fillColor: json['fillColor'] as int? ?? 0xFFD4AF37,
        gradientStops: (json['gradientStops'] as List<dynamic>?)
                ?.map((e) => ColorStopData.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [
              ColorStopData(offset: 0.0, colorValue: 0xFFFFD700),
              ColorStopData(offset: 1.0, colorValue: 0xFFB8860B),
            ],
        gradientAngle: (json['gradientAngle'] as num?)?.toDouble() ?? 0.0,
        strokeColor: json['strokeColor'] as int? ?? 0xFF111827,
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 1.5,
        dashLength: (json['dashLength'] as num?)?.toDouble() ?? 0.0,
        dashGap: (json['dashGap'] as num?)?.toDouble() ?? 0.0,
        strokeCapIndex: json['strokeCapIndex'] as int? ?? 1,
        strokeJoinIndex: json['strokeJoinIndex'] as int? ?? 1,
        tx: (json['tx'] as num?)?.toDouble() ?? 50.0,
        ty: (json['ty'] as num?)?.toDouble() ?? 50.0,
        scaleX: (json['scaleX'] as num?)?.toDouble() ?? 0.5,
        scaleY: (json['scaleY'] as num?)?.toDouble() ?? 0.5,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        flipH: json['flipH'] as bool? ?? false,
        flipV: json['flipV'] as bool? ?? false,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        textContent: json['textContent'] as String?,
        textStyleId: json['textStyleId'] as String? ?? 'block',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 12.0,
        letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 1.0,
        outlineColor: json['outlineColor'] as int? ?? 0xFF000000,
        outlineWidth: (json['outlineWidth'] as num?)?.toDouble() ?? 0.0,
        doubleOutlineColor: json['doubleOutlineColor'] as int? ?? 0xFFFFFFFF,
        doubleOutlineWidth: (json['doubleOutlineWidth'] as num?)?.toDouble() ?? 0.0,
        textWarp: TextWarpMode.values[(json['textWarp'] as int?) ?? 0],
        warpIntensity: (json['warpIntensity'] as num?)?.toDouble() ?? 25.0,
      );

  VectorShape copy({String? newId}) => VectorShape(
        id: newId ?? id,
        name: name,
        svgPath: svgPath,
        nodes: nodes.map((e) => e.copy()).toList(),
        closed: closed,
        fillType: fillType,
        fillColor: fillColor,
        gradientStops: gradientStops.map((e) => e.copy()).toList(),
        gradientAngle: gradientAngle,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
        strokeCapIndex: strokeCapIndex,
        strokeJoinIndex: strokeJoinIndex,
        tx: tx,
        ty: ty,
        scaleX: scaleX,
        scaleY: scaleY,
        rotation: rotation,
        flipH: flipH,
        flipV: flipV,
        opacity: opacity,
        textContent: textContent,
        textStyleId: textStyleId,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        outlineColor: outlineColor,
        outlineWidth: outlineWidth,
        doubleOutlineColor: doubleOutlineColor,
        doubleOutlineWidth: doubleOutlineWidth,
        textWarp: textWarp,
        warpIntensity: warpIntensity,
      );
}

class VectorLayer {
  String id;
  String name;
  bool visible;
  bool locked;
  double opacity;
  String? groupName;
  List<VectorShape> shapes;

  VectorLayer({
    required this.id,
    required this.name,
    this.visible = true,
    this.locked = false,
    this.opacity = 1.0,
    this.groupName,
    List<VectorShape>? shapes,
  }) : shapes = shapes ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'visible': visible,
        'locked': locked,
        'opacity': opacity,
        'groupName': groupName,
        'shapes': shapes.map((e) => e.toJson()).toList(),
      };

  factory VectorLayer.fromJson(Map<String, dynamic> json) => VectorLayer(
        id: json['id'] as String? ?? 'layer_1',
        name: json['name'] as String? ?? 'Layer 1',
        visible: json['visible'] as bool? ?? true,
        locked: json['locked'] as bool? ?? false,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        groupName: json['groupName'] as String?,
        shapes: (json['shapes'] as List<dynamic>?)
                ?.map((e) => VectorShape.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  VectorLayer copy({String? newId}) => VectorLayer(
        id: newId ?? id,
        name: name,
        visible: visible,
        locked: locked,
        opacity: opacity,
        groupName: groupName,
        shapes: shapes.map((e) => e.copy()).toList(),
      );
}

class CrestConfig {
  String shieldId;
  int shieldPrimaryColor;
  int shieldSecondaryColor;
  int shieldStrokeColor;
  double shieldStrokeWidth;
  int outlineCount; // 1 = single, 2 = double, 3 = triple
  bool hasBordure;
  int bordureColor;
  String divisionId;
  int divisionColor1;
  int divisionColor2;
  String topBannerText;
  String bottomBannerText;
  int bannerColor;
  int bannerTextColor;
  bool arcBannerText;

  CrestConfig({
    this.shieldId = 'heater',
    this.shieldPrimaryColor = 0xFF0F172A,
    this.shieldSecondaryColor = 0xFF1E293B,
    this.shieldStrokeColor = 0xFFD4AF37,
    this.shieldStrokeWidth = 3.0,
    this.outlineCount = 2,
    this.hasBordure = true,
    this.bordureColor = 0xFFD4AF37,
    this.divisionId = 'per_pale',
    this.divisionColor1 = 0xFFDC2626,
    this.divisionColor2 = 0xFF1D4ED8,
    this.topBannerText = 'CRESTKIT FC',
    this.bottomBannerText = 'EST. 2026',
    this.bannerColor = 0xFFD4AF37,
    this.bannerTextColor = 0xFF0F172A,
    this.arcBannerText = true,
  });

  Map<String, dynamic> toJson() => {
        'shieldId': shieldId,
        'shieldPrimaryColor': shieldPrimaryColor,
        'shieldSecondaryColor': shieldSecondaryColor,
        'shieldStrokeColor': shieldStrokeColor,
        'shieldStrokeWidth': shieldStrokeWidth,
        'outlineCount': outlineCount,
        'hasBordure': hasBordure,
        'bordureColor': bordureColor,
        'divisionId': divisionId,
        'divisionColor1': divisionColor1,
        'divisionColor2': divisionColor2,
        'topBannerText': topBannerText,
        'bottomBannerText': bottomBannerText,
        'bannerColor': bannerColor,
        'bannerTextColor': bannerTextColor,
        'arcBannerText': arcBannerText,
      };

  factory CrestConfig.fromJson(Map<String, dynamic> json) => CrestConfig(
        shieldId: json['shieldId'] as String? ?? 'heater',
        shieldPrimaryColor: json['shieldPrimaryColor'] as int? ?? 0xFF0F172A,
        shieldSecondaryColor: json['shieldSecondaryColor'] as int? ?? 0xFF1E293B,
        shieldStrokeColor: json['shieldStrokeColor'] as int? ?? 0xFFD4AF37,
        shieldStrokeWidth: (json['shieldStrokeWidth'] as num?)?.toDouble() ?? 3.0,
        outlineCount: json['outlineCount'] as int? ?? 2,
        hasBordure: json['hasBordure'] as bool? ?? true,
        bordureColor: json['bordureColor'] as int? ?? 0xFFD4AF37,
        divisionId: json['divisionId'] as String? ?? 'per_pale',
        divisionColor1: json['divisionColor1'] as int? ?? 0xFFDC2626,
        divisionColor2: json['divisionColor2'] as int? ?? 0xFF1D4ED8,
        topBannerText: json['topBannerText'] as String? ?? 'CRESTKIT FC',
        bottomBannerText: json['bottomBannerText'] as String? ?? 'EST. 2026',
        bannerColor: json['bannerColor'] as int? ?? 0xFFD4AF37,
        bannerTextColor: json['bannerTextColor'] as int? ?? 0xFF0F172A,
        arcBannerText: json['arcBannerText'] as bool? ?? true,
      );

  CrestConfig copy() => CrestConfig.fromJson(toJson());
}

class PatternConfig {
  String patternId;
  int primaryColor;
  int secondaryColor;
  double scale;
  double rotation;
  double offsetX;
  double offsetY;
  double opacity;

  PatternConfig({
    this.patternId = 'stripes_vertical',
    this.primaryColor = 0xFFDC2626,
    this.secondaryColor = 0xFFFFFFFF,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.opacity = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'patternId': patternId,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'scale': scale,
        'rotation': rotation,
        'offsetX': offsetX,
        'offsetY': offsetY,
        'opacity': opacity,
      };

  factory PatternConfig.fromJson(Map<String, dynamic> json) => PatternConfig(
        patternId: json['patternId'] as String? ?? 'stripes_vertical',
        primaryColor: json['primaryColor'] as int? ?? 0xFFDC2626,
        secondaryColor: json['secondaryColor'] as int? ?? 0xFFFFFFFF,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0.0,
        offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0.0,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      );

  PatternConfig copy() => PatternConfig.fromJson(toJson());
}

class SquadPlayer {
  String name;
  int number;
  String role;

  SquadPlayer({required this.name, required this.number, this.role = 'Starter'});

  Map<String, dynamic> toJson() => {
        'name': name,
        'number': number,
        'role': role,
      };

  factory SquadPlayer.fromJson(Map<String, dynamic> json) => SquadPlayer(
        name: json['name'] as String? ?? 'PLAYER',
        number: json['number'] as int? ?? 10,
        role: json['role'] as String? ?? 'Starter',
      );
}

class JerseyConfig {
  String templateId;
  String collarId;
  String cuffId;
  String trimId;
  String shortsStyleId;
  String socksStyleId;
  Map<String, int> zoneColors;
  PatternConfig bodyPattern;
  bool fabricShading;
  bool showChestCrest;
  String chestCrestPosition; // 'left', 'center', 'right'
  bool showSleeveCrest;
  String sponsorText;
  int sponsorColor;
  String playerName;
  String playerNumber;
  String numberStyleId;
  int numberFillColor;
  int numberOutlineColor;
  double numberOutlineWidth;
  int numberDoubleOutlineColor;
  double numberDoubleOutlineWidth;
  bool showFrontNumber;
  bool showShortsNumber;
  TextWarpMode nameWarp;

  JerseyConfig({
    this.templateId = 'football_short',
    this.collarId = 'v_neck',
    this.cuffId = 'cuff_ribbed',
    this.trimId = 'shoulder_3_stripes',
    this.shortsStyleId = 'shorts_classic',
    this.socksStyleId = 'socks_hooped',
    Map<String, int>? zoneColors,
    PatternConfig? bodyPattern,
    this.fabricShading = true,
    this.showChestCrest = true,
    this.chestCrestPosition = 'left',
    this.showSleeveCrest = true,
    this.sponsorText = 'CRESTKIT AIRWAYS',
    this.sponsorColor = 0xFFFFFFFF,
    this.playerName = 'CAPTAIN',
    this.playerNumber = '10',
    this.numberStyleId = 'athletic',
    this.numberFillColor = 0xFFFFFFFF,
    this.numberOutlineColor = 0xFF0F172A,
    this.numberOutlineWidth = 2.0,
    this.numberDoubleOutlineColor = 0xFFD4AF37,
    this.numberDoubleOutlineWidth = 1.0,
    this.showFrontNumber = false,
    this.showShortsNumber = true,
    this.nameWarp = TextWarpMode.arcUp,
  })  : zoneColors = zoneColors ??
            {
              'body': 0xFFDC2626,
              'sleeves': 0xFFFFFFFF,
              'collar': 0xFF0F172A,
              'cuffs': 0xFFDC2626,
              'side_panels': 0xFFB91C1C,
              'yoke': 0xFF991B1B,
              'trim': 0xFFD4AF37,
              'inner_collar': 0xFF7F1D1D,
              'shorts': 0xFF0F172A,
              'shorts_trim': 0xFFD4AF37,
              'socks': 0xFFDC2626,
              'socks_turnover': 0xFFFFFFFF,
            },
        bodyPattern = bodyPattern ?? PatternConfig();

  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        'collarId': collarId,
        'cuffId': cuffId,
        'trimId': trimId,
        'shortsStyleId': shortsStyleId,
        'socksStyleId': socksStyleId,
        'zoneColors': zoneColors,
        'bodyPattern': bodyPattern.toJson(),
        'fabricShading': fabricShading,
        'showChestCrest': showChestCrest,
        'chestCrestPosition': chestCrestPosition,
        'showSleeveCrest': showSleeveCrest,
        'sponsorText': sponsorText,
        'sponsorColor': sponsorColor,
        'playerName': playerName,
        'playerNumber': playerNumber,
        'numberStyleId': numberStyleId,
        'numberFillColor': numberFillColor,
        'numberOutlineColor': numberOutlineColor,
        'numberOutlineWidth': numberOutlineWidth,
        'numberDoubleOutlineColor': numberDoubleOutlineColor,
        'numberDoubleOutlineWidth': numberDoubleOutlineWidth,
        'showFrontNumber': showFrontNumber,
        'showShortsNumber': showShortsNumber,
        'nameWarp': nameWarp.index,
      };

  factory JerseyConfig.fromJson(Map<String, dynamic> json) => JerseyConfig(
        templateId: json['templateId'] as String? ?? 'football_short',
        collarId: json['collarId'] as String? ?? 'v_neck',
        cuffId: json['cuffId'] as String? ?? 'cuff_ribbed',
        trimId: json['trimId'] as String? ?? 'shoulder_3_stripes',
        shortsStyleId: json['shortsStyleId'] as String? ?? 'shorts_classic',
        socksStyleId: json['socksStyleId'] as String? ?? 'socks_hooped',
        zoneColors: (json['zoneColors'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num).toInt()),
            ) ??
            {
              'body': 0xFFDC2626,
              'sleeves': 0xFFFFFFFF,
              'collar': 0xFF0F172A,
              'cuffs': 0xFFDC2626,
              'side_panels': 0xFFB91C1C,
              'yoke': 0xFF991B1B,
              'trim': 0xFFD4AF37,
              'inner_collar': 0xFF7F1D1D,
              'shorts': 0xFF0F172A,
              'shorts_trim': 0xFFD4AF37,
              'socks': 0xFFDC2626,
              'socks_turnover': 0xFFFFFFFF,
            },
        bodyPattern: json['bodyPattern'] != null
            ? PatternConfig.fromJson(json['bodyPattern'] as Map<String, dynamic>)
            : PatternConfig(),
        fabricShading: json['fabricShading'] as bool? ?? true,
        showChestCrest: json['showChestCrest'] as bool? ?? true,
        chestCrestPosition: json['chestCrestPosition'] as String? ?? 'left',
        showSleeveCrest: json['showSleeveCrest'] as bool? ?? true,
        sponsorText: json['sponsorText'] as String? ?? 'CRESTKIT AIRWAYS',
        sponsorColor: json['sponsorColor'] as int? ?? 0xFFFFFFFF,
        playerName: json['playerName'] as String? ?? 'CAPTAIN',
        playerNumber: json['playerNumber'] as String? ?? '10',
        numberStyleId: json['numberStyleId'] as String? ?? 'athletic',
        numberFillColor: json['numberFillColor'] as int? ?? 0xFFFFFFFF,
        numberOutlineColor: json['numberOutlineColor'] as int? ?? 0xFF0F172A,
        numberOutlineWidth: (json['numberOutlineWidth'] as num?)?.toDouble() ?? 2.0,
        numberDoubleOutlineColor:
            json['numberDoubleOutlineColor'] as int? ?? 0xFFD4AF37,
        numberDoubleOutlineWidth:
            (json['numberDoubleOutlineWidth'] as num?)?.toDouble() ?? 1.0,
        showFrontNumber: json['showFrontNumber'] as bool? ?? false,
        showShortsNumber: json['showShortsNumber'] as bool? ?? true,
        nameWarp: TextWarpMode.values[(json['nameWarp'] as int?) ?? 1],
      );

  JerseyConfig copy() => JerseyConfig.fromJson(toJson());
}

class KitSet {
  String id;
  String name; // Home, Away, Third, Goalkeeper
  CrestConfig crest;
  JerseyConfig jersey;
  List<VectorLayer> layers;

  KitSet({
    required this.id,
    required this.name,
    CrestConfig? crest,
    JerseyConfig? jersey,
    List<VectorLayer>? layers,
  })  : crest = crest ?? CrestConfig(),
        jersey = jersey ?? JerseyConfig(),
        layers = layers ??
            [
              VectorLayer(
                id: 'layer_emblem',
                name: 'Main Emblem',
                shapes: [
                  VectorShape(
                    id: 'shape_lion',
                    name: 'Lion Rampant',
                    svgPath:
                        'M 50 18 L 62 26 L 58 40 L 72 46 L 60 56 L 66 78 L 50 70 L 34 78 L 40 56 L 28 46 L 42 40 L 38 26 Z',
                    fillColor: 0xFFD4AF37,
                    strokeColor: 0xFF0F172A,
                    strokeWidth: 1.8,
                    tx: 50,
                    ty: 50,
                    scaleX: 0.55,
                    scaleY: 0.55,
                  ),
                ],
              ),
            ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'crest': crest.toJson(),
        'jersey': jersey.toJson(),
        'layers': layers.map((e) => e.toJson()).toList(),
      };

  factory KitSet.fromJson(Map<String, dynamic> json) => KitSet(
        id: json['id'] as String? ?? 'home',
        name: json['name'] as String? ?? 'Home',
        crest: json['crest'] != null
            ? CrestConfig.fromJson(json['crest'] as Map<String, dynamic>)
            : CrestConfig(),
        jersey: json['jersey'] != null
            ? JerseyConfig.fromJson(json['jersey'] as Map<String, dynamic>)
            : JerseyConfig(),
        layers: (json['layers'] as List<dynamic>?)
                ?.map((e) => VectorLayer.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  KitSet copy() => KitSet.fromJson(toJson());
}

class StudioProject {
  String id;
  String name;
  DateTime updatedAt;
  int primaryTeamColor;
  int secondaryTeamColor;
  int accentTeamColor;
  List<int> recentColors;
  String backgroundId;
  List<KitSet> kits;
  List<SquadPlayer> squad;
  String? referenceImagePath;
  double referenceOpacity;

  StudioProject({
    required this.id,
    required this.name,
    DateTime? updatedAt,
    this.primaryTeamColor = 0xFFDC2626,
    this.secondaryTeamColor = 0xFFFFFFFF,
    this.accentTeamColor = 0xFFD4AF37,
    List<int>? recentColors,
    this.backgroundId = 'bg_stadium_night',
    List<KitSet>? kits,
    List<SquadPlayer>? squad,
    this.referenceImagePath,
    this.referenceOpacity = 0.35,
  })  : updatedAt = updatedAt ?? DateTime.now(),
        recentColors = recentColors ??
            [
              0xFFDC2626,
              0xFFFFFFFF,
              0xFFD4AF37,
              0xFF0F172A,
              0xFF1D4ED8,
              0xFF00E5A3,
              0xFFF59E0B,
              0xFF7C3AED,
            ],
        kits = kits ??
            [
              KitSet(id: 'home', name: 'Home'),
              KitSet(
                id: 'away',
                name: 'Away',
                crest: CrestConfig(
                  shieldPrimaryColor: 0xFFFFFFFF,
                  divisionColor1: 0xFFFFFFFF,
                  divisionColor2: 0xFF0F172A,
                ),
                jersey: JerseyConfig(
                  zoneColors: {
                    'body': 0xFFFFFFFF,
                    'sleeves': 0xFF0F172A,
                    'collar': 0xFFDC2626,
                    'cuffs': 0xFFDC2626,
                    'side_panels': 0xFFE2E8F0,
                    'yoke': 0xFF0F172A,
                    'trim': 0xFFD4AF37,
                    'inner_collar': 0xFF0F172A,
                    'shorts': 0xFFFFFFFF,
                    'shorts_trim': 0xFFDC2626,
                    'socks': 0xFF0F172A,
                    'socks_turnover': 0xFFDC2626,
                  },
                  bodyPattern: PatternConfig(
                    patternId: 'sash_right',
                    primaryColor: 0xFFFFFFFF,
                    secondaryColor: 0xFFDC2626,
                  ),
                  sponsorColor: 0xFF0F172A,
                  numberFillColor: 0xFF0F172A,
                  numberOutlineColor: 0xFFD4AF37,
                ),
              ),
              KitSet(
                id: 'third',
                name: 'Third',
                crest: CrestConfig(
                  shieldPrimaryColor: 0xFF0F172A,
                  divisionColor1: 0xFF0F172A,
                  divisionColor2: 0xFF00E5A3,
                ),
                jersey: JerseyConfig(
                  zoneColors: {
                    'body': 0xFF0F172A,
                    'sleeves': 0xFF0F172A,
                    'collar': 0xFF00E5A3,
                    'cuffs': 0xFF00E5A3,
                    'side_panels': 0xFF00E5A3,
                    'yoke': 0xFF1E293B,
                    'trim': 0xFF00E5A3,
                    'inner_collar': 0xFF00E5A3,
                    'shorts': 0xFF0F172A,
                    'shorts_trim': 0xFF00E5A3,
                    'socks': 0xFF0F172A,
                    'socks_turnover': 0xFF00E5A3,
                  },
                  bodyPattern: PatternConfig(
                    patternId: 'hex_mesh',
                    primaryColor: 0xFF0F172A,
                    secondaryColor: 0xFF00E5A3,
                  ),
                ),
              ),
              KitSet(
                id: 'gk',
                name: 'Goalkeeper',
                crest: CrestConfig(
                  shieldPrimaryColor: 0xFF065F46,
                  divisionColor1: 0xFF10B981,
                  divisionColor2: 0xFF047857,
                ),
                jersey: JerseyConfig(
                  templateId: 'football_gk_long',
                  zoneColors: {
                    'body': 0xFF10B981,
                    'sleeves': 0xFF047857,
                    'collar': 0xFF0F172A,
                    'cuffs': 0xFF0F172A,
                    'side_panels': 0xFF059669,
                    'yoke': 0xFF047857,
                    'trim': 0xFFFFFFFF,
                    'inner_collar': 0xFF0F172A,
                    'shorts': 0xFF047857,
                    'shorts_trim': 0xFFFFFFFF,
                    'socks': 0xFF10B981,
                    'socks_turnover': 0xFF0F172A,
                  },
                  bodyPattern: PatternConfig(
                    patternId: 'sublimation_geo_1',
                    primaryColor: 0xFF10B981,
                    secondaryColor: 0xFF047857,
                  ),
                  playerNumber: '1',
                  playerName: 'KEEPER',
                ),
              ),
            ],
        squad = squad ??
            [
              SquadPlayer(name: 'GUARDIOLA', number: 1, role: 'GK'),
              SquadPlayer(name: 'HAKIMI', number: 2, role: 'DEF'),
              SquadPlayer(name: 'SALIBA', number: 4, role: 'DEF'),
              SquadPlayer(name: 'BENNACER', number: 6, role: 'MID'),
              SquadPlayer(name: 'MAHREZ', number: 7, role: 'FWD'),
              SquadPlayer(name: 'BELLINGHAM', number: 8, role: 'MID'),
              SquadPlayer(name: 'HAALAND', number: 9, role: 'FWD'),
              SquadPlayer(name: 'CAPTAIN', number: 10, role: 'FWD'),
              SquadPlayer(name: 'VINICIUS', number: 11, role: 'FWD'),
            ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'updatedAt': updatedAt.toIso8601String(),
        'primaryTeamColor': primaryTeamColor,
        'secondaryTeamColor': secondaryTeamColor,
        'accentTeamColor': accentTeamColor,
        'recentColors': recentColors,
        'backgroundId': backgroundId,
        'kits': kits.map((e) => e.toJson()).toList(),
        'squad': squad.map((e) => e.toJson()).toList(),
        'referenceImagePath': referenceImagePath,
        'referenceOpacity': referenceOpacity,
      };

  factory StudioProject.fromJson(Map<String, dynamic> json) => StudioProject(
        id: json['id'] as String? ?? 'proj_1',
        name: json['name'] as String? ?? 'Untitled Club',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        primaryTeamColor: json['primaryTeamColor'] as int? ?? 0xFFDC2626,
        secondaryTeamColor: json['secondaryTeamColor'] as int? ?? 0xFFFFFFFF,
        accentTeamColor: json['accentTeamColor'] as int? ?? 0xFFD4AF37,
        recentColors: (json['recentColors'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [0xFFDC2626, 0xFFFFFFFF, 0xFFD4AF37, 0xFF0F172A],
        backgroundId: json['backgroundId'] as String? ?? 'bg_stadium_night',
        kits: (json['kits'] as List<dynamic>?)
                ?.map((e) => KitSet.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        squad: (json['squad'] as List<dynamic>?)
                ?.map((e) => SquadPlayer.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        referenceImagePath: json['referenceImagePath'] as String?,
        referenceOpacity: (json['referenceOpacity'] as num?)?.toDouble() ?? 0.35,
      );

  String toJsonString() => jsonEncode(toJson());

  factory StudioProject.fromJsonString(String source) =>
      StudioProject.fromJson(jsonDecode(source) as Map<String, dynamic>);

  StudioProject copy({String? newId, String? newName}) {
    final cloned = StudioProject.fromJson(toJson());
    if (newId != null) cloned.id = newId;
    if (newName != null) cloned.name = newName;
    cloned.updatedAt = DateTime.now();
    return cloned;
  }
}
