import 'package:flutter/material.dart';
import '../models/scene_models.dart';

class TextStylePreset {
  final String id;
  final String name;
  final String category;
  final FontWeight weight;
  final FontStyle fontStyle;
  final double letterSpacing;
  final bool useVectorGlyphs;
  final bool hasInlineStripe;
  final bool isStencil;

  const TextStylePreset({
    required this.id,
    required this.name,
    required this.category,
    this.weight = FontWeight.w800,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 1.2,
    this.useVectorGlyphs = false,
    this.hasInlineStripe = false,
    this.isStencil = false,
  });
}

class BackgroundPreset {
  final String id;
  final String name;
  final String category;
  final List<int> colors;
  final String overlayType; // 'none', 'stadium', 'pitch', 'locker', 'spotlight', 'grid', 'stripes', 'geo', 'city'

  const BackgroundPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.colors,
    this.overlayType = 'none',
  });
}

class KitPresetData {
  final String id;
  final String name;
  final String sport;
  final String style; // Classic, Modern, Retro, Esports
  final int primaryColor;
  final int secondaryColor;
  final int accentColor;
  final String shieldId;
  final String divisionId;
  final String emblemPath;
  final String templateId;
  final String collarId;
  final String patternId;
  final String topBanner;
  final String bottomBanner;

  const KitPresetData({
    required this.id,
    required this.name,
    required this.sport,
    required this.style,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.shieldId,
    required this.divisionId,
    required this.emblemPath,
    required this.templateId,
    required this.collarId,
    required this.patternId,
    required this.topBanner,
    required this.bottomBanner,
  });

