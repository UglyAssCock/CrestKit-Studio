import 'dart:math' as math;

class ShieldAsset {
  final String id;
  final String name;
  final String category;
  final String path;

  const ShieldAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.path,
  });
}

class ShieldLibrary {
  static String _polygonPath(int sides, double radius, {double rotDeg = -90}) {
    final sb = StringBuffer();
    for (int i = 0; i < sides; i++) {
      final angle = (rotDeg + (360.0 / sides) * i) * math.pi / 180.0;
      final x = 50.0 + radius * math.cos(angle);
      final y = 50.0 + radius * math.sin(angle);
      sb.write('${i == 0 ? 'M' : 'L'} ${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} ');
    }
    sb.write('Z');
    return sb.toString();
  }

  static String _starBadgePath(int points, double outerR, double innerR) {
    final sb = StringBuffer();
    final total = points * 2;
    for (int i = 0; i < total; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (-90.0 + (360.0 / total) * i) * math.pi / 180.0;
      final x = 50.0 + r * math.cos(angle);
      final y = 50.0 + r * math.sin(angle);
      sb.write('${i == 0 ? 'M' : 'L'} ${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} ');
    }
    sb.write('Z');
    return sb.toString();
  }

  static final List<ShieldAsset> all = [
    const ShieldAsset(
      id: 'heater',
      name: 'Classic Heater',
      category: 'Heraldic',
      path: 'M 14 10 L 86 10 L 86 46 Q 86 78 50 94 Q 14 78 14 46 Z',
    ),
    const ShieldAsset(
      id: 'french',
      name: 'French Modern',
      category: 'Heraldic',
      path: 'M 14 10 L 86 10 L 86 64 Q 86 84 62 84 Q 54 84 50 94 Q 46 84 38 84 Q 14 84 14 64 Z',
    ),
    const ShieldAsset(
      id: 'spanish',
      name: 'Spanish Round Base',
      category: 'Heraldic',
      path: 'M 14 10 L 86 10 L 86 56 A 36 36 0 0 1 14 56 Z',
    ),
    const ShieldAsset(
      id: 'english',
      name: 'English Eared',
      category: 'Heraldic',
      path: 'M 10 14 L 18 10 L 82 10 L 90 14 L 84 22 L 84 50 Q 84 80 50 94 Q 16 80 16 50 L 16 22 Z',
    ),
    const ShieldAsset(
      id: 'german',
      name: 'German Tartsche',
      category: 'Heraldic',
      path: 'M 20 10 Q 50 16 80 10 Q 90 30 82 48 Q 88 74 50 92 Q 12 74 18 48 Q 10 30 20 10 Z',
    ),
    const ShieldAsset(
      id: 'italian',
      name: 'Italian Horsehead',
      category: 'Heraldic',
      path: 'M 30 8 L 70 8 L 88 24 L 78 44 L 86 64 L 50 94 L 14 64 L 22 44 L 12 24 Z',
    ),
    const ShieldAsset(
      id: 'swiss',
      name: 'Swiss Triple Peak',
      category: 'Heraldic',
      path: 'M 14 16 Q 32 8 50 16 Q 68 8 86 16 L 86 50 Q 86 82 50 94 Q 14 82 14 50 Z',
    ),
    const ShieldAsset(
      id: 'polish',
      name: 'Polish Renaissance',
      category: 'Heraldic',
      path: 'M 16 14 Q 34 6 50 14 Q 66 6 84 14 L 88 36 L 82 62 Q 76 84 50 94 Q 24 84 18 62 L 12 36 Z',
    ),
    const ShieldAsset(
      id: 'norman',
      name: 'Norman Kite',
      category: 'Heraldic',
      path: 'M 20 16 A 30 14 0 0 1 80 16 Q 82 58 50 95 Q 18 58 20 16 Z',
    ),
    const ShieldAsset(
      id: 'iberian',
      name: 'Iberian Crest',
      category: 'Heraldic',
      path: 'M 14 12 L 50 6 L 86 12 L 86 58 Q 86 86 50 92 Q 14 86 14 58 Z',
    ),
    const ShieldAsset(
      id: 'gothic',
      name: 'Gothic Pointed',
      category: 'Heraldic',
      path: 'M 14 10 L 86 10 Q 88 58 50 95 Q 12 58 14 10 Z',
    ),
    const ShieldAsset(
      id: 'kite',
      name: 'Crusader Kite',
      category: 'Heraldic',
      path: 'M 22 8 L 78 8 L 84 36 L 50 95 L 16 36 Z',
    ),
    const ShieldAsset(
      id: 'pointed_crest',
      name: 'Pointed Top & Base',
      category: 'Heraldic',
      path: 'M 50 6 L 86 18 L 86 54 Q 86 82 50 94 Q 14 82 14 54 L 14 18 Z',
    ),
    const ShieldAsset(
      id: 'curved_top',
      name: 'Curved Dome Shield',
      category: 'Heraldic',
      path: 'M 14 22 Q 50 4 86 22 L 86 54 Q 86 82 50 94 Q 14 82 14 54 Z',
    ),
    const ShieldAsset(
      id: 'flat_top',
      name: 'Flat Top Angular',
      category: 'Modern',
      path: 'M 14 10 L 86 10 L 86 62 L 50 94 L 14 62 Z',
    ),
    const ShieldAsset(
      id: 'notched',
      name: 'Notched Corner',
      category: 'Modern',
      path: 'M 22 10 L 78 10 L 88 20 L 88 58 L 50 94 L 12 58 L 12 20 Z',
    ),
    const ShieldAsset(
      id: 'scalloped',
      name: 'Scalloped Crown',
      category: 'Heraldic',
      path: 'M 14 16 Q 26 24 38 12 Q 50 24 62 12 Q 74 24 86 16 L 86 54 Q 86 82 50 94 Q 14 82 14 54 Z',
    ),
    const ShieldAsset(
      id: 'split_modern',
      name: 'Modern Split Shield',
      category: 'Modern',
      path: 'M 14 12 L 47 8 L 47 92 L 14 62 Z M 53 8 L 86 12 L 86 62 L 53 92 Z',
    ),
    const ShieldAsset(
      id: 'banner_top',
      name: 'Banner Header Shield',
      category: 'Modern',
      path: 'M 10 10 L 90 10 L 84 26 L 84 56 Q 84 82 50 94 Q 16 82 16 56 L 16 26 Z',
    ),
    const ShieldAsset(
      id: 'ribbon_top',
      name: 'Ribbon Arch Shield',
      category: 'Modern',
      path: 'M 12 18 Q 50 6 88 18 L 84 58 Q 84 82 50 94 Q 16 82 16 58 Z',
    ),
    const ShieldAsset(
      id: 'pennant',
      name: 'Triangular Pennant',
      category: 'Classic',
      path: 'M 16 8 L 84 8 L 50 95 Z',
    ),
    const ShieldAsset(
      id: 'pennant_notched',
      name: 'Swallowtail Pennant',
      category: 'Classic',
      path: 'M 16 8 L 84 8 L 84 68 L 50 94 L 16 68 Z',
    ),
    const ShieldAsset(
      id: 'crown_top',
      name: 'Royal Crown Shield',
      category: 'Heraldic',
      path: 'M 14 20 L 28 8 L 40 18 L 50 6 L 60 18 L 72 8 L 86 20 L 86 56 Q 86 82 50 94 Q 14 82 14 56 Z',
    ),
    const ShieldAsset(
      id: 'wing_top',
      name: 'Winged Esports Shield',
      category: 'Esports',
      path: 'M 6 14 L 34 18 L 50 8 L 66 18 L 94 14 L 84 56 L 50 94 L 16 56 Z',
    ),
    const ShieldAsset(
      id: 'round_badge',
      name: 'Circle Badge',
      category: 'Badges',
      path: 'M 50 8 A 42 42 0 1 0 50 92 A 42 42 0 1 0 50 8 Z',
    ),
    const ShieldAsset(
      id: 'double_circle',
      name: 'Double Ring Badge',
      category: 'Badges',
      path: 'M 50 6 A 44 44 0 1 0 50 94 A 44 44 0 1 0 50 6 Z M 50 16 A 34 34 0 1 0 50 84 A 34 34 0 1 0 50 16 Z',
    ),
    const ShieldAsset(
      id: 'oval_vertical',
      name: 'Classic Oval',
      category: 'Badges',
      path: 'M 50 6 A 32 44 0 1 0 50 94 A 32 44 0 1 0 50 6 Z',
    ),
    const ShieldAsset(
      id: 'oval_horizontal',
      name: 'Wide Stadium Oval',
      category: 'Badges',
      path: 'M 50 18 A 44 32 0 1 0 50 82 A 44 32 0 1 0 50 18 Z',
    ),
    const ShieldAsset(
      id: 'lozenge',
      name: 'Heraldic Lozenge',
      category: 'Geometric',
      path: 'M 50 6 L 86 50 L 50 94 L 14 50 Z',
    ),
    const ShieldAsset(
      id: 'diamond_wide',
      name: 'Baseball Diamond',
      category: 'Geometric',
      path: 'M 50 8 L 92 50 L 50 92 L 8 50 Z',
    ),
    const ShieldAsset(
      id: 'rounded_square',
      name: 'Fortress Square',
      category: 'Geometric',
      path: 'M 24 10 L 76 10 Q 90 10 90 24 L 90 76 Q 90 90 76 90 L 24 90 Q 10 90 10 76 L 10 24 Q 10 10 24 10 Z',
    ),
    ShieldAsset(
      id: 'pentagon_badge',
      name: 'Pentagon Shield',
      category: 'Geometric',
      path: _polygonPath(5, 43),
    ),
    ShieldAsset(
      id: 'hexagon_badge',
      name: 'Hexagon Core',
      category: 'Geometric',
      path: _polygonPath(6, 43),
    ),
    ShieldAsset(
      id: 'hexagon_flat',
      name: 'Hexagon Flat Top',
      category: 'Geometric',
      path: _polygonPath(6, 43, rotDeg: 0),
    ),
    ShieldAsset(
      id: 'heptagon_badge',
      name: 'Heptagon Vault',
      category: 'Geometric',
      path: _polygonPath(7, 43),
    ),
    ShieldAsset(
      id: 'octagon_badge',
      name: 'Octagon Arena',
      category: 'Geometric',
      path: _polygonPath(8, 43, rotDeg: 22.5),
    ),
    ShieldAsset(
      id: 'decagon_badge',
      name: 'Decagon Seal',
      category: 'Geometric',
      path: _polygonPath(10, 43),
    ),
    ShieldAsset(
      id: 'dodecagon_badge',
      name: '12-Sided Coin',
      category: 'Badges',
      path: _polygonPath(12, 43),
    ),
    ShieldAsset(
      id: 'star_badge_8',
      name: '8-Point Star Seal',
      category: 'Badges',
      path: _starBadgePath(8, 45, 36),
    ),
    ShieldAsset(
      id: 'star_badge_12',
      name: '12-Point Rosette',
      category: 'Badges',
      path: _starBadgePath(12, 45, 38),
    ),
    ShieldAsset(
      id: 'star_badge_16',
      name: '16-Point Sun Seal',
      category: 'Badges',
      path: _starBadgePath(16, 45, 40),
    ),
    const ShieldAsset(
      id: 'esports_mecha',
      name: 'Mecha Armor Crest',
      category: 'Esports',
      path: 'M 24 8 L 76 8 L 92 26 L 82 64 L 50 94 L 18 64 L 8 26 Z',
    ),
    const ShieldAsset(
      id: 'esports_viper',
      name: 'Viper Fang Shield',
      category: 'Esports',
      path: 'M 14 8 L 50 18 L 86 8 L 90 44 L 68 82 L 50 94 L 32 82 L 10 44 Z',
    ),
    const ShieldAsset(
      id: 'esports_aegis',
      name: 'Aegis Cyber Crest',
      category: 'Esports',
      path: 'M 30 8 L 70 8 L 88 20 L 88 48 L 72 78 L 50 94 L 28 78 L 12 48 L 12 20 Z',
    ),
  ];

  static ShieldAsset byId(String id) {
    return all.firstWhere((e) => e.id == id, orElse: () => all.first);
  }
}
