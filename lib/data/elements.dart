import 'dart:math' as math;

class EmblemAsset {
  final String id;
  final String name;
  final String category;
  final String path;

  const EmblemAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.path,
  });
}

class ElementLibrary {
  static List<EmblemAsset>? _cached;

  static List<EmblemAsset> get all {
    if (_cached != null) return _cached!;
    final items = <EmblemAsset>[
      ..._animals,
      ..._crowns,
      ..._weapons,
      ..._starsAndShapes,
      ..._laurels,
      ..._banners,
      ..._sports,
      ..._esports,
      ..._nature,
      ..._symbols,
      ..._generateVectorGlyphs(),
    ];
    _cached = items;
    return items;
  }

  static List<String> get categories => const [
        'All',
        'Animals',
        'Crowns',
        'Weapons',
        'Stars & Shapes',
        'Laurels',
        'Banners',
        'Sports',
        'Esports',
        'Nature',
        'Letters & Digits',
        'Symbols',
      ];

  static String _starPath(int points, double outerR, double innerR) {
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

  static String _polygonPath(int sides, double radius, {double rot = -90}) {
    final sb = StringBuffer();
    for (int i = 0; i < sides; i++) {
      final a = (rot + (360.0 / sides) * i) * math.pi / 180.0;
      final x = 50.0 + radius * math.cos(a);
      final y = 50.0 + radius * math.sin(a);
      sb.write('${i == 0 ? 'M' : 'L'} ${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)} ');
    }
    sb.write('Z');
    return sb.toString();
  }

  static String _wreathLeaves(int pairs, double radius, bool closedTop) {
    final sb = StringBuffer();
    for (int i = 0; i < pairs; i++) {
      final t = i / (pairs - 1);
      final startAngle = 100.0;
      final endAngle = closedTop ? 260.0 : 240.0;
      final deg = startAngle + (endAngle - startAngle) * t;
      final radL = deg * math.pi / 180.0;
      final lx = 50.0 + radius * math.cos(radL);
      final ly = 50.0 + radius * math.sin(radL);
      sb.write(
          'M ${lx.toStringAsFixed(1)} ${ly.toStringAsFixed(1)} Q ${(lx - 7).toStringAsFixed(1)} ${(ly - 5).toStringAsFixed(1)} ${(lx - 2).toStringAsFixed(1)} ${(ly - 12).toStringAsFixed(1)} Q ${(lx + 5).toStringAsFixed(1)} ${(ly - 5).toStringAsFixed(1)} ${lx.toStringAsFixed(1)} ${ly.toStringAsFixed(1)} Z ');
      final rx = 100.0 - lx;
      sb.write(
          'M ${rx.toStringAsFixed(1)} ${ly.toStringAsFixed(1)} Q ${(rx + 7).toStringAsFixed(1)} ${(ly - 5).toStringAsFixed(1)} ${(rx + 2).toStringAsFixed(1)} ${(ly - 12).toStringAsFixed(1)} Q ${(rx - 5).toStringAsFixed(1)} ${(ly - 5).toStringAsFixed(1)} ${rx.toStringAsFixed(1)} ${ly.toStringAsFixed(1)} Z ');
    }
    sb.write('M 36 86 Q 50 78 64 86 L 60 92 Q 50 84 40 92 Z');
    return sb.toString();
  }

  static final List<EmblemAsset> _animals = [
    const EmblemAsset(id: 'lion_rampant', name: 'Lion Rampant', category: 'Animals', path: 'M 48 12 L 60 18 L 64 30 L 56 38 L 76 34 L 70 46 L 58 48 L 66 64 L 78 86 L 64 88 L 52 68 L 44 68 L 36 88 L 22 86 L 34 62 L 32 42 L 20 38 L 26 26 L 38 30 L 36 18 Z'),
    const EmblemAsset(id: 'lion_head', name: 'Lion Head Roar', category: 'Animals', path: 'M 50 10 L 66 16 L 78 12 L 76 28 L 88 40 L 78 56 L 82 72 L 66 78 L 50 90 L 34 78 L 18 72 L 22 56 L 12 40 L 24 28 L 22 12 L 34 16 Z M 36 42 L 44 46 L 36 50 Z M 64 42 L 56 46 L 64 50 Z'),
    const EmblemAsset(id: 'lion_passant', name: 'Lion Passant', category: 'Animals', path: 'M 16 38 L 28 30 L 36 38 L 68 38 Q 84 26 88 42 L 80 56 L 86 76 L 74 76 L 68 58 L 38 58 L 32 76 L 20 76 L 26 56 L 12 52 Z'),
    const EmblemAsset(id: 'lion_crowned', name: 'Crowned Lion', category: 'Animals', path: 'M 36 18 L 42 8 L 50 16 L 58 8 L 64 18 Z M 50 22 L 68 28 L 78 44 L 70 68 L 50 88 L 30 68 L 22 44 L 32 28 Z'),
    const EmblemAsset(id: 'eagle_spread', name: 'Eagle Wings Spread', category: 'Animals', path: 'M 50 16 L 58 24 L 54 32 L 92 14 L 84 36 L 90 42 L 76 54 L 82 60 L 62 66 L 70 86 L 50 78 L 30 86 L 38 66 L 18 60 L 24 54 L 10 42 L 16 36 L 8 14 L 46 32 L 42 24 Z'),
    const EmblemAsset(id: 'eagle_head', name: 'Eagle Fierce Head', category: 'Animals', path: 'M 22 24 Q 52 12 78 28 Q 90 44 76 62 L 64 54 Q 54 68 82 76 Q 52 88 20 72 L 30 56 L 16 48 Z'),
    const EmblemAsset(id: 'eagle_perched', name: 'Imperial Perched Eagle', category: 'Animals', path: 'M 50 12 L 60 20 L 82 18 L 74 52 L 60 66 L 66 88 L 34 88 L 40 66 L 26 52 L 18 18 L 40 20 Z'),
    const EmblemAsset(id: 'wolf_howl', name: 'Wolf Howling', category: 'Animals', path: 'M 26 14 L 36 30 L 48 16 L 54 32 L 82 40 L 86 50 L 68 58 L 74 86 L 30 86 L 24 52 Z'),
    const EmblemAsset(id: 'wolf_head', name: 'Dire Wolf Fang', category: 'Animals', path: 'M 22 12 L 38 30 L 50 26 L 62 30 L 78 12 L 84 44 L 72 68 L 50 90 L 28 68 L 16 44 Z'),
    const EmblemAsset(id: 'bear_roar', name: 'Grizzly Bear Head', category: 'Animals', path: 'M 24 18 A 10 10 0 1 1 38 24 L 62 24 A 10 10 0 1 1 76 18 L 84 46 L 74 76 L 50 88 L 26 76 L 16 46 Z'),
    const EmblemAsset(id: 'tiger_strike', name: 'Bengal Tiger', category: 'Animals', path: 'M 20 18 L 34 22 L 50 16 L 66 22 L 80 18 L 88 46 L 76 74 L 50 90 L 24 74 L 12 46 Z'),
    const EmblemAsset(id: 'panther_prowl', name: 'Black Panther', category: 'Animals', path: 'M 24 22 L 38 26 L 62 26 L 76 22 L 86 44 L 72 74 L 50 86 L 28 74 L 14 44 Z'),
    const EmblemAsset(id: 'jaguar_fang', name: 'Aztec Jaguar', category: 'Animals', path: 'M 20 20 L 36 28 L 64 28 L 80 20 L 88 48 L 70 82 L 50 90 L 30 82 L 12 48 Z'),
    const EmblemAsset(id: 'bull_charge', name: 'Charging Toro Bull', category: 'Animals', path: 'M 10 14 Q 14 38 32 36 L 68 36 Q 86 38 90 14 Q 96 42 74 52 L 66 84 L 50 90 L 34 84 L 26 52 Q 4 42 10 14 Z'),
    const EmblemAsset(id: 'stallion_rear', name: 'Rearing Stallion', category: 'Animals', path: 'M 54 10 L 68 18 L 62 30 L 76 42 L 64 48 L 58 64 L 70 88 L 30 88 L 36 54 L 24 38 L 38 22 Z'),
    const EmblemAsset(id: 'horse_head', name: 'Knight Chess Horse', category: 'Animals', path: 'M 36 12 L 54 18 L 76 32 L 70 46 L 52 42 L 64 68 L 72 88 L 28 88 L 30 44 L 22 28 Z'),
    const EmblemAsset(id: 'dragon_wyvern', name: 'Heraldic Dragon', category: 'Animals', path: 'M 48 10 L 64 16 L 56 28 L 90 20 L 76 52 L 86 68 L 62 72 L 72 90 L 34 88 L 42 64 L 14 54 L 28 26 Z'),
    const EmblemAsset(id: 'griffin_crest', name: 'Royal Griffin', category: 'Animals', path: 'M 44 12 L 60 18 L 88 14 L 76 46 L 62 56 L 72 88 L 32 88 L 38 56 L 14 38 L 34 26 Z'),
    const EmblemAsset(id: 'phoenix_rise', name: 'Rising Phoenix', category: 'Animals', path: 'M 50 10 L 58 26 L 92 14 L 78 48 L 88 62 L 62 70 L 50 92 L 38 70 L 12 62 L 22 48 L 8 14 L 42 26 Z'),
    const EmblemAsset(id: 'falcon_swoop', name: 'Diving Falcon', category: 'Animals', path: 'M 12 18 L 46 34 L 50 22 L 54 34 L 88 18 L 68 58 L 58 88 L 50 78 L 42 88 L 32 58 Z'),
    const EmblemAsset(id: 'hawk_fierce', name: 'War Hawk', category: 'Animals', path: 'M 18 28 L 50 14 L 82 28 L 72 56 L 84 72 L 50 88 L 16 72 L 28 56 Z'),
    const EmblemAsset(id: 'owl_wise', name: 'Night Owl', category: 'Animals', path: 'M 24 14 L 38 24 L 62 24 L 76 14 L 82 48 L 68 84 L 50 92 L 32 84 L 18 48 Z'),
    const EmblemAsset(id: 'shark_jaws', name: 'Apex Shark', category: 'Animals', path: 'M 50 8 L 76 42 L 92 52 L 72 64 L 78 88 L 50 76 L 22 88 L 28 64 L 8 52 L 24 42 Z'),
    const EmblemAsset(id: 'dolphin_leap', name: 'Leaping Dolphin', category: 'Animals', path: 'M 22 72 Q 18 26 66 16 Q 86 14 88 28 Q 66 32 58 50 L 74 56 L 52 62 Q 42 78 60 88 L 36 86 Z'),
    const EmblemAsset(id: 'cobra_hood', name: 'King Cobra', category: 'Animals', path: 'M 50 10 Q 86 18 82 46 Q 74 64 58 68 L 66 88 L 34 88 L 42 68 Q 26 64 18 46 Q 14 18 50 10 Z'),
    const EmblemAsset(id: 'scorpion_sting', name: 'Desert Scorpion', category: 'Animals', path: 'M 50 8 L 64 16 L 56 28 L 62 42 L 84 30 L 88 46 L 68 56 L 64 84 L 36 84 L 32 56 L 12 46 L 16 30 L 38 42 L 44 28 L 36 16 Z'),
    const EmblemAsset(id: 'fox_clever', name: 'Red Fox Head', category: 'Animals', path: 'M 16 12 L 40 32 L 60 32 L 84 12 L 86 52 L 50 90 L 14 52 Z'),
    const EmblemAsset(id: 'stag_antlers', name: 'Royal Stag Buck', category: 'Animals', path: 'M 14 10 L 24 28 L 16 36 L 36 42 L 40 24 L 30 12 M 86 10 L 76 28 L 84 36 L 64 42 L 60 24 L 70 12 M 34 42 L 66 42 L 60 72 L 50 90 L 40 72 Z'),
    const EmblemAsset(id: 'ram_horns', name: 'Bighorn Ram', category: 'Animals', path: 'M 34 26 Q 8 18 12 48 Q 16 68 34 56 L 42 86 L 58 86 L 66 56 Q 84 68 88 48 Q 92 18 66 26 Z'),
    const EmblemAsset(id: 'boar_tusk', name: 'Wild Boar', category: 'Animals', path: 'M 22 22 L 38 28 L 62 28 L 78 22 L 84 48 L 92 40 L 82 66 L 50 88 L 18 66 L 8 40 L 16 48 Z'),
    const EmblemAsset(id: 'bat_wings', name: 'Valencia Bat', category: 'Animals', path: 'M 42 22 L 46 12 L 50 20 L 54 12 L 58 22 L 94 18 Q 78 44 86 62 Q 66 56 50 86 Q 34 56 14 62 Q 22 44 6 18 Z'),
    const EmblemAsset(id: 'spider_widow', name: 'Black Widow Spider', category: 'Animals', path: 'M 42 32 L 58 32 L 64 58 L 50 76 L 36 58 Z M 14 18 L 40 40 L 10 50 L 40 52 L 16 82 L 44 60 M 86 18 L 60 40 L 90 50 L 60 52 L 84 82 L 56 60'),
    const EmblemAsset(id: 'rooster_crest', name: 'Gallic Rooster', category: 'Animals', path: 'M 46 10 L 56 16 L 62 12 L 60 26 L 72 34 L 58 46 L 86 38 L 74 68 L 54 74 L 58 90 L 38 90 L 42 72 L 26 56 L 38 30 Z'),
    const EmblemAsset(id: 'swan_grace', name: 'Royal Swan', category: 'Animals', path: 'M 38 20 Q 48 8 56 20 Q 56 36 42 48 L 84 36 Q 88 68 62 84 L 24 84 Q 18 64 38 48 Z'),
    const EmblemAsset(id: 'pegasus_wings', name: 'Winged Pegasus', category: 'Animals', path: 'M 48 14 L 62 22 L 92 12 L 76 48 L 64 60 L 70 88 L 32 88 L 36 54 L 10 26 L 40 32 Z'),
    const EmblemAsset(id: 'unicorn_horn', name: 'Heraldic Unicorn', category: 'Animals', path: 'M 50 18 L 78 6 L 60 28 L 76 42 L 62 56 L 68 88 L 32 88 L 36 46 L 24 28 Z'),
    const EmblemAsset(id: 'bison_buffalo', name: 'Thunder Bison', category: 'Animals', path: 'M 14 26 L 26 14 L 34 26 L 66 26 L 74 14 L 86 26 L 82 58 L 64 86 L 36 86 L 18 58 Z'),
    const EmblemAsset(id: 'rhino_horn', name: 'Armored Rhino', category: 'Animals', path: 'M 50 12 L 64 36 L 82 28 L 86 56 L 68 86 L 32 86 L 14 56 L 18 28 L 36 36 Z'),
    const EmblemAsset(id: 'gorilla_kong', name: 'Silverback Gorilla', category: 'Animals', path: 'M 32 14 L 68 14 L 86 38 L 82 72 L 64 88 L 36 88 L 18 72 L 14 38 Z'),
    const EmblemAsset(id: 'bulldog_tough', name: 'British Bulldog', category: 'Animals', path: 'M 20 18 L 36 26 L 64 26 L 80 18 L 88 52 L 76 82 L 50 88 L 24 82 L 12 52 Z'),
  ];

  static final List<EmblemAsset> _crowns = [
    const EmblemAsset(id: 'crown_royal_5', name: '5-Peak Royal Crown', category: 'Crowns', path: 'M 12 72 L 8 28 L 30 48 L 50 18 L 70 48 L 92 28 L 88 72 Z M 12 78 L 88 78 L 88 86 L 12 86 Z'),
    const EmblemAsset(id: 'crown_imperial', name: 'Imperial Arch Crown', category: 'Crowns', path: 'M 16 74 Q 10 30 42 32 L 50 12 L 58 32 Q 90 30 84 74 Z M 16 80 L 84 80 L 84 88 L 16 88 Z'),
    const EmblemAsset(id: 'crown_mural', name: 'Civic Mural Crown', category: 'Crowns', path: 'M 10 32 L 22 32 L 22 42 L 34 42 L 34 32 L 46 32 L 46 42 L 54 42 L 54 32 L 66 32 L 66 42 L 78 42 L 78 32 L 90 32 L 84 76 L 16 76 Z'),
    const EmblemAsset(id: 'crown_3_peak', name: '3-Point Baron Crown', category: 'Crowns', path: 'M 14 74 L 14 26 L 50 52 L 50 18 L 50 52 L 86 26 L 86 74 Z'),
    const EmblemAsset(id: 'crown_fleur', name: 'Fleur-de-Lis Crown', category: 'Crowns', path: 'M 14 76 L 18 36 L 34 52 L 50 16 L 66 52 L 82 36 L 86 76 Z'),
    const EmblemAsset(id: 'crown_eastern', name: 'Radiant Sun Crown', category: 'Crowns', path: 'M 12 76 L 10 38 L 26 56 L 32 24 L 44 52 L 50 14 L 56 52 L 68 24 L 74 56 L 90 38 L 88 76 Z'),
    const EmblemAsset(id: 'crown_naval', name: 'Naval Sail Crown', category: 'Crowns', path: 'M 14 74 L 20 34 L 38 46 L 50 20 L 62 46 L 80 34 L 86 74 Z'),
    const EmblemAsset(id: 'crown_astral', name: 'Astral Wing Crown', category: 'Crowns', path: 'M 8 32 L 34 54 L 50 20 L 66 54 L 92 32 L 82 76 L 18 76 Z'),
    const EmblemAsset(id: 'crown_tiara', name: 'Diamond Tiara', category: 'Crowns', path: 'M 12 72 Q 50 12 88 72 L 82 80 Q 50 34 18 80 Z'),
    const EmblemAsset(id: 'crown_viking', name: 'Nordic Iron Crown', category: 'Crowns', path: 'M 14 72 L 22 30 L 36 58 L 50 24 L 64 58 L 78 30 L 86 72 Z'),
    const EmblemAsset(id: 'crown_laurel', name: 'Crowned Laurel', category: 'Crowns', path: 'M 20 68 L 24 34 L 40 50 L 50 22 L 60 50 L 76 34 L 80 68 Z M 10 78 Q 50 92 90 78 L 86 86 Q 50 98 14 86 Z'),
    const EmblemAsset(id: 'crown_modern_min', name: 'Minimalist Geometric Crown', category: 'Crowns', path: 'M 16 70 L 16 34 L 38 54 L 50 26 L 62 54 L 84 34 L 84 70 Z'),
    const EmblemAsset(id: 'crown_king_chess', name: 'Chess King Cross Crown', category: 'Crowns', path: 'M 46 10 L 54 10 L 54 18 L 62 18 L 62 26 L 54 26 L 54 34 L 82 40 L 76 78 L 24 78 L 18 40 L 46 34 L 46 26 L 38 26 L 38 18 L 46 18 Z'),
    const EmblemAsset(id: 'crown_esports', name: 'Esports Sharp Crown', category: 'Crowns', path: 'M 8 28 L 32 48 L 50 14 L 68 48 L 92 28 L 78 82 L 50 72 L 22 82 Z'),
    const EmblemAsset(id: 'crown_tudor', name: 'Tudor Arch Crown', category: 'Crowns', path: 'M 16 74 C 12 36 44 36 50 20 C 56 36 88 36 84 74 Z'),
  ];

  static final List<EmblemAsset> _weapons = [
    const EmblemAsset(id: 'sword_vertical', name: 'Broad Sword', category: 'Weapons', path: 'M 50 6 L 56 18 L 55 68 L 72 68 L 72 74 L 54 74 L 54 90 L 46 90 L 46 74 L 28 74 L 28 68 L 45 68 L 44 18 Z'),
    const EmblemAsset(id: 'swords_crossed', name: 'Crossed Swords', category: 'Weapons', path: 'M 14 14 L 24 18 L 82 76 L 88 70 L 92 74 L 74 92 L 70 88 L 76 82 L 18 24 Z M 86 14 L 82 24 L 24 82 L 30 88 L 26 92 L 8 74 L 12 70 L 18 76 L 76 18 Z'),
    const EmblemAsset(id: 'axe_battle', name: 'Double Battle Axe', category: 'Weapons', path: 'M 47 10 L 53 10 L 53 90 L 47 90 Z M 47 22 Q 20 10 14 36 Q 20 62 47 50 Z M 53 22 Q 80 10 86 36 Q 80 62 53 50 Z'),
    const EmblemAsset(id: 'axes_crossed', name: 'Crossed Viking Axes', category: 'Weapons', path: 'M 18 18 L 84 84 L 78 90 L 12 24 Z M 82 18 L 16 84 L 22 90 L 88 24 Z M 12 24 Q 6 44 26 48 L 34 32 Z M 88 24 Q 94 44 74 48 L 66 32 Z'),
    const EmblemAsset(id: 'spear_spartan', name: 'Spartan Spear', category: 'Weapons', path: 'M 50 6 L 62 30 L 53 26 L 53 92 L 47 92 L 47 26 L 38 30 Z'),
    const EmblemAsset(id: 'trident_poseidon', name: 'Poseidon Trident', category: 'Weapons', path: 'M 50 8 L 58 22 L 53 22 L 53 46 L 68 46 L 68 24 L 62 24 L 72 12 L 80 26 L 74 26 L 74 54 L 53 54 L 53 92 L 47 92 L 47 54 L 26 54 L 26 26 L 20 26 L 28 12 L 38 24 L 32 24 L 32 46 L 47 46 L 47 22 L 42 22 Z'),
    const EmblemAsset(id: 'arrow_sharp', name: 'Heraldic Arrow', category: 'Weapons', path: 'M 50 8 L 68 32 L 54 28 L 54 76 L 64 88 L 50 82 L 36 88 L 46 76 L 46 28 L 32 32 Z'),
    const EmblemAsset(id: 'arrows_crossed', name: 'Crossed Arrows', category: 'Weapons', path: 'M 14 14 L 32 18 L 26 22 L 86 82 L 82 86 L 22 26 L 18 32 Z M 86 14 L 82 32 L 78 26 L 18 86 L 14 82 L 74 22 L 68 18 Z'),
    const EmblemAsset(id: 'bow_and_arrow', name: 'Longbow & Arrow', category: 'Weapons', path: 'M 28 12 Q 78 50 28 88 L 24 84 Q 68 50 24 16 Z M 14 47 L 86 47 L 74 38 L 92 50 L 74 62 L 86 53 L 14 53 Z'),
    const EmblemAsset(id: 'hammer_thor', name: 'War Hammer', category: 'Weapons', path: 'M 22 16 L 78 16 L 84 38 L 16 38 Z M 45 38 L 55 38 L 55 90 L 45 90 Z'),
    const EmblemAsset(id: 'hammers_crossed', name: 'Crossed Iron Hammers', category: 'Weapons', path: 'M 18 28 L 36 12 L 46 22 L 28 38 Z M 34 30 L 86 82 L 80 88 L 28 36 Z M 82 28 L 64 12 L 54 22 L 72 38 Z M 66 30 L 14 82 L 20 88 L 72 36 Z'),
    const EmblemAsset(id: 'anchor_naval', name: 'Maritime Anchor', category: 'Weapons', path: 'M 50 12 A 8 8 0 1 0 50 28 A 8 8 0 1 0 50 12 Z M 46 28 L 54 28 L 54 36 L 68 36 L 68 42 L 54 42 L 54 76 Q 72 72 78 56 L 86 60 Q 76 86 50 90 Q 24 86 14 60 L 22 56 Q 28 72 46 76 L 46 42 L 32 42 L 32 36 L 46 36 Z'),
    const EmblemAsset(id: 'cannon_artillery', name: 'Artillery Cannon', category: 'Weapons', path: 'M 14 42 L 86 24 L 90 38 L 18 60 Z M 46 58 A 18 18 0 1 0 46 92 A 18 18 0 1 0 46 58 Z'),
    const EmblemAsset(id: 'key_fortress', name: 'Fortress Key', category: 'Weapons', path: 'M 32 28 A 18 18 0 1 0 32 64 A 18 18 0 1 0 32 28 Z M 48 42 L 88 42 L 88 62 L 80 62 L 80 50 L 72 50 L 72 60 L 64 60 L 64 50 L 48 50 Z'),
    const EmblemAsset(id: 'torch_olympic', name: 'Victory Torch', category: 'Weapons', path: 'M 50 8 Q 72 24 62 44 Q 50 32 38 44 Q 28 24 50 8 Z M 34 48 L 66 48 L 56 90 L 44 90 Z'),
    const EmblemAsset(id: 'lightning_bolt', name: 'Thunderbolt Strike', category: 'Weapons', path: 'M 58 8 L 22 54 L 48 54 L 38 92 L 78 44 L 52 44 Z'),
    const EmblemAsset(id: 'halberd_guard', name: 'Royal Halberd', category: 'Weapons', path: 'M 50 6 L 56 26 L 82 18 Q 72 44 82 56 L 54 48 L 54 92 L 46 92 L 46 36 L 26 40 L 34 26 Z'),
    const EmblemAsset(id: 'mace_spiked', name: 'Spiked Flail Mace', category: 'Weapons', path: 'M 50 8 L 58 22 L 74 16 L 66 32 L 80 42 L 64 46 L 68 62 L 54 54 L 54 92 L 46 92 L 46 54 L 32 62 L 36 46 L 20 42 L 34 32 L 26 16 L 42 22 Z'),
    const EmblemAsset(id: 'dagger_blade', name: 'Tactical Dagger', category: 'Weapons', path: 'M 50 10 L 60 36 L 56 64 L 70 64 L 70 72 L 54 72 L 54 90 L 46 90 L 46 72 L 30 72 L 30 64 L 44 64 L 40 36 Z'),
    const EmblemAsset(id: 'shield_crossed_swords', name: 'Shield & Blades', category: 'Weapons', path: 'M 14 14 L 86 86 L 80 92 L 8 20 Z M 86 14 L 14 86 L 20 92 L 92 20 Z M 26 24 L 74 24 L 74 54 Q 74 78 50 88 Q 26 78 26 54 Z'),
  ];

  static final List<EmblemAsset> _starsAndShapes = [
    EmblemAsset(id: 'star_3', name: '3-Point Star', category: 'Stars & Shapes', path: _starPath(3, 44, 18)),
    EmblemAsset(id: 'star_4', name: '4-Point Compass Star', category: 'Stars & Shapes', path: _starPath(4, 44, 16)),
    EmblemAsset(id: 'star_5', name: '5-Point Championship Star', category: 'Stars & Shapes', path: _starPath(5, 44, 18)),
    EmblemAsset(id: 'star_5_fat', name: '5-Point Bold Star', category: 'Stars & Shapes', path: _starPath(5, 44, 25)),
    EmblemAsset(id: 'star_6', name: '6-Point Hexagram Star', category: 'Stars & Shapes', path: _starPath(6, 44, 24)),
    EmblemAsset(id: 'star_7', name: '7-Point Commonwealth Star', category: 'Stars & Shapes', path: _starPath(7, 44, 22)),
    EmblemAsset(id: 'star_8', name: '8-Point Octagram Star', category: 'Stars & Shapes', path: _starPath(8, 44, 22)),
    EmblemAsset(id: 'star_9', name: '9-Point Star', category: 'Stars & Shapes', path: _starPath(9, 44, 24)),
    EmblemAsset(id: 'star_10', name: '10-Point Decagram', category: 'Stars & Shapes', path: _starPath(10, 44, 24)),
    EmblemAsset(id: 'star_12', name: '12-Point Sunburst Star', category: 'Stars & Shapes', path: _starPath(12, 44, 24)),
    EmblemAsset(id: 'star_16_rays', name: '16-Ray Sunburst', category: 'Stars & Shapes', path: _starPath(16, 45, 18)),
    EmblemAsset(id: 'star_24_burst', name: '24-Ray Glory Burst', category: 'Stars & Shapes', path: _starPath(24, 45, 28)),
    const EmblemAsset(id: 'stars_3_arc', name: 'Three Championship Stars', category: 'Stars & Shapes', path: 'M 20 40 L 23 48 L 31 48 L 25 53 L 27 61 L 20 56 L 13 61 L 15 53 L 9 48 L 17 48 Z M 50 24 L 54 34 L 64 34 L 56 40 L 59 50 L 50 44 L 41 50 L 44 40 L 36 34 L 46 34 Z M 80 40 L 83 48 L 91 48 L 85 53 L 87 61 L 80 56 L 73 61 L 75 53 L 69 48 L 77 48 Z'),
    const EmblemAsset(id: 'sparkle_diamond', name: 'Diamond Sparkle', category: 'Stars & Shapes', path: 'M 50 6 Q 50 50 94 50 Q 50 50 50 94 Q 50 50 6 50 Q 50 50 50 6 Z'),
    const EmblemAsset(id: 'heart_heraldic', name: 'Heraldic Heart', category: 'Stars & Shapes', path: 'M 50 30 C 35 6 8 18 12 46 C 16 68 50 88 50 92 C 50 88 84 68 88 46 C 92 18 65 6 50 30 Z'),
    const EmblemAsset(id: 'flame_fire', name: 'Blazing Flame', category: 'Stars & Shapes', path: 'M 52 8 Q 84 36 78 64 A 28 28 0 1 1 22 60 Q 20 38 38 26 Q 34 44 46 46 Q 38 24 52 8 Z'),
    const EmblemAsset(id: 'droplet_water', name: 'Pure Droplet', category: 'Stars & Shapes', path: 'M 50 10 Q 82 50 82 66 A 32 32 0 1 1 18 66 Q 18 50 50 10 Z'),
    const EmblemAsset(id: 'crescent_moon', name: 'Crescent Moon', category: 'Stars & Shapes', path: 'M 64 12 A 40 40 0 1 0 64 88 A 32 36 0 1 1 64 12 Z'),
    const EmblemAsset(id: 'crescent_star', name: 'Crescent & Star', category: 'Stars & Shapes', path: 'M 58 12 A 38 38 0 1 0 58 88 A 30 34 0 1 1 58 12 Z M 72 36 L 76 46 L 86 46 L 78 52 L 81 62 L 72 56 L 63 62 L 66 52 L 58 46 L 68 46 Z'),
    const EmblemAsset(id: 'comet_tail', name: 'Shooting Comet', category: 'Stars & Shapes', path: 'M 74 14 L 80 26 L 92 26 L 82 34 L 86 46 L 74 38 L 62 46 L 66 34 L 56 26 L 68 26 Z M 58 42 L 8 88 L 28 56 Z'),
    const EmblemAsset(id: 'infinity_loop', name: 'Infinity Loop', category: 'Stars & Shapes', path: 'M 30 34 A 16 16 0 1 0 30 66 L 70 34 A 16 16 0 1 1 70 66 Z'),
    const EmblemAsset(id: 'chevron_rank_3', name: 'Triple Rank Chevron', category: 'Stars & Shapes', path: 'M 16 42 L 50 16 L 84 42 L 84 52 L 50 26 L 16 52 Z M 16 62 L 50 36 L 84 62 L 84 72 L 50 46 L 16 72 Z M 16 82 L 50 56 L 84 82 L 84 92 L 50 66 L 16 92 Z'),
    EmblemAsset(id: 'poly_triangle', name: 'Equilateral Triangle', category: 'Stars & Shapes', path: _polygonPath(3, 44)),
    EmblemAsset(id: 'poly_pentagon', name: 'Regular Pentagon', category: 'Stars & Shapes', path: _polygonPath(5, 42)),
    EmblemAsset(id: 'poly_hexagon', name: 'Regular Hexagon', category: 'Stars & Shapes', path: _polygonPath(6, 42)),
    EmblemAsset(id: 'poly_octagon', name: 'Regular Octagon', category: 'Stars & Shapes', path: _polygonPath(8, 42)),
    const EmblemAsset(id: 'arrow_up_bold', name: 'Ascent Arrow', category: 'Stars & Shapes', path: 'M 50 10 L 86 48 L 66 48 L 66 90 L 34 90 L 34 48 L 14 48 Z'),
    const EmblemAsset(id: 'cross_plus', name: 'Swiss Bold Cross', category: 'Stars & Shapes', path: 'M 36 12 L 64 12 L 64 36 L 88 36 L 88 64 L 64 64 L 64 88 L 36 88 L 36 64 L 12 64 L 12 36 L 36 36 Z'),
    const EmblemAsset(id: 'ring_hollow', name: 'Champion Ring', category: 'Stars & Shapes', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 24 A 26 26 0 1 0 50 76 A 26 26 0 1 0 50 24 Z'),
    const EmblemAsset(id: 'rays_rising', name: 'Rising Sun Rays', category: 'Stars & Shapes', path: 'M 50 90 L 10 90 L 10 70 Z M 50 90 L 10 46 L 24 30 Z M 50 90 L 38 14 L 62 14 Z M 50 90 L 76 30 L 90 46 Z M 50 90 L 90 70 L 90 90 Z'),
  ];

  static final List<EmblemAsset> _laurels = [
    EmblemAsset(id: 'wreath_classic_10', name: 'Classic 10-Leaf Laurel', category: 'Laurels', path: _wreathLeaves(10, 38, false)),
    EmblemAsset(id: 'wreath_dense_14', name: 'Imperial 14-Leaf Laurel', category: 'Laurels', path: _wreathLeaves(14, 39, false)),
    EmblemAsset(id: 'wreath_closed_16', name: 'Full Closed Wreath', category: 'Laurels', path: _wreathLeaves(16, 40, true)),
    EmblemAsset(id: 'wreath_compact_8', name: 'Compact 8-Leaf Wreath', category: 'Laurels', path: _wreathLeaves(8, 34, false)),
    EmblemAsset(id: 'wreath_wide_12', name: 'Wide Stadium Wreath', category: 'Laurels', path: _wreathLeaves(12, 43, false)),
    const EmblemAsset(id: 'branch_left', name: 'Left Olive Branch', category: 'Laurels', path: 'M 46 88 Q 14 58 28 14 L 34 18 Q 22 56 50 84 Z M 22 64 L 12 52 L 26 54 Z M 20 44 L 12 30 L 26 36 Z M 26 26 L 22 12 L 34 20 Z'),
    const EmblemAsset(id: 'branch_right', name: 'Right Olive Branch', category: 'Laurels', path: 'M 54 88 Q 86 58 72 14 L 66 18 Q 78 56 50 84 Z M 78 64 L 88 52 L 74 54 Z M 80 44 L 88 30 L 74 36 Z M 74 26 L 78 12 L 66 20 Z'),
    const EmblemAsset(id: 'wheat_sheaf', name: 'Golden Wheat Crest', category: 'Laurels', path: 'M 46 14 L 54 14 L 58 56 L 70 88 L 30 88 L 42 56 Z M 30 28 L 44 48 L 24 44 Z M 70 28 L 56 48 L 76 44 Z'),
    const EmblemAsset(id: 'oak_cluster', name: 'Oak Leaf Cluster', category: 'Laurels', path: 'M 50 12 Q 66 18 60 32 Q 74 36 64 50 Q 76 58 60 70 L 54 90 L 46 90 L 40 70 Q 24 58 36 50 Q 26 36 40 32 Q 34 18 50 12 Z'),
    const EmblemAsset(id: 'palm_fronds', name: 'Victory Palm Fronds', category: 'Laurels', path: 'M 50 84 Q 14 66 10 22 Q 34 36 50 76 Q 66 36 90 22 Q 86 66 50 84 Z'),
    const EmblemAsset(id: 'flourish_royal', name: 'Baroque Flourish', category: 'Laurels', path: 'M 8 50 Q 28 24 50 50 Q 72 76 92 50 Q 72 24 50 50 Q 28 76 8 50 Z'),
    const EmblemAsset(id: 'divider_diamond', name: 'Ornamental Divider', category: 'Laurels', path: 'M 8 50 L 38 46 L 50 34 L 62 46 L 92 50 L 62 54 L 50 66 L 38 54 Z'),
    const EmblemAsset(id: 'wings_pair', name: 'Angelic Crest Wings', category: 'Laurels', path: 'M 46 56 L 8 18 L 18 40 L 6 44 L 22 58 L 12 64 L 46 74 Z M 54 56 L 92 18 L 82 40 L 94 44 L 78 58 L 88 64 L 54 74 Z'),
    const EmblemAsset(id: 'scroll_crest', name: 'Heraldic Pedestal Scroll', category: 'Laurels', path: 'M 14 40 Q 50 20 86 40 L 78 64 Q 50 48 22 64 Z'),
    EmblemAsset(id: 'gear_wreath', name: 'Industrial Gear Wreath', category: 'Laurels', path: _wreathLeaves(9, 36, true)),
    EmblemAsset(id: 'laurel_star_top', name: 'Star-Crowned Wreath', category: 'Laurels', path: '${_wreathLeaves(10, 38, false)} M 50 6 L 53 14 L 61 14 L 55 19 L 57 27 L 50 22 L 43 27 L 45 19 L 39 14 L 47 14 Z'),
    EmblemAsset(id: 'laurel_inner_ring', name: 'Ringed Medallion Wreath', category: 'Laurels', path: '${_wreathLeaves(12, 41, false)} M 50 22 A 28 28 0 1 0 50 78 A 28 28 0 1 0 50 22 Z'),
    const EmblemAsset(id: 'ribbon_tie', name: 'Bottom Wreath Bow', category: 'Laurels', path: 'M 32 42 L 50 52 L 68 42 L 64 62 L 78 88 L 62 88 L 50 64 L 38 88 L 22 88 L 36 62 Z'),
    const EmblemAsset(id: 'acanthus_leaf', name: 'Acanthus Mantle', category: 'Laurels', path: 'M 14 26 Q 32 8 50 26 Q 68 8 86 26 Q 94 56 72 78 L 50 64 L 28 78 Q 6 56 14 26 Z'),
    const EmblemAsset(id: 'feathers_3', name: 'Prince Three Feathers', category: 'Laurels', path: 'M 50 12 Q 62 38 54 84 L 46 84 Q 38 38 50 12 Z M 24 22 Q 42 42 42 84 L 34 84 Q 16 48 24 22 Z M 76 22 Q 84 48 66 84 L 58 84 Q 58 42 76 22 Z'),
  ];

  static final List<EmblemAsset> _banners = [
    const EmblemAsset(id: 'banner_arc_up', name: 'Arch Up Ribbon', category: 'Banners', path: 'M 6 62 Q 50 32 94 62 L 88 80 Q 50 52 12 80 Z'),
    const EmblemAsset(id: 'banner_arc_down', name: 'Curved Smile Banner', category: 'Banners', path: 'M 6 38 Q 50 68 94 38 L 88 58 Q 50 86 12 58 Z'),
    const EmblemAsset(id: 'banner_flat', name: 'Classic Flat Scroll', category: 'Banners', path: 'M 6 38 L 94 38 L 86 50 L 94 62 L 6 62 L 14 50 Z'),
    const EmblemAsset(id: 'banner_wave', name: 'Wave Dynamic Ribbon', category: 'Banners', path: 'M 6 44 Q 28 26 50 44 Q 72 62 94 44 L 90 64 Q 72 82 50 64 Q 28 46 10 64 Z'),
    const EmblemAsset(id: 'banner_folded_up', name: 'Folded Tail Arch', category: 'Banners', path: 'M 4 68 L 18 54 L 18 42 Q 50 24 82 42 L 82 54 L 96 68 L 76 68 L 76 58 Q 50 42 24 58 L 24 68 Z'),
    const EmblemAsset(id: 'banner_folded_down', name: 'Folded Tail Smile', category: 'Banners', path: 'M 4 32 L 18 46 L 18 58 Q 50 76 82 58 L 82 46 L 96 32 L 76 32 L 76 42 Q 50 58 24 42 L 24 32 Z'),
    const EmblemAsset(id: 'banner_hex', name: 'Hexagonal Plate Banner', category: 'Banners', path: 'M 16 36 L 84 36 L 94 50 L 84 64 L 16 64 L 6 50 Z'),
    const EmblemAsset(id: 'banner_shield_base', name: 'Pedestal Plinth', category: 'Banners', path: 'M 14 38 L 86 38 L 78 66 L 22 66 Z'),
    const EmblemAsset(id: 'banner_double', name: 'Double Stacked Ribbon', category: 'Banners', path: 'M 10 28 L 90 28 L 84 44 L 16 44 Z M 6 54 L 94 54 L 88 72 L 12 72 Z'),
    const EmblemAsset(id: 'banner_chevron_up', name: 'Chevron Peak Banner', category: 'Banners', path: 'M 8 64 L 50 34 L 92 64 L 84 78 L 50 52 L 16 78 Z'),
    const EmblemAsset(id: 'banner_chevron_down', name: 'Chevron V Banner', category: 'Banners', path: 'M 8 36 L 50 66 L 92 36 L 84 52 L 50 82 L 16 52 Z'),
    const EmblemAsset(id: 'banner_swallowtail', name: 'Swallowtail Scroll', category: 'Banners', path: 'M 4 36 L 96 36 L 86 50 L 96 64 L 4 64 L 14 50 Z'),
    const EmblemAsset(id: 'banner_notched', name: 'Notched Plaque', category: 'Banners', path: 'M 14 34 L 86 34 L 92 42 L 92 58 L 86 66 L 14 66 L 8 58 L 8 42 Z'),
    const EmblemAsset(id: 'banner_circle_rocker_top', name: 'Top Rocker Arch', category: 'Banners', path: 'M 10 68 A 44 44 0 0 1 90 68 L 78 76 A 30 30 0 0 0 22 76 Z'),
    const EmblemAsset(id: 'banner_circle_rocker_bot', name: 'Bottom Rocker Arch', category: 'Banners', path: 'M 10 32 A 44 44 0 0 0 90 32 L 78 24 A 30 30 0 0 1 22 24 Z'),
    const EmblemAsset(id: 'banner_esports_slash', name: 'Esports Slash Tag', category: 'Banners', path: 'M 16 36 L 94 36 L 84 64 L 6 64 Z'),
    const EmblemAsset(id: 'banner_esports_wings', name: 'Winged Title Bar', category: 'Banners', path: 'M 4 32 L 24 40 L 76 40 L 96 32 L 86 64 L 14 64 Z'),
    const EmblemAsset(id: 'banner_vintage_label', name: 'Apothecary Label', category: 'Banners', path: 'M 20 30 L 80 30 Q 92 42 92 50 Q 92 58 80 70 L 20 70 Q 8 58 8 50 Q 8 42 20 30 Z'),
    const EmblemAsset(id: 'banner_hanging_flag', name: 'Vertical Gonfalon Flag', category: 'Banners', path: 'M 24 12 L 76 12 L 76 86 L 50 70 L 24 86 Z'),
    const EmblemAsset(id: 'banner_Pennant_R', name: 'Pennant Streamer', category: 'Banners', path: 'M 8 32 L 94 50 L 8 68 L 18 50 Z'),
    const EmblemAsset(id: 'banner_split_center', name: 'Split Center Ribbon', category: 'Banners', path: 'M 6 40 L 46 40 L 46 60 L 6 60 L 14 50 Z M 54 40 L 94 40 L 86 50 L 94 60 L 54 60 Z'),
    const EmblemAsset(id: 'banner_stepped', name: 'Stepped Podium Banner', category: 'Banners', path: 'M 22 34 L 78 34 L 78 44 L 92 44 L 92 64 L 8 64 L 8 44 L 22 44 Z'),
    const EmblemAsset(id: 'banner_crown_bar', name: 'Crowned Nameplate', category: 'Banners', path: 'M 34 34 L 42 22 L 50 32 L 58 22 L 66 34 L 90 34 L 84 62 L 16 62 L 10 34 Z'),
    const EmblemAsset(id: 'banner_arrow_ends', name: 'Arrowhead Bar', category: 'Banners', path: 'M 6 50 L 20 34 L 80 34 L 94 50 L 80 66 L 20 66 Z'),
    const EmblemAsset(id: 'banner_scroll_vertical', name: 'Parchment Scroll', category: 'Banners', path: 'M 24 14 L 76 14 L 72 86 L 28 86 Z'),
  ];

  static final List<EmblemAsset> _sports = [
    const EmblemAsset(id: 'ball_soccer', name: 'Football / Soccer Ball', category: 'Sports', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 32 L 68 44 L 62 64 L 38 64 L 32 44 Z M 50 32 L 50 10 M 68 44 L 88 38 M 62 64 L 76 82 M 38 64 L 24 82 M 32 44 L 12 38'),
    const EmblemAsset(id: 'ball_basketball', name: 'Basketball', category: 'Sports', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 10 50 L 90 50 M 50 10 L 50 90 M 22 22 Q 50 50 22 78 M 78 22 Q 50 50 78 78'),
    const EmblemAsset(id: 'ball_rugby', name: 'Rugby Ball', category: 'Sports', path: 'M 14 86 Q 10 10 86 14 Q 90 90 14 86 Z M 26 74 L 74 26'),
    const EmblemAsset(id: 'ball_am_football', name: 'American Football Gridiron', category: 'Sports', path: 'M 12 88 Q 12 12 88 12 Q 88 88 12 88 Z M 38 62 L 62 38 M 42 50 L 50 58 M 48 44 L 56 52'),
    const EmblemAsset(id: 'ball_cricket', name: 'Cricket Seam Ball', category: 'Sports', path: 'M 50 12 A 38 38 0 1 0 50 88 A 38 38 0 1 0 50 12 Z M 24 24 L 76 76 M 20 30 L 70 80'),
    const EmblemAsset(id: 'ball_baseball', name: 'Baseball Stitched', category: 'Sports', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 22 20 Q 48 50 22 80 M 78 20 Q 52 50 78 80'),
    const EmblemAsset(id: 'ball_tennis', name: 'Tennis Ball', category: 'Sports', path: 'M 50 12 A 38 38 0 1 0 50 88 A 38 38 0 1 0 50 12 Z M 18 32 Q 50 48 18 68 M 82 32 Q 50 48 82 68'),
    const EmblemAsset(id: 'ball_volleyball', name: 'Volleyball Panels', category: 'Sports', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 50 L 50 10 M 50 50 L 86 70 M 50 50 L 14 70'),
    const EmblemAsset(id: 'hockey_sticks', name: 'Crossed Hockey Sticks', category: 'Sports', path: 'M 20 12 L 78 78 Q 88 88 70 90 L 56 88 L 58 78 L 70 80 L 14 18 Z M 80 12 L 22 78 Q 12 88 30 90 L 44 88 L 42 78 L 30 80 L 86 18 Z'),
    const EmblemAsset(id: 'golf_clubs', name: 'Crossed Golf Clubs', category: 'Sports', path: 'M 20 14 L 78 82 L 90 76 L 84 90 L 72 88 L 14 20 Z M 80 14 L 22 82 L 10 76 L 16 90 L 28 88 L 86 20 Z'),
    const EmblemAsset(id: 'boxing_glove', name: 'Boxing Glove', category: 'Sports', path: 'M 32 18 Q 76 14 78 44 Q 80 64 64 68 L 64 88 L 32 88 L 32 68 Q 16 62 18 42 Q 20 28 32 34 Z'),
    const EmblemAsset(id: 'boot_cleat', name: 'Football Studded Boot', category: 'Sports', path: 'M 24 22 L 46 22 L 54 52 L 88 60 L 88 74 L 16 74 L 16 42 Z M 22 74 L 22 82 L 30 82 L 30 74 M 46 74 L 46 82 L 54 82 L 54 74 M 72 74 L 72 82 L 80 82 L 80 74'),
    const EmblemAsset(id: 'trophy_cup_1', name: 'Champions Cup Trophy', category: 'Sports', path: 'M 26 14 L 74 14 L 70 52 Q 70 68 54 70 L 54 82 L 70 82 L 70 90 L 30 90 L 30 82 L 46 82 L 46 70 Q 30 68 30 52 Z M 26 22 L 12 22 Q 12 46 28 46 M 74 22 L 88 22 Q 88 46 72 46'),
    const EmblemAsset(id: 'trophy_globe', name: 'World Globe Trophy', category: 'Sports', path: 'M 50 12 A 22 22 0 1 0 50 56 A 22 22 0 1 0 50 12 Z M 34 52 L 42 78 L 32 88 L 68 88 L 58 78 L 66 52 Z'),
    const EmblemAsset(id: 'trophy_shield_plaque', name: 'Championship Shield Plaque', category: 'Sports', path: 'M 20 12 L 80 12 L 80 56 L 50 88 L 20 56 Z M 32 24 L 68 24 L 68 52 L 50 72 L 32 52 Z'),
    const EmblemAsset(id: 'trophy_bowl', name: 'Silver Salver Bowl', category: 'Sports', path: 'M 14 26 L 86 26 Q 82 64 56 68 L 64 86 L 36 86 L 44 68 Q 18 64 14 26 Z'),
    const EmblemAsset(id: 'trophy_star_pillar', name: 'Star Pillar Award', category: 'Sports', path: 'M 50 10 L 56 26 L 72 26 L 60 36 L 64 52 L 50 42 L 36 52 L 40 36 L 28 26 L 44 26 Z M 40 54 L 60 54 L 66 88 L 34 88 Z'),
    const EmblemAsset(id: 'medal_ribbon', name: 'Gold Winner Medal', category: 'Sports', path: 'M 28 10 L 46 10 L 50 38 L 38 38 Z M 72 10 L 54 10 L 50 38 L 62 38 Z M 50 36 A 26 26 0 1 0 50 88 A 26 26 0 1 0 50 36 Z'),
    const EmblemAsset(id: 'whistle_ref', name: 'Referee Whistle', category: 'Sports', path: 'M 12 38 L 56 38 A 22 22 0 1 1 44 68 L 28 52 L 12 52 Z'),
    const EmblemAsset(id: 'goal_net', name: 'Stadium Goal Posts', category: 'Sports', path: 'M 12 24 L 88 24 L 88 80 L 80 80 L 80 32 L 20 32 L 20 80 L 12 80 Z M 20 48 L 80 48 M 20 64 L 80 64 M 40 32 L 40 80 M 60 32 L 60 80'),
    const EmblemAsset(id: 'corner_flag', name: 'Pitch Corner Flag', category: 'Sports', path: 'M 24 10 L 30 10 L 30 90 L 24 90 Z M 30 12 L 82 28 L 30 44 Z'),
    const EmblemAsset(id: 'cycling_wheel', name: 'Cycling Spoke Wheel', category: 'Sports', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 20 A 30 30 0 1 0 50 80 A 30 30 0 1 0 50 20 Z M 50 20 L 50 80 M 20 50 L 80 50 M 28 28 L 72 72 M 72 28 L 28 72'),
    const EmblemAsset(id: 'helmet_gridiron', name: 'Pro Gridiron Helmet', category: 'Sports', path: 'M 20 56 A 34 34 0 1 1 82 48 L 88 74 L 58 74 L 58 52 L 42 52 L 42 78 L 20 72 Z'),
    const EmblemAsset(id: 'dumbbell_gym', name: 'Heavy Barbell Dumbbell', category: 'Sports', path: 'M 10 32 L 20 32 L 20 68 L 10 68 Z M 22 24 L 32 24 L 32 76 L 22 76 Z M 32 45 L 68 45 L 68 55 L 32 55 Z M 68 24 L 78 24 L 78 76 L 68 76 Z M 80 32 L 90 32 L 90 68 L 80 68 Z'),
    const EmblemAsset(id: 'cricket_wickets', name: 'Cricket Stumps & Bat', category: 'Sports', path: 'M 32 20 L 38 20 L 38 86 L 32 86 Z M 47 20 L 53 20 L 53 86 L 47 86 Z M 62 20 L 68 20 L 68 86 L 62 86 Z M 28 14 L 72 14 L 72 19 L 28 19 Z'),
    const EmblemAsset(id: 'shuttlecock', name: 'Badminton Shuttlecock', category: 'Sports', path: 'M 38 72 A 12 12 0 1 0 62 72 Z M 38 68 L 20 20 L 38 36 L 50 16 L 62 36 L 80 20 L 62 68 Z'),
    const EmblemAsset(id: 'puck_winged', name: 'Winged Hockey Puck', category: 'Sports', path: 'M 30 46 L 70 46 L 70 64 L 30 64 Z M 30 48 L 8 24 L 16 58 L 30 60 Z M 70 48 L 92 24 L 84 58 L 70 60 Z'),
    const EmblemAsset(id: 'stopwatch_race', name: 'Track Stopwatch', category: 'Sports', path: 'M 42 8 L 58 8 L 58 16 L 42 16 Z M 50 20 A 34 34 0 1 0 50 88 A 34 34 0 1 0 50 20 Z M 50 54 L 50 32 M 50 54 L 68 54'),
    const EmblemAsset(id: 'bowling_pins', name: 'Strike Bowling Pin', category: 'Sports', path: 'M 42 14 A 8 8 0 1 1 58 14 L 54 32 Q 70 54 64 86 L 36 86 Q 30 54 46 32 Z'),
    const EmblemAsset(id: 'checkered_flags', name: 'Crossed Racing Flags', category: 'Sports', path: 'M 18 18 L 82 88 L 76 92 L 12 22 Z M 82 18 L 18 88 L 24 92 L 88 22 Z M 18 18 L 48 12 L 58 38 L 28 44 Z M 82 18 L 52 12 L 42 38 L 72 44 Z'),
  ];

  static final List<EmblemAsset> _esports = [
    const EmblemAsset(id: 'esports_gamepad', name: 'Pro Gamepad Controller', category: 'Esports', path: 'M 24 30 L 76 30 Q 92 30 92 54 Q 92 78 76 78 L 62 62 L 38 62 L 24 78 Q 8 78 8 54 Q 8 30 24 30 Z'),
    const EmblemAsset(id: 'esports_headset', name: 'Pro Gaming Headset', category: 'Esports', path: 'M 18 56 L 18 46 A 32 32 0 0 1 82 46 L 82 56 L 90 56 L 90 78 L 74 78 L 74 46 A 24 24 0 0 0 26 46 L 26 78 L 10 78 L 10 56 Z'),
    const EmblemAsset(id: 'esports_crosshair', name: 'Sniper Crosshair', category: 'Esports', path: 'M 50 14 A 36 36 0 1 0 50 86 A 36 36 0 1 0 50 14 Z M 47 4 L 53 4 L 53 26 L 47 26 Z M 47 74 L 53 74 L 53 96 L 47 96 Z M 4 47 L 26 47 L 26 53 L 4 53 Z M 74 47 L 96 47 L 96 53 L 74 53 Z'),
    const EmblemAsset(id: 'esports_skull', name: 'Cyber Skull', category: 'Esports', path: 'M 24 44 A 28 28 0 1 1 76 44 L 72 64 L 64 64 L 64 84 L 36 84 L 36 64 L 28 64 Z M 34 46 L 44 46 L 44 56 L 34 56 Z M 56 46 L 66 46 L 66 56 L 56 56 Z'),
    const EmblemAsset(id: 'esports_spartan', name: 'Spartan Vanguard Helmet', category: 'Esports', path: 'M 50 6 Q 82 14 80 42 L 76 88 L 56 88 L 56 52 L 70 44 L 50 48 L 30 44 L 44 52 L 44 88 L 24 88 L 20 42 Q 18 14 50 6 Z'),
    const EmblemAsset(id: 'esports_ninja', name: 'Shadow Shuriken Star', category: 'Esports', path: 'M 50 6 L 62 38 L 94 50 L 62 62 L 50 94 L 38 62 L 6 50 L 38 38 Z M 50 42 A 8 8 0 1 0 50 58 A 8 8 0 1 0 50 42 Z'),
    const EmblemAsset(id: 'esports_mecha_head', name: 'Mecha Valkyrie Visor', category: 'Esports', path: 'M 50 10 L 66 28 L 90 16 L 78 52 L 86 68 L 50 90 L 14 68 L 22 52 L 10 16 L 34 28 Z'),
    const EmblemAsset(id: 'esports_joystick', name: 'Arcade Stick', category: 'Esports', path: 'M 50 14 A 14 14 0 1 0 50 42 A 14 14 0 1 0 50 14 Z M 46 40 L 54 40 L 54 68 L 82 68 L 88 86 L 12 86 L 18 68 L 46 68 Z'),
    const EmblemAsset(id: 'esports_potion', name: 'Mana Flask', category: 'Esports', path: 'M 40 12 L 60 12 L 60 22 L 56 22 L 56 36 L 82 72 Q 86 88 68 88 L 32 88 Q 14 88 18 72 L 44 36 L 44 22 L 40 22 Z'),
    const EmblemAsset(id: 'esports_mouse', name: 'RGB Gaming Mouse', category: 'Esports', path: 'M 30 34 A 20 20 0 0 1 70 34 L 70 66 A 20 20 0 0 1 30 66 Z M 50 14 L 50 42 M 30 42 L 70 42'),
    const EmblemAsset(id: 'esports_d20', name: 'D20 Icosahedron Die', category: 'Esports', path: 'M 50 8 L 86 28 L 86 72 L 50 92 L 14 72 L 14 28 Z M 50 8 L 50 36 L 86 28 M 50 36 L 14 28 M 50 36 L 74 68 L 26 68 Z'),
    const EmblemAsset(id: 'esports_kunai', name: 'Shinobi Kunai Blade', category: 'Esports', path: 'M 50 8 L 68 48 L 54 56 L 54 74 A 8 8 0 1 1 46 74 L 46 56 L 32 48 Z'),
    const EmblemAsset(id: 'esports_gem', name: 'Rank Master Crystal', category: 'Esports', path: 'M 30 16 L 70 16 L 90 38 L 50 88 L 10 38 Z M 30 16 L 50 38 L 70 16 M 10 38 L 90 38'),
    const EmblemAsset(id: 'esports_samurai', name: 'Kabuto Samurai Crest', category: 'Esports', path: 'M 10 18 L 44 36 L 50 20 L 56 36 L 90 18 L 76 52 L 88 76 L 12 76 L 24 52 Z'),
    const EmblemAsset(id: 'esports_power', name: 'Power Core Icon', category: 'Esports', path: 'M 46 10 L 54 10 L 54 50 L 46 50 Z M 68 22 A 34 34 0 1 1 32 22 L 38 30 A 24 24 0 1 0 62 30 Z'),
  ];

  static final List<EmblemAsset> _nature = [
    const EmblemAsset(id: 'nat_fleur_de_lis', name: 'Royal Fleur-de-Lis', category: 'Nature', path: 'M 50 8 Q 64 28 58 54 Q 76 34 86 48 Q 84 66 62 64 L 82 68 L 82 74 L 58 74 L 64 92 L 50 84 L 36 92 L 42 74 L 18 74 L 18 68 L 38 64 Q 16 66 14 48 Q 24 34 42 54 Q 36 28 50 8 Z'),
    const EmblemAsset(id: 'nat_rose_tudor', name: 'Lancaster / Tudor Rose', category: 'Nature', path: 'M 50 12 Q 68 12 68 30 Q 88 32 82 52 Q 86 72 68 76 Q 50 92 32 76 Q 14 72 18 52 Q 12 32 32 30 Q 32 12 50 12 Z M 50 34 A 16 16 0 1 0 50 66 A 16 16 0 1 0 50 34 Z'),
    const EmblemAsset(id: 'nat_shamrock', name: 'Irish Shamrock Clover', category: 'Nature', path: 'M 50 48 C 30 14 68 14 50 48 C 86 28 86 68 50 48 C 62 76 58 88 46 90 L 44 84 C 52 76 50 62 50 48 C 14 68 14 28 50 48 Z'),
    const EmblemAsset(id: 'nat_maple_leaf', name: 'Canadian Maple Leaf', category: 'Nature', path: 'M 50 8 L 58 28 L 72 22 L 66 42 L 88 38 L 78 54 L 86 62 L 60 66 L 62 76 L 53 74 L 53 92 L 47 92 L 47 74 L 38 76 L 40 66 L 14 62 L 22 54 L 12 38 L 34 42 L 28 22 L 42 28 Z'),
    const EmblemAsset(id: 'nat_thistle', name: 'Scottish Thistle', category: 'Nature', path: 'M 32 16 L 42 26 L 50 14 L 58 26 L 68 16 L 62 42 Q 76 58 56 72 L 56 90 L 44 90 L 44 72 Q 24 58 38 42 Z'),
    const EmblemAsset(id: 'nat_pine_tree', name: 'Alpine Pine Tree', category: 'Nature', path: 'M 50 10 L 72 36 L 60 36 L 78 58 L 64 58 L 84 80 L 56 80 L 56 92 L 44 92 L 44 80 L 16 80 L 36 58 L 22 58 L 40 36 L 28 36 Z'),
    const EmblemAsset(id: 'nat_palm_tree', name: 'Oasis Palm Tree', category: 'Nature', path: 'M 46 42 L 54 42 L 58 90 L 42 90 Z M 50 40 Q 20 20 12 42 Q 30 36 50 40 Q 28 10 46 12 Q 50 26 50 40 Q 72 10 54 12 Q 70 36 88 42 Q 80 20 50 40 Z'),
    const EmblemAsset(id: 'nat_mountains', name: 'Twin Alpine Peaks', category: 'Nature', path: 'M 8 82 L 38 22 L 56 54 L 70 30 L 92 82 Z'),
    const EmblemAsset(id: 'nat_waves', name: 'Oceanic Waves', category: 'Nature', path: 'M 8 44 Q 28 24 50 44 Q 72 64 92 44 L 92 58 Q 72 78 50 58 Q 28 38 8 58 Z M 8 68 Q 28 48 50 68 Q 72 88 92 68 L 92 82 Q 72 102 50 82 Q 28 62 8 82 Z'),
    EmblemAsset(id: 'nat_sun_radiant', name: 'Sol Invictus Sun', category: 'Nature', path: _starPath(16, 44, 26)),
    const EmblemAsset(id: 'nat_snowflake', name: 'Winter Crystal', category: 'Nature', path: 'M 47 8 L 53 8 L 53 92 L 47 92 Z M 12 26 L 88 70 L 84 76 L 8 32 Z M 88 26 L 12 70 L 16 76 L 92 32 Z'),
    const EmblemAsset(id: 'nat_lotus', name: 'Royal Lotus Flower', category: 'Nature', path: 'M 50 18 Q 66 42 50 74 Q 34 42 50 18 Z M 50 74 Q 78 36 84 56 Q 76 76 50 74 Z M 50 74 Q 22 36 16 56 Q 24 76 50 74 Z'),
    const EmblemAsset(id: 'nat_cactus', name: 'Desert Saguaro Cactus', category: 'Nature', path: 'M 44 16 L 56 16 L 56 52 L 68 52 L 68 30 L 78 30 L 78 62 L 56 62 L 56 90 L 44 90 L 44 68 L 22 68 L 22 38 L 32 38 L 32 58 L 44 58 Z'),
    const EmblemAsset(id: 'nat_castle_tower', name: 'Fortress Battlement Tower', category: 'Nature', path: 'M 24 14 L 34 14 L 34 24 L 44 24 L 44 14 L 56 14 L 56 24 L 66 24 L 66 14 L 76 14 L 72 52 L 80 88 L 58 88 L 58 66 L 42 66 L 42 88 L 20 88 L 28 52 Z'),
    const EmblemAsset(id: 'nat_castle_3_towers', name: 'Three-Tower Citadel', category: 'Nature', path: 'M 12 32 L 28 32 L 28 52 L 40 52 L 40 16 L 60 16 L 60 52 L 72 52 L 72 32 L 88 32 L 88 88 L 58 88 L 58 68 L 42 68 L 42 88 L 12 88 Z'),
    const EmblemAsset(id: 'nat_bridge', name: 'Suspension Arch Bridge', category: 'Nature', path: 'M 8 68 L 92 68 L 92 76 L 8 76 Z M 24 24 L 32 24 L 32 86 L 24 86 Z M 68 24 L 76 24 L 76 86 L 68 86 Z M 8 68 Q 28 30 50 68 Q 72 30 92 68'),
    const EmblemAsset(id: 'nat_lighthouse', name: 'Coastal Lighthouse', category: 'Nature', path: 'M 50 10 L 64 22 L 60 34 L 68 88 L 32 88 L 40 34 L 36 22 Z M 12 24 L 36 28 L 12 34 Z M 88 24 L 64 28 L 88 34 Z'),
    const EmblemAsset(id: 'nat_ship_galleon', name: 'Heraldic Sailing Ship', category: 'Nature', path: 'M 48 12 L 52 12 L 52 68 L 86 68 L 72 88 L 28 88 L 14 68 L 48 68 Z M 52 18 Q 82 32 76 58 L 52 58 Z M 48 24 Q 22 36 26 58 L 48 58 Z'),
    const EmblemAsset(id: 'nat_windmill', name: 'Dutch Windmill', category: 'Nature', path: 'M 38 42 L 62 42 L 68 88 L 32 88 Z M 16 14 L 84 82 L 78 88 L 10 20 Z M 84 14 L 16 82 L 22 88 L 90 20 Z'),
    const EmblemAsset(id: 'nat_pyramid', name: 'Pharaoh Pyramid', category: 'Nature', path: 'M 50 16 L 92 84 L 8 84 Z M 50 16 L 64 84'),
  ];

  static final List<EmblemAsset> _symbols = [
    const EmblemAsset(id: 'sym_compass', name: 'Nautical Compass Rose', category: 'Symbols', path: 'M 50 6 L 60 40 L 94 50 L 60 60 L 50 94 L 40 60 L 6 50 L 40 40 Z'),
    const EmblemAsset(id: 'sym_helm_wheel', name: 'Ship Helm Wheel', category: 'Symbols', path: 'M 50 18 A 32 32 0 1 0 50 82 A 32 32 0 1 0 50 18 Z M 47 6 L 53 6 L 53 94 L 47 94 Z M 6 47 L 94 47 L 94 53 L 6 53 Z M 18 18 L 82 82 M 82 18 L 18 82'),
    const EmblemAsset(id: 'sym_scales', name: 'Scales of Justice', category: 'Symbols', path: 'M 47 12 L 53 12 L 53 88 L 70 88 L 70 94 L 30 94 L 30 88 L 47 88 Z M 16 28 L 84 28 L 84 34 L 16 34 Z M 12 60 L 24 34 L 36 60 Q 24 72 12 60 Z M 64 60 L 76 34 L 88 60 Q 76 72 64 60 Z'),
    const EmblemAsset(id: 'sym_hourglass', name: 'Sand Hourglass', category: 'Symbols', path: 'M 22 12 L 78 12 L 78 20 L 56 50 L 78 80 L 78 88 L 22 88 L 22 80 L 44 50 L 22 20 Z'),
    const EmblemAsset(id: 'sym_book_open', name: 'Academy Open Book', category: 'Symbols', path: 'M 10 24 Q 30 16 50 28 Q 70 16 90 24 L 90 78 Q 70 70 50 82 Q 30 70 10 78 Z M 50 28 L 50 82'),
    const EmblemAsset(id: 'sym_graduation_cap', name: 'Varsity Mortarboard', category: 'Symbols', path: 'M 50 18 L 94 40 L 50 62 L 6 40 Z M 24 52 L 24 74 Q 50 88 76 74 L 76 52 L 50 66 Z'),
    const EmblemAsset(id: 'sym_music_lyre', name: 'Apollo Harp Lyre', category: 'Symbols', path: 'M 24 18 Q 12 52 34 76 L 30 88 L 70 88 L 66 76 Q 88 52 76 18 L 64 24 Q 74 50 56 68 L 44 68 Q 26 50 36 24 Z'),
    const EmblemAsset(id: 'sym_atom', name: 'Atomic Orbit', category: 'Symbols', path: 'M 50 42 A 8 8 0 1 0 50 58 A 8 8 0 1 0 50 42 Z M 50 10 A 18 40 0 1 0 50 90 A 18 40 0 1 0 50 10 Z M 10 50 A 40 18 0 1 0 90 50 A 40 18 0 1 0 10 50 Z'),
    EmblemAsset(id: 'sym_cog_gear', name: '8-Tooth Industrial Gear', category: 'Symbols', path: '${_starPath(8, 44, 34)} M 50 30 A 20 20 0 1 0 50 70 A 20 20 0 1 0 50 30 Z'),
    const EmblemAsset(id: 'sym_piston', name: 'Crossed Engine Pistons', category: 'Symbols', path: 'M 14 26 L 34 10 L 46 24 L 26 40 Z M 34 30 L 86 82 L 78 90 L 26 38 Z M 86 26 L 66 10 L 54 24 L 74 40 Z M 66 30 L 14 82 L 22 90 L 74 38 Z'),
    const EmblemAsset(id: 'sym_wings_badge', name: 'Aviator Pilot Wings', category: 'Symbols', path: 'M 50 32 L 62 50 L 50 68 L 38 50 Z M 38 42 L 6 28 L 14 48 L 8 56 L 38 58 Z M 62 42 L 94 28 L 86 48 L 92 56 L 62 58 Z'),
    const EmblemAsset(id: 'sym_globe_grid', name: 'Meridian World Globe', category: 'Symbols', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 10 A 20 40 0 1 0 50 90 A 20 40 0 1 0 50 10 Z M 10 50 L 90 50 M 16 30 L 84 30 M 16 70 L 84 70'),
    const EmblemAsset(id: 'sym_horseshoe', name: 'Lucky Horseshoe', category: 'Symbols', path: 'M 22 14 L 36 14 L 36 52 A 14 14 0 0 0 64 52 L 64 14 L 78 14 L 78 54 A 28 28 0 0 1 22 54 Z'),
    const EmblemAsset(id: 'sym_spade', name: 'Ace of Spades', category: 'Symbols', path: 'M 50 10 Q 88 46 82 64 A 18 18 0 0 1 54 68 L 62 88 L 38 88 L 46 68 A 18 18 0 0 1 18 64 Q 12 46 50 10 Z'),
    const EmblemAsset(id: 'sym_club', name: 'Ace of Clubs', category: 'Symbols', path: 'M 50 12 A 16 16 0 1 0 50 44 A 16 16 0 1 0 50 12 Z M 28 40 A 16 16 0 1 0 28 72 A 16 16 0 1 0 28 40 Z M 72 40 A 16 16 0 1 0 72 72 A 16 16 0 1 0 72 40 Z M 46 56 L 54 56 L 62 88 L 38 88 Z'),
    const EmblemAsset(id: 'sym_Peace', name: 'Peace Crest', category: 'Symbols', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 10 L 50 90 M 50 50 L 22 78 M 50 50 L 78 78'),
    const EmblemAsset(id: 'sym_yin_yang', name: 'Balance Monogram', category: 'Symbols', path: 'M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z M 50 10 A 20 20 0 0 1 50 50 A 20 20 0 0 0 50 90'),
    const EmblemAsset(id: 'sym_caduceus', name: 'Heraldic Staff', category: 'Symbols', path: 'M 47 12 L 53 12 L 53 90 L 47 90 Z M 12 20 L 47 32 L 88 20 L 72 40 L 28 40 Z M 30 48 Q 70 60 30 76 M 70 48 Q 30 60 70 76'),
    const EmblemAsset(id: 'sym_ankh', name: 'Ancient Key of Life', category: 'Symbols', path: 'M 50 12 A 16 20 0 1 0 50 52 A 16 20 0 1 0 50 12 Z M 24 50 L 76 50 L 76 58 L 54 58 L 54 90 L 46 90 L 46 58 L 24 58 Z'),
    const EmblemAsset(id: 'sym_triskelion', name: 'Celtic Triskelion Spiral', category: 'Symbols', path: 'M 50 50 L 50 14 L 72 22 Z M 50 50 L 82 68 L 64 86 Z M 50 50 L 18 68 L 18 42 Z'),
    const EmblemAsset(id: 'sym_chevron_shield', name: 'Military Rank Shield', category: 'Symbols', path: 'M 20 14 L 80 14 L 80 60 L 50 88 L 20 60 Z M 28 42 L 50 24 L 72 42 L 72 52 L 50 34 L 28 52 Z'),
    const EmblemAsset(id: 'sym_bell', name: 'Liberty Bell', category: 'Symbols', path: 'M 42 12 L 58 12 L 58 20 Q 76 26 78 66 L 86 76 L 14 76 L 22 66 Q 24 26 42 20 Z M 42 78 A 8 8 0 0 0 58 78 Z'),
    const EmblemAsset(id: 'sym_crown_heart', name: 'Loyal Heart & Crown', category: 'Symbols', path: 'M 28 28 L 34 12 L 50 24 L 66 12 L 72 28 Z M 50 42 C 36 24 14 34 18 56 C 22 74 50 88 50 90 C 50 88 78 74 82 56 C 86 34 64 24 50 42 Z'),
    const EmblemAsset(id: 'sym_hand_fist', name: 'Unity Power Fist', category: 'Symbols', path: 'M 28 26 L 72 26 L 78 56 L 64 68 L 64 88 L 36 88 L 36 68 L 22 56 Z'),
    const EmblemAsset(id: 'sym_feather_quill', name: 'Heritage Quill Pen', category: 'Symbols', path: 'M 82 12 Q 86 52 38 74 L 16 88 L 28 66 Q 46 18 82 12 Z'),
    const EmblemAsset(id: 'sym_lantern', name: 'Beacon Lantern', category: 'Symbols', path: 'M 38 14 L 62 14 L 72 28 L 64 78 L 72 86 L 28 86 L 36 78 L 28 28 Z'),
    const EmblemAsset(id: 'sym_omega', name: 'Omega Crest', category: 'Symbols', path: 'M 14 76 L 34 76 A 32 32 0 1 1 66 76 L 86 76 L 86 86 L 54 86 L 54 70 A 20 20 0 1 0 46 70 L 46 86 L 14 86 Z'),
    const EmblemAsset(id: 'sym_delta', name: 'Delta Triad', category: 'Symbols', path: 'M 50 10 L 90 84 L 10 84 Z M 50 32 L 72 74 L 28 74 Z'),
    const EmblemAsset(id: 'sym_knot_celtic', name: 'Eternal Square Knot', category: 'Symbols', path: 'M 24 14 L 76 14 L 76 86 L 24 86 Z M 14 24 L 86 24 L 86 76 L 14 76 Z'),
    const EmblemAsset(id: 'sym_ribbon_awareness', name: 'Folded Loop Ribbon', category: 'Symbols', path: 'M 32 88 L 68 34 A 18 18 0 1 0 32 34 L 68 88 L 54 88 L 24 38 A 28 28 0 1 1 76 38 L 46 88 Z'),
  ];

  static final Map<String, String> _baseGlyphPaths = {
    'A': 'M 50 12 L 82 88 L 66 88 L 59 68 L 41 68 L 34 88 L 18 88 Z M 45 54 L 55 54 L 50 34 Z',
    'B': 'M 24 12 L 62 12 Q 78 12 78 30 Q 78 44 64 48 Q 82 52 82 70 Q 82 88 62 88 L 24 88 Z M 38 26 L 38 42 L 58 42 L 58 26 Z M 38 56 L 38 74 L 60 74 L 60 56 Z',
    'C': 'M 78 28 L 66 36 Q 58 24 48 26 Q 34 28 34 50 Q 34 72 48 74 Q 58 76 66 64 L 78 72 Q 66 90 46 88 Q 18 86 18 50 Q 18 14 46 12 Q 66 10 78 28 Z',
    'D': 'M 22 12 L 56 12 Q 84 12 84 50 Q 84 88 56 88 L 22 88 Z M 38 26 L 38 74 L 54 74 Q 68 74 68 50 Q 68 26 54 26 Z',
    'E': 'M 24 12 L 78 12 L 78 26 L 40 26 L 40 43 L 72 43 L 72 57 L 40 57 L 40 74 L 78 74 L 78 88 L 24 88 Z',
    'F': 'M 24 12 L 78 12 L 78 26 L 40 26 L 40 46 L 72 46 L 72 60 L 40 60 L 40 88 L 24 88 Z',
    'G': 'M 78 28 L 64 34 Q 56 24 46 26 Q 34 28 34 50 Q 34 74 50 74 Q 64 74 66 58 L 50 58 L 50 46 L 82 46 L 82 88 L 70 88 L 68 80 Q 56 90 44 88 Q 18 86 18 50 Q 18 14 48 12 Q 68 12 78 28 Z',
    'H': 'M 20 12 L 36 12 L 36 42 L 64 42 L 64 12 L 80 12 L 80 88 L 64 88 L 64 58 L 36 58 L 36 88 L 20 88 Z',
    'I': 'M 30 12 L 70 12 L 70 26 L 58 26 L 58 74 L 70 74 L 70 88 L 30 88 L 30 74 L 42 74 L 42 26 L 30 26 Z',
    'J': 'M 56 12 L 72 12 L 72 64 Q 72 88 46 88 Q 22 88 22 64 L 38 64 Q 38 74 46 74 Q 56 74 56 64 Z',
    'K': 'M 22 12 L 38 12 L 38 44 L 66 12 L 84 12 L 54 46 L 86 88 L 66 88 L 44 58 L 38 64 L 38 88 L 22 88 Z',
    'L': 'M 24 12 L 40 12 L 40 74 L 78 74 L 78 88 L 24 88 Z',
    'M': 'M 14 12 L 32 12 L 50 48 L 68 12 L 86 12 L 86 88 L 70 88 L 70 40 L 50 76 L 30 40 L 30 88 L 14 88 Z',
    'N': 'M 18 12 L 34 12 L 66 62 L 66 12 L 82 12 L 82 88 L 66 88 L 34 38 L 34 88 L 18 88 Z',
    'O': 'M 50 12 A 34 38 0 1 0 50 88 A 34 38 0 1 0 50 12 Z M 50 26 A 18 24 0 1 0 50 74 A 18 24 0 1 0 50 26 Z',
    'P': 'M 24 12 L 60 12 Q 82 12 82 36 Q 82 60 60 60 L 40 60 L 40 88 L 24 88 Z M 40 26 L 40 46 L 58 46 Q 66 46 66 36 Q 66 26 58 26 Z',
    'Q': 'M 50 12 A 34 36 0 1 0 50 84 A 34 36 0 1 0 50 12 Z M 56 64 L 84 86 L 74 94 L 48 72 Z',
    'R': 'M 22 12 L 60 12 Q 80 12 80 34 Q 80 50 64 56 L 84 88 L 66 88 L 48 58 L 38 58 L 38 88 L 22 88 Z M 38 26 L 38 44 L 58 44 Q 64 44 64 34 Q 64 26 58 26 Z',
    'S': 'M 76 26 L 64 34 Q 56 24 44 26 Q 36 28 38 36 Q 40 42 58 46 Q 82 52 80 70 Q 78 88 50 88 Q 24 88 18 70 L 32 62 Q 38 74 52 74 Q 64 74 64 66 Q 64 58 46 54 Q 20 48 22 32 Q 24 12 50 12 Q 68 12 76 26 Z',
    'T': 'M 16 12 L 84 12 L 84 26 L 58 26 L 58 88 L 42 88 L 42 26 L 16 26 Z',
    'U': 'M 20 12 L 36 12 L 36 62 Q 36 74 50 74 Q 64 74 64 62 L 64 12 L 80 12 L 80 62 Q 80 88 50 88 Q 20 88 20 62 Z',
    'V': 'M 16 12 L 34 12 L 50 66 L 66 12 L 84 12 L 58 88 L 42 88 Z',
    'W': 'M 8 12 L 24 12 L 34 64 L 50 26 L 66 64 L 76 12 L 92 12 L 74 88 L 60 88 L 50 52 L 40 88 L 26 88 Z',
    'X': 'M 16 12 L 34 12 L 50 38 L 66 12 L 84 12 L 60 50 L 86 88 L 68 88 L 50 62 L 32 88 L 14 88 L 40 50 Z',
    'Y': 'M 16 12 L 34 12 L 50 42 L 66 12 L 84 12 L 58 56 L 58 88 L 42 88 L 42 56 Z',
    'Z': 'M 20 12 L 80 12 L 80 26 L 40 74 L 80 74 L 80 88 L 20 88 L 20 74 L 60 26 L 20 26 Z',
    '0': 'M 50 12 A 30 38 0 1 0 50 88 A 30 38 0 1 0 50 12 Z M 50 26 A 14 24 0 1 0 50 74 A 14 24 0 1 0 50 26 Z',
    '1': 'M 36 22 L 50 12 L 62 12 L 62 74 L 74 74 L 74 88 L 28 88 L 28 74 L 46 74 L 46 30 L 36 36 Z',
    '2': 'M 22 30 Q 24 12 52 12 Q 78 12 78 34 Q 78 50 42 74 L 80 74 L 80 88 L 20 88 L 20 74 Q 60 44 60 34 Q 60 26 48 26 Q 38 26 36 36 Z',
    '3': 'M 24 24 Q 32 12 52 12 Q 78 12 78 32 Q 78 46 64 48 Q 80 54 80 70 Q 80 88 50 88 Q 26 88 20 72 L 36 66 Q 40 74 52 74 Q 64 74 64 66 Q 64 56 46 56 L 46 44 Q 62 44 62 34 Q 62 26 50 26 Q 40 26 36 32 Z',
    '4': 'M 56 12 L 72 12 L 72 60 L 84 60 L 84 74 L 72 74 L 72 88 L 56 88 L 56 74 L 16 74 L 16 60 Z M 34 60 L 56 60 L 56 32 Z',
    '5': 'M 26 12 L 76 12 L 76 26 L 40 26 L 38 42 Q 50 36 64 42 Q 80 50 80 68 Q 80 88 50 88 Q 24 88 20 70 L 36 66 Q 40 74 52 74 Q 64 74 64 64 Q 64 52 48 52 Q 38 52 34 56 L 22 52 Z',
    '6': 'M 64 12 L 44 40 Q 54 38 64 42 Q 80 50 80 66 Q 80 88 50 88 Q 20 88 20 64 Q 20 48 34 30 L 48 12 Z M 50 52 A 14 12 0 1 0 50 76 A 14 12 0 1 0 50 52 Z',
    '7': 'M 20 12 L 80 12 L 80 26 L 48 88 L 30 88 L 62 26 L 20 26 Z',
    '8': 'M 50 12 A 26 18 0 1 0 50 48 A 26 18 0 1 0 50 12 Z M 50 48 A 30 20 0 1 0 50 88 A 30 20 0 1 0 50 48 Z',
    '9': 'M 50 12 Q 80 12 80 36 Q 80 52 66 70 L 52 88 L 36 88 L 56 60 Q 46 62 36 58 Q 20 50 20 34 Q 20 12 50 12 Z M 50 24 A 14 12 0 1 0 50 48 A 14 12 0 1 0 50 24 Z',
  };

  static List<EmblemAsset> _generateVectorGlyphs() {
    final result = <EmblemAsset>[];
    for (final entry in _baseGlyphPaths.entries) {
      final ch = entry.key;
      final base = entry.value;
      result.add(EmblemAsset(
        id: 'glyph_block_$ch',
        name: '$ch (Block)',
        category: 'Letters & Digits',
        path: base,
      ));
      result.add(EmblemAsset(
        id: 'glyph_serif_$ch',
        name: '$ch (Serif Crest)',
        category: 'Letters & Digits',
        path: '$base M 16 10 L 84 10 L 84 14 L 16 14 Z M 16 86 L 84 86 L 84 90 L 16 90 Z',
      ));
      result.add(EmblemAsset(
        id: 'glyph_framed_$ch',
        name: '$ch (Monogram Shield)',
        category: 'Letters & Digits',
        path: 'M 8 8 L 92 8 L 92 92 L 8 92 Z $base',
      ));
    }
    return result;
  }
}