  KitSet toKitSet() {
    return KitSet(
      id: id,
      name: name,
      crest: CrestConfig(
        shieldId: shieldId,
        shieldPrimaryColor: primaryColor,
        shieldSecondaryColor: secondaryColor,
        shieldStrokeColor: accentColor,
        shieldStrokeWidth: 3.0,
        outlineCount: 2,
        hasBordure: true,
        bordureColor: accentColor,
        divisionId: divisionId,
        divisionColor1: primaryColor,
        divisionColor2: secondaryColor,
        topBannerText: topBanner,
        bottomBannerText: bottomBanner,
        bannerColor: accentColor,
        bannerTextColor: primaryColor,
        arcBannerText: true,
      ),
      jersey: JerseyConfig(
        templateId: templateId,
        collarId: collarId,
        zoneColors: {
          'body': primaryColor,
          'sleeves': secondaryColor,
          'collar': accentColor,
          'cuffs': accentColor,
          'side_panels': secondaryColor,
          'yoke': primaryColor,
          'trim': accentColor,
          'inner_collar': primaryColor,
          'shorts': secondaryColor,
          'shorts_trim': accentColor,
          'socks': primaryColor,
          'socks_turnover': accentColor,
        },
        bodyPattern: PatternConfig(
          patternId: patternId,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
        sponsorText: '$topBanner AIR',
        sponsorColor: accentColor,
        numberFillColor: accentColor,
        numberOutlineColor: primaryColor,
        numberDoubleOutlineColor: secondaryColor,
      ),
      layers: [
        VectorLayer(
          id: 'layer_${id}_main',
          name: 'Club Emblem',
          shapes: [
            VectorShape(
              id: 'shape_${id}_emblem',
              name: name,
              svgPath: emblemPath,
              fillColor: accentColor,
              strokeColor: primaryColor,
              strokeWidth: 1.6,
              tx: 50,
              ty: 50,
              scaleX: 0.52,
              scaleY: 0.52,
            ),
          ],
        ),
      ],
    );
  }
}

class PresetLibrary {
  static final List<TextStylePreset> textStyles = [
    const TextStylePreset(id: 'block', name: 'Pro Block', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 1.5),
    const TextStylePreset(id: 'slab', name: 'Varsity Slab', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 2.0, useVectorGlyphs: true),
    const TextStylePreset(id: 'athletic', name: 'Premier Athletic', category: 'Athletic', weight: FontWeight.w800, letterSpacing: 1.2),
    const TextStylePreset(id: 'collegiate', name: 'Collegiate Arch', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 2.4, hasInlineStripe: true),
    const TextStylePreset(id: 'retro', name: '70s Retro Groove', category: 'Retro', weight: FontWeight.w700, letterSpacing: 1.8),
    const TextStylePreset(id: 'italic', name: 'Speed Italic', category: 'Modern', weight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1.0),
    const TextStylePreset(id: 'outline', name: 'Hollow Outline', category: 'Modern', weight: FontWeight.w800, letterSpacing: 2.0),
    const TextStylePreset(id: 'extrude_2d', name: '2D Offset Block', category: 'Modern', weight: FontWeight.w900, letterSpacing: 1.8),
    const TextStylePreset(id: 'neon', name: 'Cyber Glow Line', category: 'Esports', weight: FontWeight.w600, letterSpacing: 3.0),
    const TextStylePreset(id: 'stencil', name: 'Military Stencil', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 2.2, isStencil: true),
    const TextStylePreset(id: 'rounded', name: 'Arena Rounded', category: 'Modern', weight: FontWeight.w700, letterSpacing: 1.0),
    const TextStylePreset(id: 'pixel', name: '8-Bit Arcade', category: 'Esports', weight: FontWeight.w900, letterSpacing: 2.5, useVectorGlyphs: true),
    const TextStylePreset(id: 'brush', name: 'Street Brush Italic', category: 'Modern', weight: FontWeight.w800, fontStyle: FontStyle.italic, letterSpacing: 0.6),
    const TextStylePreset(id: 'serif', name: 'Royal Heraldic Serif', category: 'Classic', weight: FontWeight.w700, letterSpacing: 2.0),
    const TextStylePreset(id: 'bold_condensed', name: 'Tall Condensed', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 0.4),
    const TextStylePreset(id: 'euro_cup', name: 'Continental Cup', category: 'Athletic', weight: FontWeight.w800, letterSpacing: 1.4, hasInlineStripe: true),
    const TextStylePreset(id: 'laliga', name: 'Iberian Cut', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 1.1),
    const TextStylePreset(id: 'serie_a', name: 'Calcio Scudetto', category: 'Classic', weight: FontWeight.w800, letterSpacing: 1.6),
    const TextStylePreset(id: 'bundesliga', name: 'Deutscher Block', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 1.3),
    const TextStylePreset(id: 'cyber_esports', name: 'Mecha Angular', category: 'Esports', weight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2.2),
    const TextStylePreset(id: 'futsal_bold', name: 'Sala Street Bold', category: 'Modern', weight: FontWeight.w900, letterSpacing: 0.8),
    const TextStylePreset(id: 'motorsport', name: 'Grand Prix Slant', category: 'Esports', weight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1.8),
    const TextStylePreset(id: 'classic_roman', name: 'Roman Trajan', category: 'Classic', weight: FontWeight.w600, letterSpacing: 3.2),
    const TextStylePreset(id: 'gothic_modern', name: 'Blackletter Crest', category: 'Classic', weight: FontWeight.w900, letterSpacing: 1.5, useVectorGlyphs: true),
    const TextStylePreset(id: 'inline_stripe', name: 'Twin Inline Track', category: 'Retro', weight: FontWeight.w800, letterSpacing: 2.0, hasInlineStripe: true),
    const TextStylePreset(id: 'chamfered', name: 'Octagon Chamfer', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 1.4, useVectorGlyphs: true),
    const TextStylePreset(id: 'heavy_impact', name: 'Titan Ultra Black', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 0.5),
    const TextStylePreset(id: 'minimal_sans', name: 'Nordic Clean Sans', category: 'Modern', weight: FontWeight.w500, letterSpacing: 3.5),
    const TextStylePreset(id: 'monogram_serif', name: 'Interlocking Monogram', category: 'Classic', weight: FontWeight.w800, letterSpacing: -0.5),
    const TextStylePreset(id: 'vector_block', name: 'Pure Vector Block', category: 'Athletic', weight: FontWeight.w900, letterSpacing: 1.5, useVectorGlyphs: true),
    const TextStylePreset(id: 'vector_serif', name: 'Pure Vector Serif', category: 'Classic', weight: FontWeight.w800, letterSpacing: 1.5, useVectorGlyphs: true),
    const TextStylePreset(id: 'vector_framed', name: 'Pure Vector Plaque', category: 'Retro', weight: FontWeight.w900, letterSpacing: 1.8, useVectorGlyphs: true),
  ];

  static final List<BackgroundPreset> backgrounds = [
    const BackgroundPreset(id: 'bg_solid_1', name: 'Obsidian Pitch', category: 'Solids', colors: [0xFF0B0F19, 0xFF0B0F19]),
    const BackgroundPreset(id: 'bg_solid_2', name: 'Slate Studio', category: 'Solids', colors: [0xFF1E293B, 0xFF1E293B]),
    const BackgroundPreset(id: 'bg_solid_3', name: 'Pure White', category: 'Solids', colors: [0xFFF8FAFC, 0xFFF8FAFC]),
    const BackgroundPreset(id: 'bg_solid_4', name: 'Warm Parchment', category: 'Solids', colors: [0xFFF5F0E6, 0xFFF5F0E6]),
    const BackgroundPreset(id: 'bg_solid_5', name: 'Turf Emerald', category: 'Solids', colors: [0xFF064E3B, 0xFF064E3B]),
    const BackgroundPreset(id: 'bg_solid_6', name: 'Royal Navy', category: 'Solids', colors: [0xFF0F172A, 0xFF0F172A]),
    const BackgroundPreset(id: 'bg_solid_7', name: 'Crimson Velvet', category: 'Solids', colors: [0xFF450A0A, 0xFF450A0A]),
    const BackgroundPreset(id: 'bg_solid_8', name: 'Imperial Purple', category: 'Solids', colors: [0xFF2E1065, 0xFF2E1065]),
    const BackgroundPreset(id: 'bg_solid_9', name: 'Charcoal Concrete', category: 'Solids', colors: [0xFF18181B, 0xFF18181B]),
    const BackgroundPreset(id: 'bg_solid_10', name: 'Championship Gold', category: 'Solids', colors: [0xFF422006, 0xFF422006]),
    const BackgroundPreset(id: 'bg_grad_1', name: 'Champions Tunnel', category: 'Gradients', colors: [0xFF0F172A, 0xFF1E1B4B]),
    const BackgroundPreset(id: 'bg_grad_2', name: 'Emerald Floodlight', category: 'Gradients', colors: [0xFF022C22, 0xFF0F172A]),
    const BackgroundPreset(id: 'bg_grad_3', name: 'Sunset Arena', category: 'Gradients', colors: [0xFF450A0A, 0xFF1E1B4B]),
    const BackgroundPreset(id: 'bg_grad_4', name: 'Cyber Neon Dusk', category: 'Gradients', colors: [0xFF090D16, 0xFF042F2E]),
    const BackgroundPreset(id: 'bg_grad_5', name: 'Silver Showroom', category: 'Gradients', colors: [0xFFE2E8F0, 0xFF94A3B8]),
    const BackgroundPreset(id: 'bg_grad_6', name: 'Golden Hour', category: 'Gradients', colors: [0xFF451A03, 0xFF0F172A]),
    const BackgroundPreset(id: 'bg_stadium_night', name: 'Night Stadium Lights', category: 'Scenes', colors: [0xFF090D16, 0xFF1E293B], overlayType: 'stadium'),
    const BackgroundPreset(id: 'bg_stadium_day', name: 'Sunny Matchday Arena', category: 'Scenes', colors: [0xFF0C4A6E, 0xFF065F46], overlayType: 'stadium'),
    const BackgroundPreset(id: 'bg_stadium_finals', name: 'Cup Final Confetti', category: 'Scenes', colors: [0xFF1E1B4B, 0xFF31102F], overlayType: 'stadium'),
    const BackgroundPreset(id: 'bg_pitch_lines', name: 'Tactical Pitch Chalk', category: 'Scenes', colors: [0xFF065F46, 0xFF047857], overlayType: 'pitch'),
    const BackgroundPreset(id: 'bg_locker_room', name: 'Club Locker Room', category: 'Scenes', colors: [0xFF18181B, 0xFF27272A], overlayType: 'locker'),
    const BackgroundPreset(id: 'bg_studio_dark', name: 'Dark Editorial Studio', category: 'Scenes', colors: [0xFF111827, 0xFF030712], overlayType: 'spotlight'),
    const BackgroundPreset(id: 'bg_spotlight', name: 'Trophy Reveal Spotlight', category: 'Scenes', colors: [0xFF1C1917, 0xFF0C0A09], overlayType: 'spotlight'),
    const BackgroundPreset(id: 'bg_city_street', name: 'Urban Cage Pitch', category: 'Scenes', colors: [0xFF0F172A, 0xFF334155], overlayType: 'city'),
    const BackgroundPreset(id: 'bg_abstract_geo', name: 'Broadcast Geo Graphics', category: 'Scenes', colors: [0xFF0F172A, 0xFF1E293B], overlayType: 'geo'),
    const BackgroundPreset(id: 'bg_blueprint_grid', name: 'Designer Vector Grid', category: 'Scenes', colors: [0xFF0B132B, 0xFF1C2541], overlayType: 'grid'),
    const BackgroundPreset(id: 'bg_diagonal_stripes', name: 'Matchday Diagonal Banner', category: 'Scenes', colors: [0xFF111827, 0xFF1F2937], overlayType: 'stripes'),
  ];

  static const String _lionPath =
      'M 48 12 L 60 18 L 64 30 L 56 38 L 76 34 L 70 46 L 58 48 L 66 64 L 78 86 L 64 88 L 52 68 L 44 68 L 36 88 L 22 86 L 34 62 L 32 42 L 20 38 L 26 26 L 38 30 L 36 18 Z';
  static const String _eaglePath =
      'M 50 16 L 58 24 L 54 32 L 92 14 L 84 36 L 90 42 L 76 54 L 82 60 L 62 66 L 70 86 L 50 78 L 30 86 L 38 66 L 18 60 L 24 54 L 10 42 L 16 36 L 8 14 L 46 32 L 42 24 Z';
  static const String _crownPath =
      'M 12 72 L 8 28 L 30 48 L 50 18 L 70 48 L 92 28 L 88 72 Z';
  static const String _starPath =
      'M 50 10 L 60 36 L 88 36 L 66 52 L 74 80 L 50 64 L 26 80 L 34 52 L 12 36 L 40 36 Z';
  static const String _wolfPath =
      'M 22 12 L 38 30 L 50 26 L 62 30 L 78 12 L 84 44 L 72 68 L 50 90 L 28 68 L 16 44 Z';
  static const String _dragonPath =
      'M 48 10 L 64 16 L 56 28 L 90 20 L 76 52 L 86 68 L 62 72 L 72 90 L 34 88 L 42 64 L 14 54 L 28 26 Z';
  static const String _anchorPath =
      'M 50 12 A 8 8 0 1 0 50 28 A 8 8 0 1 0 50 12 Z M 46 28 L 54 28 L 54 76 Q 72 72 78 56 L 86 60 Q 76 86 50 90 Q 24 86 14 60 L 22 56 Q 28 72 46 76 Z';
  static const String _bullPath =
      'M 10 14 Q 14 38 32 36 L 68 36 Q 86 38 90 14 Q 96 42 74 52 L 66 84 L 50 90 L 34 84 L 26 52 Q 4 42 10 14 Z';

  static final List<KitPresetData> presetKits = [
    const KitPresetData(id: 'preset_1', name: 'Real Madrid Blanco', sport: 'Football', style: 'Classic', primaryColor: 0xFFFFFFFF, secondaryColor: 0xFF1E3A8A, accentColor: 0xFFD4AF37, shieldId: 'round_badge', divisionId: 'bend_sash', emblemPath: _crownPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'solid', topBanner: 'MADRID CF', bottomBanner: 'MCMII'),
    const KitPresetData(id: 'preset_2', name: 'Blaugrana Stripes', sport: 'Football', style: 'Classic', primaryColor: 0xFF1E3A8A, secondaryColor: 0xFF991B1B, accentColor: 0xFFFBBF24, shieldId: 'french', divisionId: 'quartered', emblemPath: _lionPath, templateId: 'football_short', collarId: 'crew', patternId: 'stripes_vertical', topBanner: 'FC CATALUNYA', bottomBanner: '1899'),
    const KitPresetData(id: 'preset_3', name: 'Rossoneri Diavoli', sport: 'Football', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFF111827, accentColor: 0xFFFFFFFF, shieldId: 'oval_vertical', divisionId: 'paly_6', emblemPath: _starPath, templateId: 'football_short', collarId: 'polo', patternId: 'stripes_thin', topBanner: 'AC MILANO', bottomBanner: '1899'),
    const KitPresetData(id: 'preset_4', name: 'Nerazzurri Biscione', sport: 'Football', style: 'Modern', primaryColor: 0xFF1D4ED8, secondaryColor: 0xFF0F172A, accentColor: 0xFFD4AF37, shieldId: 'double_circle', divisionId: 'paly_4', emblemPath: _dragonPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'stripes_vertical', topBanner: 'INTERNAZIONALE', bottomBanner: '1908'),
    const KitPresetData(id: 'preset_5', name: 'Bianconeri Zebra', sport: 'Football', style: 'Modern', primaryColor: 0xFFFFFFFF, secondaryColor: 0xFF0F172A, accentColor: 0xFFD4AF37, shieldId: 'italian', divisionId: 'paly_6', emblemPath: _bullPath, templateId: 'football_short', collarId: 'round', patternId: 'stripes_vertical', topBanner: 'TORINO FC', bottomBanner: '1897'),
    const KitPresetData(id: 'preset_6', name: 'North London Cannon', sport: 'Football', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFD4AF37, shieldId: 'heater', divisionId: 'per_pale', emblemPath: _eaglePath, templateId: 'football_short', collarId: 'round', patternId: 'solid', topBanner: 'HIGHBURY FC', bottomBanner: '1886'),
    const KitPresetData(id: 'preset_7', name: 'Merseyside Red', sport: 'Football', style: 'Classic', primaryColor: 0xFFB91C1C, secondaryColor: 0xFFB91C1C, accentColor: 0xFFFDE047, shieldId: 'english', divisionId: 'solid', emblemPath: _eaglePath, templateId: 'football_short', collarId: 'v_neck', patternId: 'stripes_thin', topBanner: 'ANFIELD SC', bottomBanner: 'YNWA'),
    const KitPresetData(id: 'preset_8', name: 'Sky Blue Citizens', sport: 'Football', style: 'Modern', primaryColor: 0xFF38BDF8, secondaryColor: 0xFFFFFFFF, accentColor: 0xFF0F172A, shieldId: 'round_badge', divisionId: 'per_fess', emblemPath: _anchorPath, templateId: 'football_short', collarId: 'crew', patternId: 'ocean_wave', topBanner: 'MANCHESTER', bottomBanner: '1894'),
    const KitPresetData(id: 'preset_9', name: 'Bavaria Diamonds', sport: 'Football', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFF1D4ED8, accentColor: 0xFFFFFFFF, shieldId: 'round_badge', divisionId: 'fusilly_6', emblemPath: _lionPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'harlequin', topBanner: 'FC MUNCHEN', bottomBanner: '1900'),
    const KitPresetData(id: 'preset_10', name: 'Westfalen Yellow Wall', sport: 'Football', style: 'Modern', primaryColor: 0xFFFACC15, secondaryColor: 0xFF0F172A, accentColor: 0xFF0F172A, shieldId: 'round_badge', divisionId: 'per_bend', emblemPath: _lionPath, templateId: 'football_raglan', collarId: 'crew', patternId: 'lightning_bolts', topBanner: 'BORUSSIA', bottomBanner: '09'),
    const KitPresetData(id: 'preset_11', name: 'Parisian Hechter', sport: 'Football', style: 'Modern', primaryColor: 0xFF1E3A8A, secondaryColor: 0xFFDC2626, accentColor: 0xFFFFFFFF, shieldId: 'round_badge', divisionId: 'tierced_pale', emblemPath: _starPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'stripes_center_band', topBanner: 'PARIS SG', bottomBanner: '1970'),
    const KitPresetData(id: 'preset_12', name: 'Amsterdam Pillar', sport: 'Football', style: 'Classic', primaryColor: 0xFFFFFFFF, secondaryColor: 0xFFDC2626, accentColor: 0xFFD4AF37, shieldId: 'round_badge', divisionId: 'tierced_pale', emblemPath: _crownPath, templateId: 'football_short', collarId: 'polo', patternId: 'stripes_center_band', topBanner: 'AJAX AMSTERDAM', bottomBanner: 'XXX'),
    const KitPresetData(id: 'preset_13', name: 'Lisbon Eagles', sport: 'Football', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFD4AF37, shieldId: 'iberian', divisionId: 'per_bend', emblemPath: _eaglePath, templateId: 'football_short', collarId: 'v_neck', patternId: 'solid', topBanner: 'SL LISBOA', bottomBanner: '1904'),
    const KitPresetData(id: 'preset_14', name: 'Porto Dragons', sport: 'Football', style: 'Classic', primaryColor: 0xFF1D4ED8, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFD4AF37, shieldId: 'spanish', divisionId: 'paly_4', emblemPath: _dragonPath, templateId: 'football_short', collarId: 'round', patternId: 'stripes_vertical', topBanner: 'FC DRAGOES', bottomBanner: '1893'),
    const KitPresetData(id: 'preset_15', name: 'Glasgow Emerald Hoops', sport: 'Football', style: 'Classic', primaryColor: 0xFF16A34A, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFD4AF37, shieldId: 'round_badge', divisionId: 'barry_6', emblemPath: _starPath, templateId: 'football_short', collarId: 'polo', patternId: 'hoops_horizontal', topBanner: 'CELTIC GLASGOW', bottomBanner: '1888'),
    const KitPresetData(id: 'preset_16', name: 'Buenos Aires Gold Band', sport: 'Football', style: 'Classic', primaryColor: 0xFF1E3A8A, secondaryColor: 0xFFFACC15, accentColor: 0xFFFACC15, shieldId: 'swiss', divisionId: 'per_fess', emblemPath: _starPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'chest_band', topBanner: 'CABJ BOCA', bottomBanner: '1905'),
    const KitPresetData(id: 'preset_17', name: 'Millionaire Red Sash', sport: 'Football', style: 'Classic', primaryColor: 0xFFFFFFFF, secondaryColor: 0xFFDC2626, accentColor: 0xFF0F172A, shieldId: 'heater', divisionId: 'bend_sash', emblemPath: _lionPath, templateId: 'football_short', collarId: 'polo', patternId: 'sash_right', topBanner: 'RIVER PLATE', bottomBanner: '1901'),
    const KitPresetData(id: 'preset_18', name: 'Rio Mengao Hoops', sport: 'Football', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFF0F172A, accentColor: 0xFFFFFFFF, shieldId: 'spanish', divisionId: 'barry_6', emblemPath: _anchorPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'hoops_horizontal', topBanner: 'CR FLAMENGO', bottomBanner: '1895'),
    const KitPresetData(id: 'preset_19', name: 'Algiers Desert Greens', sport: 'Football', style: 'Modern', primaryColor: 0xFF10B981, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFDC2626, shieldId: 'round_badge', divisionId: 'per_pale', emblemPath: _starPath, templateId: 'football_raglan', collarId: 'mandarin', patternId: 'sublimation_geo_1', topBanner: 'EL KHADRA', bottomBanner: '1962'),
    const KitPresetData(id: 'preset_20', name: 'Oran Lions Red-White', sport: 'Football', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFD4AF37, shieldId: 'french', divisionId: 'paly_4', emblemPath: _lionPath, templateId: 'football_short', collarId: 'v_neck', patternId: 'stripes_vertical', topBanner: 'MC ORAN', bottomBanner: '1946'),
    const KitPresetData(id: 'preset_21', name: '90s Bruised Banana Retro', sport: 'Football', style: 'Retro', primaryColor: 0xFFFACC15, secondaryColor: 0xFF1E3A8A, accentColor: 0xFFDC2626, shieldId: 'english', divisionId: 'chevron_double', emblemPath: _eaglePath, templateId: 'football_retro', collarId: 'polo', patternId: 'retro_90s_zigzags', topBanner: 'RETRO 1991', bottomBanner: 'CLASSIC'),
    const KitPresetData(id: 'preset_22', name: '88 Dutch Origami Retro', sport: 'Football', style: 'Retro', primaryColor: 0xFFF97316, secondaryColor: 0xFFFFFFFF, accentColor: 0xFF0F172A, shieldId: 'heater', divisionId: 'chevron_single', emblemPath: _lionPath, templateId: 'football_retro', collarId: 'wrap_v', patternId: 'sublimation_geo_2', topBanner: 'ORANJE 88', bottomBanner: 'CHAMPIONS'),
    const KitPresetData(id: 'preset_23', name: '70s Samba Gold Retro', sport: 'Football', style: 'Retro', primaryColor: 0xFFFDE047, secondaryColor: 0xFF15803D, accentColor: 0xFF1D4ED8, shieldId: 'iberian', divisionId: 'cross_st_george', emblemPath: _starPath, templateId: 'football_retro', collarId: 'crew', patternId: 'solid', topBanner: 'BRASIL 1970', bottomBanner: 'TRICAMPEAO'),
    const KitPresetData(id: 'preset_24', name: '94 Campos Harlequin GK', sport: 'Football', style: 'Retro', primaryColor: 0xFFEC4899, secondaryColor: 0xFF00E5A3, accentColor: 0xFFFACC15, shieldId: 'lozenge', divisionId: 'lozengy_4', emblemPath: _eaglePath, templateId: 'football_gk_long', collarId: 'crew', patternId: 'harlequin', topBanner: 'ACAPULCO 94', bottomBanner: 'NUMBER 1'),
    const KitPresetData(id: 'preset_25', name: 'LA Gold Hardwood', sport: 'Basketball', style: 'Classic', primaryColor: 0xFFF59E0B, secondaryColor: 0xFF581C87, accentColor: 0xFFFFFFFF, shieldId: 'round_badge', divisionId: 'per_bend', emblemPath: _crownPath, templateId: 'basketball_tank', collarId: 'round', patternId: 'solid', topBanner: 'ANGELES HOOPS', bottomBanner: 'SHOWTIME'),
    const KitPresetData(id: 'preset_26', name: 'Windy City Bulls 96', sport: 'Basketball', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFF0F172A, accentColor: 0xFFFFFFFF, shieldId: 'diamond_wide', divisionId: 'per_fess', emblemPath: _bullPath, templateId: 'basketball_tank', collarId: 'v_neck', patternId: 'stripes_thin', topBanner: 'CHICAGO 23', bottomBanner: 'DYNASTY'),
    const KitPresetData(id: 'preset_27', name: 'South Beach Vice Neon', sport: 'Basketball', style: 'Modern', primaryColor: 0xFF0F172A, secondaryColor: 0xFF06B6D4, accentColor: 0xFFEC4899, shieldId: 'round_badge', divisionId: 'per_bend_sinister', emblemPath: _starPath, templateId: 'basketball_wide', collarId: 'v_neck', patternId: 'retro_70s_waves', topBanner: 'MIAMI VICE', bottomBanner: '305'),
    const KitPresetData(id: 'preset_28', name: 'Celtics Parquet Green', sport: 'Basketball', style: 'Classic', primaryColor: 0xFF15803D, secondaryColor: 0xFFFFFFFF, accentColor: 0xFFD4AF37, shieldId: 'round_badge', divisionId: 'quartered', emblemPath: _crownPath, templateId: 'basketball_retro', collarId: 'round', patternId: 'solid', topBanner: 'BOSTON', bottomBanner: 'BANNER 18'),
    const KitPresetData(id: 'preset_29', name: 'All Blacks Silver Fern', sport: 'Rugby', style: 'Classic', primaryColor: 0xFF090D16, secondaryColor: 0xFFFFFFFF, accentColor: 0xFF94A3B8, shieldId: 'norman', divisionId: 'solid', emblemPath: _eaglePath, templateId: 'rugby_pro', collarId: 'polo', patternId: 'carbon_fiber', topBanner: 'AOTEAROA XV', bottomBanner: '1884'),
    const KitPresetData(id: 'preset_30', name: 'Springboks Green & Gold', sport: 'Rugby', style: 'Classic', primaryColor: 0xFF065F46, secondaryColor: 0xFFF59E0B, accentColor: 0xFFFFFFFF, shieldId: 'heater', divisionId: 'per_fess', emblemPath: _lionPath, templateId: 'rugby_heritage', collarId: 'button_polo', patternId: 'hoops_wide', topBanner: 'BOKKE RUGBY', bottomBanner: 'CHAMPS'),
    const KitPresetData(id: 'preset_31', name: 'Harlequins Quarters', sport: 'Rugby', style: 'Retro', primaryColor: 0xFF7C2D12, secondaryColor: 0xFF38BDF8, accentColor: 0xFFFACC15, shieldId: 'french', divisionId: 'quartered', emblemPath: _crownPath, templateId: 'rugby_pro', collarId: 'polo', patternId: 'quartered_kit', topBanner: 'TWICKENHAM', bottomBanner: '1866'),
    const KitPresetData(id: 'preset_32', name: 'Mumbai T20 Blue Gold', sport: 'Cricket', style: 'Modern', primaryColor: 0xFF1E40AF, secondaryColor: 0xFFD4AF37, accentColor: 0xFF38BDF8, shieldId: 'octagon_badge', divisionId: 'chevron_single', emblemPath: _lionPath, templateId: 'cricket_t20', collarId: 'button_polo', patternId: 'sublimation_geo_6', topBanner: 'MUMBAI XI', bottomBanner: 'T20 CHAMPIONS'),
    const KitPresetData(id: 'preset_33', name: 'Lords Test Whites', sport: 'Cricket', style: 'Classic', primaryColor: 0xFFF8FAFC, secondaryColor: 0xFF1E3A8A, accentColor: 0xFF991B1B, shieldId: 'english', divisionId: 'three_lions', emblemPath: _lionPath, templateId: 'cricket_test', collarId: 'deep_v', patternId: 'solid', topBanner: 'TEST XI', bottomBanner: '1877'),
    const KitPresetData(id: 'preset_34', name: 'Cyber Wolves Esports', sport: 'Esports', style: 'Esports', primaryColor: 0xFF0F172A, secondaryColor: 0xFF00E5A3, accentColor: 0xFF38BDF8, shieldId: 'esports_viper', divisionId: 'pile', emblemPath: _wolfPath, templateId: 'esports_zipped', collarId: 'zipped', patternId: 'hex_mesh', topBanner: 'APEX WOLVES', bottomBanner: 'ESPORTS'),
    const KitPresetData(id: 'preset_35', name: 'Valkyrie Mecha Gaming', sport: 'Esports', style: 'Esports', primaryColor: 0xFF31102F, secondaryColor: 0xFFF43F5E, accentColor: 0xFFFACC15, shieldId: 'esports_mecha', divisionId: 'pall', emblemPath: _dragonPath, templateId: 'esports_hoodie', collarId: 'hood', patternId: 'circuit_board', topBanner: 'VALKYRIE GG', bottomBanner: 'WORLD FINALS'),
    const KitPresetData(id: 'preset_36', name: 'Shogunate Samurai GG', sport: 'Esports', style: 'Esports', primaryColor: 0xFF111827, secondaryColor: 0xFFDC2626, accentColor: 0xFFFFFFFF, shieldId: 'esports_aegis', divisionId: 'per_bend', emblemPath: _dragonPath, templateId: 'esports_zipped', collarId: 'mandarin', patternId: 'brush_stroke', topBanner: 'SHOGUN CLAN', bottomBanner: 'TOKYO'),
    const KitPresetData(id: 'preset_37', name: 'Montreal Bleu-Blanc-Rouge', sport: 'Hockey', style: 'Classic', primaryColor: 0xFFDC2626, secondaryColor: 0xFF1D4ED8, accentColor: 0xFFFFFFFF, shieldId: 'oval_horizontal', divisionId: 'per_fess', emblemPath: _starPath, templateId: 'hockey_ice', collarId: 'laced', patternId: 'chest_band', topBanner: 'HABITANTS HC', bottomBanner: '1909'),
    const KitPresetData(id: 'preset_38', name: 'Nordic Ice Bears', sport: 'Hockey', style: 'Modern', primaryColor: 0xFF0C4A6E, secondaryColor: 0xFF38BDF8, accentColor: 0xFFFFFFFF, shieldId: 'hexagon_badge', divisionId: 'cross_nordic', emblemPath: _wolfPath, templateId: 'hockey_ice', collarId: 'laced', patternId: 'sublimation_geo_8', topBanner: 'POLAR HC', bottomBanner: 'ARCTIC'),
    const KitPresetData(id: 'preset_39', name: 'Bronx Pinstripe Nine', sport: 'Baseball', style: 'Classic', primaryColor: 0xFFFFFFFF, secondaryColor: 0xFF0F172A, accentColor: 0xFFDC2626, shieldId: 'diamond_wide', divisionId: 'paly_6', emblemPath: _starPath, templateId: 'baseball_button', collarId: 'collarless', patternId: 'stripes_thin', topBanner: 'EMPIRE NINE', bottomBanner: '1903'),
    const KitPresetData(id: 'preset_40', name: 'Tour Maillot Jaune', sport: 'Cycling', style: 'Modern', primaryColor: 0xFFFACC15, secondaryColor: 0xFF0F172A, accentColor: 0xFFFFFFFF, shieldId: 'hexagon_flat', divisionId: 'chevron_single', emblemPath: _eaglePath, templateId: 'cycling_zip', collarId: 'zipped', patternId: 'sublimation_geo_5', topBanner: 'ALPE VELO', bottomBanner: 'PRO TOUR'),
    const KitPresetData(id: 'preset_41', name: 'Gridiron Lone Star', sport: 'Gridiron', style: 'Classic', primaryColor: 0xFF1E3A8A, secondaryColor: 0xFF94A3B8, accentColor: 0xFFFFFFFF, shieldId: 'pentagon_badge', divisionId: 'per_pale', emblemPath: _starPath, templateId: 'am_football_gridiron', collarId: 'v_neck', patternId: 'solid', topBanner: 'DALLAS GRID', bottomBanner: 'BOWL CHAMPS'),
    const KitPresetData(id: 'preset_42', name: 'Copacabana Court', sport: 'Volleyball', style: 'Modern', primaryColor: 0xFF00E5A3, secondaryColor: 0xFF0F172A, accentColor: 0xFFFACC15, shieldId: 'round_badge', divisionId: 'gyronny', emblemPath: _starPath, templateId: 'volleyball_pro', collarId: 'v_neck', patternId: 'ocean_wave', topBanner: 'RIO VOLLEY', bottomBanner: 'GOLD'),
  ];
}
