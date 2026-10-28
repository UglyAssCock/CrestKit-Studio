class JerseyTemplateAsset {
  final String id;
  final String name;
  final String category;
  final String bodyFrontPath;
  final String bodyBackPath;
  final String sleevesFrontPath;
  final String sleevesBackPath;
  final String sidePanelsPath;
  final String yokePath;
  final String sleeveSinglePath;

  const JerseyTemplateAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.bodyFrontPath,
    required this.bodyBackPath,
    required this.sleevesFrontPath,
    required this.sleevesBackPath,
    required this.sidePanelsPath,
    required this.yokePath,
    this.sleeveSinglePath =
        'M 30 14 L 70 14 L 82 84 L 18 84 Z M 18 76 L 82 76 L 82 84 L 18 84 Z',
  });
}

class GarmentDetailAsset {
  final String id;
  final String name;
  final String type; // 'collar', 'cuff', 'trim', 'shorts', 'socks'
  final String primaryPath;
  final String secondaryPath;

  const GarmentDetailAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryPath,
    this.secondaryPath = '',
  });
}

class JerseyLibrary {
  static const String _stdFrontBody =
      'M 30 14 L 40 12 Q 50 18 60 12 L 70 14 L 74 28 L 72 88 L 28 88 L 26 28 Z';
  static const String _stdBackBody =
      'M 30 14 L 40 12 Q 50 14 60 12 L 70 14 L 74 28 L 72 88 L 28 88 L 26 28 Z';
  static const String _shortSleeves =
      'M 30 14 L 12 28 L 18 42 L 26 32 L 26 28 Z M 70 14 L 88 28 L 82 42 L 74 32 L 74 28 Z';
  static const String _longSleeves =
      'M 30 14 L 10 30 L 14 78 L 23 78 L 24 34 L 26 28 Z M 70 14 L 90 30 L 86 78 L 77 78 L 76 34 L 74 28 Z';
  static const String _raglanSleeves =
      'M 40 12 L 12 28 L 18 42 L 26 32 L 34 22 Z M 60 12 L 88 28 L 82 42 L 74 32 L 66 22 Z';
  static const String _sleeveless = 'M 30 14 L 26 28 L 28 30 L 32 14 Z M 70 14 L 74 28 L 72 30 L 68 14 Z';
  static const String _stdSides =
      'M 26 32 L 31 32 L 32 88 L 28 88 Z M 74 32 L 69 32 L 68 88 L 72 88 Z';
  static const String _stdYoke =
      'M 30 14 L 40 12 Q 50 18 60 12 L 70 14 L 73 22 L 27 22 Z';

  static final List<JerseyTemplateAsset> templates = [
    const JerseyTemplateAsset(
      id: 'football_short',
      name: 'Football Pro Short Sleeve',
      category: 'Football',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'football_long',
      name: 'Football Pro Long Sleeve',
      category: 'Football',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'football_retro',
      name: 'Football 90s Heritage Cut',
      category: 'Football',
      bodyFrontPath:
          'M 28 14 L 40 12 L 50 20 L 60 12 L 72 14 L 76 32 L 74 88 L 26 88 L 24 32 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath:
          'M 28 14 L 8 30 L 16 46 L 24 36 L 24 32 Z M 72 14 L 92 30 L 84 46 L 76 36 L 76 32 Z',
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 28 14 L 72 14 L 75 26 L 25 26 Z',
    ),
    const JerseyTemplateAsset(
      id: 'football_raglan',
      name: 'Football Aero Raglan',
      category: 'Football',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _raglanSleeves,
      sleevesBackPath: _raglanSleeves,
      sidePanelsPath:
          'M 26 34 Q 33 58 28 88 L 32 88 Q 37 58 29 34 Z M 74 34 Q 67 58 72 88 L 68 88 Q 63 58 71 34 Z',
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'football_gk_long',
      name: 'Goalkeeper Padded Pro',
      category: 'Football',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 30 14 L 70 14 L 74 28 L 50 34 L 26 28 Z',
    ),
    const JerseyTemplateAsset(
      id: 'basketball_tank',
      name: 'Basketball Hardwood Singlet',
      category: 'Basketball',
      bodyFrontPath:
          'M 35 12 L 42 12 Q 50 28 58 12 L 65 12 Q 62 28 72 34 L 72 88 L 28 88 L 28 34 Q 38 28 35 12 Z',
      bodyBackPath:
          'M 36 12 L 43 12 Q 50 24 57 12 L 64 12 Q 60 28 72 34 L 72 88 L 28 88 L 28 34 Q 40 28 36 12 Z',
      sleevesFrontPath: _sleeveless,
      sleevesBackPath: _sleeveless,
      sidePanelsPath:
          'M 28 34 L 33 34 L 33 88 L 28 88 Z M 72 34 L 67 34 L 67 88 L 72 88 Z',
      yokePath: 'M 35 12 L 42 12 L 38 24 L 32 24 Z M 65 12 L 58 12 L 62 24 L 68 24 Z',
    ),
    const JerseyTemplateAsset(
      id: 'basketball_wide',
      name: 'Basketball Wide-Shoulder Cut',
      category: 'Basketball',
      bodyFrontPath:
          'M 30 12 L 41 12 Q 50 24 59 12 L 70 12 L 68 32 L 72 88 L 28 88 L 32 32 Z',
      bodyBackPath:
          'M 30 12 L 41 12 Q 50 20 59 12 L 70 12 L 68 32 L 72 88 L 28 88 L 32 32 Z',
      sleevesFrontPath: _sleeveless,
      sleevesBackPath: _sleeveless,
      sidePanelsPath: _stdSides,
      yokePath: 'M 30 12 L 70 12 L 69 22 L 31 22 Z',
    ),
    const JerseyTemplateAsset(
      id: 'basketball_retro',
      name: 'Basketball 80s Classic Mesh',
      category: 'Basketball',
      bodyFrontPath:
          'M 34 14 L 42 14 A 8 12 0 0 0 58 14 L 66 14 Q 64 30 72 34 L 72 88 L 28 88 L 28 34 Q 36 30 34 14 Z',
      bodyBackPath:
          'M 34 14 L 42 14 A 8 10 0 0 0 58 14 L 66 14 Q 64 30 72 34 L 72 88 L 28 88 L 28 34 Q 36 30 34 14 Z',
      sleevesFrontPath: _sleeveless,
      sleevesBackPath: _sleeveless,
      sidePanelsPath: _stdSides,
      yokePath: 'M 34 14 L 66 14 L 66 20 L 34 20 Z',
    ),
    const JerseyTemplateAsset(
      id: 'rugby_pro',
      name: 'Rugby Test Match Jersey',
      category: 'Rugby',
      bodyFrontPath:
          'M 28 14 L 40 11 L 50 16 L 60 11 L 72 14 L 75 30 L 72 88 L 28 88 L 25 30 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 28 14 L 72 14 L 75 28 L 50 32 L 25 28 Z',
    ),
    const JerseyTemplateAsset(
      id: 'rugby_heritage',
      name: 'Rugby Classic Long Sleeve',
      category: 'Rugby',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'cricket_t20',
      name: 'Cricket T20 Sublimation Polo',
      category: 'Cricket',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _raglanSleeves,
      sleevesBackPath: _raglanSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'cricket_test',
      name: 'Cricket Test Flannel Sweater',
      category: 'Cricket',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: 'M 28 82 L 72 82 L 72 88 L 28 88 Z',
      yokePath: 'M 36 12 L 50 30 L 64 12 L 58 12 L 50 24 L 42 12 Z',
    ),
    const JerseyTemplateAsset(
      id: 'esports_zipped',
      name: 'Esports Pro Quarter-Zip',
      category: 'Esports',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _raglanSleeves,
      sleevesBackPath: _raglanSleeves,
      sidePanelsPath:
          'M 26 30 L 34 44 L 30 88 L 26 88 Z M 74 30 L 66 44 L 70 88 L 74 88 Z',
      yokePath: 'M 30 14 L 50 28 L 70 14 L 74 24 L 50 38 L 26 24 Z',
    ),
    const JerseyTemplateAsset(
      id: 'esports_hoodie',
      name: 'Esports Arena Stage Hoodie',
      category: 'Esports',
      bodyFrontPath:
          'M 28 16 L 72 16 L 76 32 L 74 88 L 26 88 L 24 32 Z M 34 62 L 66 62 L 70 82 L 30 82 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 32 6 L 68 6 Q 76 14 72 20 L 28 20 Q 24 14 32 6 Z',
    ),
    const JerseyTemplateAsset(
      id: 'cycling_zip',
      name: 'Cycling Aero Full-Zip',
      category: 'Cycling',
      bodyFrontPath:
          'M 32 12 L 68 12 L 72 28 L 68 88 L 32 88 L 28 28 Z M 49 12 L 51 12 L 51 88 L 49 88 Z',
      bodyBackPath:
          'M 32 12 L 68 12 L 72 28 L 68 90 L 32 90 L 28 28 Z M 34 68 L 66 68 L 66 86 L 34 86 Z',
      sleevesFrontPath: _raglanSleeves,
      sleevesBackPath: _raglanSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'cycling_bib',
      name: 'Cycling Grand Tour Skinsuit',
      category: 'Cycling',
      bodyFrontPath: 'M 32 12 L 68 12 L 72 56 L 68 92 L 54 92 L 50 72 L 46 92 L 32 92 L 28 56 Z',
      bodyBackPath: 'M 32 12 L 68 12 L 72 56 L 68 92 L 54 92 L 50 72 L 46 92 L 32 92 L 28 56 Z',
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'hockey_ice',
      name: 'Ice Hockey Sweater',
      category: 'Hockey',
      bodyFrontPath:
          'M 26 14 L 40 12 L 50 18 L 60 12 L 74 14 L 78 36 L 76 88 L 24 88 L 22 36 Z',
      bodyBackPath:
          'M 26 14 L 74 14 L 78 36 L 76 88 L 24 88 L 22 36 Z',
      sleevesFrontPath:
          'M 26 14 L 6 34 L 12 78 L 22 78 L 22 36 Z M 74 14 L 94 34 L 88 78 L 78 78 L 78 36 Z',
      sleevesBackPath:
          'M 26 14 L 6 34 L 12 78 L 22 78 L 22 36 Z M 74 14 L 94 34 L 88 78 L 78 78 L 78 36 Z',
      sidePanelsPath: 'M 24 74 L 76 74 L 76 84 L 24 84 Z',
      yokePath: 'M 26 14 L 74 14 L 78 26 L 22 26 Z',
    ),
    const JerseyTemplateAsset(
      id: 'baseball_button',
      name: 'Baseball Diamond Button-Down',
      category: 'Baseball',
      bodyFrontPath:
          'M 30 14 L 40 12 L 50 22 L 60 12 L 70 14 L 74 28 L 72 88 Q 50 92 28 88 L 26 28 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath:
          'M 48 22 L 52 22 L 52 89 L 48 89 Z',
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'am_football_gridiron',
      name: 'American Football Gridiron',
      category: 'Gridiron',
      bodyFrontPath:
          'M 24 14 L 38 10 L 50 18 L 62 10 L 76 14 L 80 30 L 70 88 L 30 88 L 20 30 Z',
      bodyBackPath:
          'M 24 14 L 76 14 L 80 30 L 70 88 L 30 88 L 20 30 Z',
      sleevesFrontPath:
          'M 24 14 L 10 26 L 16 40 L 20 30 Z M 76 14 L 90 26 L 84 40 L 80 30 Z',
      sleevesBackPath:
          'M 24 14 L 10 26 L 16 40 L 20 30 Z M 76 14 L 90 26 L 84 40 L 80 30 Z',
      sidePanelsPath: _stdSides,
      yokePath: 'M 24 14 L 76 14 L 80 28 L 20 28 Z',
    ),
    const JerseyTemplateAsset(
      id: 'volleyball_pro',
      name: 'Volleyball Court Fitted',
      category: 'Volleyball',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 30 14 L 70 14 L 50 32 Z',
    ),
    const JerseyTemplateAsset(
      id: 'running_singlet',
      name: 'Athletics Track Racerback',
      category: 'Athletics',
      bodyFrontPath:
          'M 36 12 L 42 12 Q 50 26 58 12 L 64 12 Q 62 32 72 38 L 70 88 L 30 88 L 28 38 Q 38 32 36 12 Z',
      bodyBackPath:
          'M 42 12 L 58 12 L 54 34 L 72 42 L 70 88 L 30 88 L 28 42 L 46 34 Z',
      sleevesFrontPath: _sleeveless,
      sleevesBackPath: _sleeveless,
      sidePanelsPath: 'M 30 60 L 70 60 L 70 72 L 30 72 Z',
      yokePath: 'M 36 12 L 64 12 L 64 20 L 36 20 Z',
    ),
    const JerseyTemplateAsset(
      id: 'tennis_polo',
      name: 'Tennis Grand Slam Polo',
      category: 'Tennis',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 48 16 L 52 16 L 52 34 L 48 34 Z',
    ),
    const JerseyTemplateAsset(
      id: 'handball_court',
      name: 'Handball Reinforced Top',
      category: 'Handball',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'futsal_street',
      name: 'Futsal Sala Fast-Dry',
      category: 'Football',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _raglanSleeves,
      sleevesBackPath: _raglanSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'tracksuit_jacket',
      name: 'Anthem Tracksuit Jacket',
      category: 'Outerwear',
      bodyFrontPath:
          'M 28 12 L 72 12 L 76 30 L 74 88 L 26 88 L 24 30 Z M 49 12 L 51 12 L 51 88 L 49 88 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: 'M 26 82 L 74 82 L 74 88 L 26 88 Z',
      yokePath: 'M 28 12 L 72 12 L 75 34 L 50 42 L 25 34 Z',
    ),
    const JerseyTemplateAsset(
      id: 'hoodie_lifestyle',
      name: 'Club Pullover Hoodie',
      category: 'Outerwear',
      bodyFrontPath:
          'M 28 14 L 72 14 L 76 32 L 74 88 L 26 88 L 24 32 Z M 34 60 L 66 60 L 70 82 L 30 82 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: 'M 26 82 L 74 82 L 74 88 L 26 88 Z',
      yokePath: 'M 34 6 L 66 6 L 70 16 L 30 16 Z',
    ),
    const JerseyTemplateAsset(
      id: 'polo_travel',
      name: 'Manager Travel Polo',
      category: 'Lifestyle',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 48 16 L 52 16 L 52 34 L 48 34 Z',
    ),
    const JerseyTemplateAsset(
      id: 'tshirt_fan',
      name: 'Supporter Crew Tee',
      category: 'Lifestyle',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'windbreaker_rain',
      name: 'Training Rain Windbreaker',
      category: 'Outerwear',
      bodyFrontPath:
          'M 28 12 L 72 12 L 76 30 L 76 88 L 24 88 L 24 30 Z',
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _longSleeves,
      sleevesBackPath: _longSleeves,
      sidePanelsPath: _stdSides,
      yokePath: 'M 28 12 L 72 12 L 76 36 L 50 46 L 24 36 Z',
    ),
    const JerseyTemplateAsset(
      id: 'training_bib',
      name: 'Training Pinnies Scrimmage Bib',
      category: 'Training',
      bodyFrontPath:
          'M 34 12 L 42 12 Q 50 28 58 12 L 66 12 L 66 36 L 72 36 L 72 84 L 28 84 L 28 36 L 34 36 Z',
      bodyBackPath:
          'M 34 12 L 42 12 Q 50 28 58 12 L 66 12 L 66 36 L 72 36 L 72 84 L 28 84 L 28 36 L 34 36 Z',
      sleevesFrontPath: _sleeveless,
      sleevesBackPath: _sleeveless,
      sidePanelsPath: 'M 28 36 L 32 36 L 32 84 L 28 84 Z M 68 36 L 72 36 L 72 84 L 68 84 Z',
      yokePath: 'M 34 12 L 66 12 L 66 18 L 34 18 Z',
    ),
    const JerseyTemplateAsset(
      id: 'scarf_ultras',
      name: 'Ultras Jacquard Stadium Scarf',
      category: 'Accessories',
      bodyFrontPath: 'M 10 34 L 90 34 L 90 66 L 10 66 Z',
      bodyBackPath: 'M 10 34 L 90 34 L 90 66 L 10 66 Z',
      sleevesFrontPath: 'M 4 34 L 10 34 L 10 66 L 4 66 Z M 90 34 L 96 34 L 96 66 L 90 66 Z',
      sleevesBackPath: 'M 4 34 L 10 34 L 10 66 L 4 66 Z M 90 34 L 96 34 L 96 66 L 90 66 Z',
      sidePanelsPath: 'M 16 34 L 22 34 L 22 66 L 16 66 Z M 78 34 L 84 34 L 84 66 L 78 66 Z',
      yokePath: 'M 10 34 L 90 34 L 90 40 L 10 40 Z',
    ),
    const JerseyTemplateAsset(
      id: 'cap_snapback',
      name: 'Club Snapback Cap',
      category: 'Accessories',
      bodyFrontPath: 'M 20 56 A 30 32 0 0 1 80 56 Z',
      bodyBackPath: 'M 20 56 A 30 32 0 0 1 80 56 Z M 38 48 A 12 8 0 0 1 62 48 Z',
      sleevesFrontPath: 'M 12 56 L 88 56 Q 92 70 50 72 Q 8 70 12 56 Z',
      sleevesBackPath: 'M 20 52 L 80 52 L 80 56 L 20 56 Z',
      sidePanelsPath: 'M 48 24 L 52 24 L 52 56 L 48 56 Z',
      yokePath: 'M 46 22 A 4 4 0 1 0 54 22 A 4 4 0 1 0 46 22 Z',
    ),
    const JerseyTemplateAsset(
      id: 'beanie_winter',
      name: 'Winter Sideline Beanie',
      category: 'Accessories',
      bodyFrontPath: 'M 22 64 Q 22 22 50 22 Q 78 22 78 64 Z',
      bodyBackPath: 'M 22 64 Q 22 22 50 22 Q 78 22 78 64 Z',
      sleevesFrontPath: 'M 18 60 L 82 60 L 82 78 L 18 78 Z',
      sleevesBackPath: 'M 18 60 L 82 60 L 82 78 L 18 78 Z',
      sidePanelsPath: 'M 22 44 L 78 44 L 78 54 L 22 54 Z',
      yokePath: 'M 50 10 A 10 10 0 1 0 50 30 A 10 10 0 1 0 50 10 Z',
    ),
    const JerseyTemplateAsset(
      id: 'football_womens_fit',
      name: 'Football Women Pro Tailored',
      category: 'Football',
      bodyFrontPath:
          'M 32 14 L 40 12 Q 50 18 60 12 L 68 14 L 72 28 Q 66 54 72 88 L 28 88 Q 34 54 28 28 Z',
      bodyBackPath:
          'M 32 14 L 68 14 L 72 28 Q 66 54 72 88 L 28 88 Q 34 54 28 28 Z',
      sleevesFrontPath: _shortSleeves,
      sleevesBackPath: _shortSleeves,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
    const JerseyTemplateAsset(
      id: 'football_sleeveless_training',
      name: 'Summer Sleeveless Training Top',
      category: 'Training',
      bodyFrontPath: _stdFrontBody,
      bodyBackPath: _stdBackBody,
      sleevesFrontPath: _sleeveless,
      sleevesBackPath: _sleeveless,
      sidePanelsPath: _stdSides,
      yokePath: _stdYoke,
    ),
  ];

  static final List<GarmentDetailAsset> collars = [
    const GarmentDetailAsset(
      id: 'v_neck',
      name: 'Classic V-Neck',
      type: 'collar',
      primaryPath: 'M 38 11 L 50 25 L 62 11 L 58 11 L 50 20 L 42 11 Z',
      secondaryPath: 'M 42 11 L 58 11 L 50 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'round',
      name: 'Round Neck',
      type: 'collar',
      primaryPath: 'M 38 11 Q 50 22 62 11 L 58 11 Q 50 18 42 11 Z',
      secondaryPath: 'M 42 11 Q 50 18 58 11 Z',
    ),
    const GarmentDetailAsset(
      id: 'crew',
      name: 'Thick Ribbed Crew',
      type: 'collar',
      primaryPath: 'M 36 10 Q 50 24 64 10 L 59 10 Q 50 18 41 10 Z',
      secondaryPath: 'M 41 10 Q 50 18 59 10 Z',
    ),
    const GarmentDetailAsset(
      id: 'polo',
      name: 'Classic Folded Polo',
      type: 'collar',
      primaryPath:
          'M 36 10 L 44 22 L 50 18 L 56 22 L 64 10 L 58 8 L 50 14 L 42 8 Z',
      secondaryPath: 'M 42 10 L 58 10 L 50 18 Z',
    ),
    const GarmentDetailAsset(
      id: 'button_polo',
      name: 'Button Placket Polo',
      type: 'collar',
      primaryPath:
          'M 36 10 L 44 20 L 48 18 L 48 30 L 52 30 L 52 18 L 56 20 L 64 10 L 58 8 L 50 14 L 42 8 Z',
      secondaryPath: 'M 42 10 L 58 10 L 50 16 Z',
    ),
    const GarmentDetailAsset(
      id: 'henley',
      name: 'Grandad Henley Placket',
      type: 'collar',
      primaryPath:
          'M 38 11 Q 50 20 62 11 L 58 11 Q 50 16 42 11 Z M 48 16 L 52 16 L 52 28 L 48 28 Z',
      secondaryPath: 'M 42 11 Q 50 16 58 11 Z',
    ),
    const GarmentDetailAsset(
      id: 'mandarin',
      name: 'Stand Mandarin Collar',
      type: 'collar',
      primaryPath: 'M 38 8 L 62 8 L 62 15 L 52 15 L 50 20 L 48 15 L 38 15 Z',
      secondaryPath: 'M 40 10 L 60 10 L 60 13 L 40 13 Z',
    ),
    const GarmentDetailAsset(
      id: 'zipped',
      name: 'Quarter-Zip Tech Collar',
      type: 'collar',
      primaryPath: 'M 38 8 L 62 8 L 60 16 L 51 16 L 51 30 L 49 30 L 49 16 L 40 16 Z',
      secondaryPath: 'M 42 10 L 58 10 L 58 14 L 42 14 Z',
    ),
    const GarmentDetailAsset(
      id: 'wrap_v',
      name: 'Overlap Wrap V-Neck',
      type: 'collar',
      primaryPath: 'M 37 11 L 52 26 L 63 11 L 58 11 L 48 22 L 41 11 Z',
      secondaryPath: 'M 41 11 L 58 11 L 50 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'deep_v',
      name: 'Retro Deep V-Neck',
      type: 'collar',
      primaryPath: 'M 37 11 L 50 32 L 63 11 L 58 11 L 50 25 L 42 11 Z',
      secondaryPath: 'M 42 11 L 58 11 L 50 25 Z',
    ),
    const GarmentDetailAsset(
      id: 'ribbed',
      name: 'Striped Rib Collar',
      type: 'collar',
      primaryPath: 'M 36 10 Q 50 24 64 10 L 60 10 Q 50 20 40 10 Z',
      secondaryPath: 'M 38 11 Q 50 22 62 11',
    ),
    const GarmentDetailAsset(
      id: 'laced',
      name: 'Vintage Laced Drawstring',
      type: 'collar',
      primaryPath:
          'M 38 11 L 50 26 L 62 11 L 58 11 L 50 22 L 42 11 Z M 44 16 L 56 20 M 56 16 L 44 20',
      secondaryPath: 'M 42 11 L 58 11 L 50 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'hood',
      name: 'Athletic Scuba Hood',
      type: 'collar',
      primaryPath: 'M 32 14 Q 30 2 50 2 Q 70 2 68 14 L 58 18 L 50 24 L 42 18 Z',
      secondaryPath: 'M 38 12 Q 50 6 62 12 L 50 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'collarless',
      name: 'Laser-Cut Seamless',
      type: 'collar',
      primaryPath: 'M 40 12 Q 50 17 60 12 L 59 14 Q 50 19 41 14 Z',
      secondaryPath: '',
    ),
  ];

  static final List<GarmentDetailAsset> cuffs = [
    const GarmentDetailAsset(
      id: 'cuff_ribbed',
      name: 'Wide Ribbed Cuffs',
      type: 'cuff',
      primaryPath:
          'M 12 28 L 15 25 L 21 39 L 18 42 Z M 88 28 L 85 25 L 79 39 L 82 42 Z',
    ),
    const GarmentDetailAsset(
      id: 'cuff_plain',
      name: 'Thin Seamless Hem',
      type: 'cuff',
      primaryPath:
          'M 12 28 L 13.5 26.5 L 19.5 40.5 L 18 42 Z M 88 28 L 86.5 26.5 L 80.5 40.5 L 82 42 Z',
    ),
    const GarmentDetailAsset(
      id: 'cuff_striped',
      name: 'Twin Hoop Cuffs',
      type: 'cuff',
      primaryPath:
          'M 12 28 L 16 24 L 22 38 L 18 42 Z M 88 28 L 84 24 L 78 38 L 82 42 Z',
      secondaryPath: 'M 14 26 L 20 40 M 86 26 L 80 40',
    ),
    const GarmentDetailAsset(
      id: 'cuff_angled',
      name: 'Notched Aero Cuffs',
      type: 'cuff',
      primaryPath:
          'M 12 28 L 17 24 L 20 32 L 22 38 L 18 42 Z M 88 28 L 83 24 L 80 32 L 78 38 L 82 42 Z',
    ),
  ];

  static final List<GarmentDetailAsset> trims = [
    const GarmentDetailAsset(
      id: 'shoulder_3_stripes',
      name: '3 Shoulder Stripes',
      type: 'trim',
      primaryPath:
          'M 38 12 L 16 25 L 17 27 L 39 14 Z M 36 15 L 18 26 L 19 28 L 37 17 Z M 34 18 L 20 27 L 21 29 L 35 20 Z M 62 12 L 84 25 L 83 27 L 61 14 Z M 64 15 L 82 26 L 81 28 L 63 17 Z M 66 18 L 80 27 L 79 29 L 65 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'shoulder_2_stripes',
      name: '2 Shoulder Bars',
      type: 'trim',
      primaryPath:
          'M 38 12 L 16 25 L 18 28 L 40 15 Z M 35 17 L 19 27 L 21 30 L 37 20 Z M 62 12 L 84 25 L 82 28 L 60 15 Z M 65 17 L 81 27 L 79 30 L 63 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'shoulder_1_stripe',
      name: 'Bold Shoulder Tape',
      type: 'trim',
      primaryPath:
          'M 38 12 L 15 26 L 18 30 L 41 16 Z M 62 12 L 85 26 L 82 30 L 59 16 Z',
    ),
    const GarmentDetailAsset(
      id: 'piping_chest',
      name: 'Chest Arc Piping',
      type: 'trim',
      primaryPath: 'M 26 28 Q 50 38 74 28 L 74 30 Q 50 40 26 30 Z',
    ),
    const GarmentDetailAsset(
      id: 'piping_raglan',
      name: 'Raglan Seam Piping',
      type: 'trim',
      primaryPath:
          'M 40 12 L 26 32 L 28 33 L 42 13 Z M 60 12 L 74 32 L 72 33 L 58 13 Z',
    ),
    const GarmentDetailAsset(
      id: 'side_tape',
      name: 'Vertical Side Flash',
      type: 'trim',
      primaryPath:
          'M 29 30 L 31 30 L 31 88 L 29 88 Z M 69 30 L 71 30 L 71 88 L 69 88 Z',
    ),
    const GarmentDetailAsset(
      id: 'trim_none',
      name: 'Clean (No Trim)',
      type: 'trim',
      primaryPath: '',
    ),
  ];

  static final List<GarmentDetailAsset> shortsStyles = [
    const GarmentDetailAsset(
      id: 'shorts_classic',
      name: 'Pro Match Shorts',
      type: 'shorts',
      primaryPath:
          'M 28 16 L 72 16 L 78 78 L 53 78 L 50 48 L 47 78 L 22 78 Z',
      secondaryPath:
          'M 28 16 L 72 16 L 72 23 L 28 23 Z M 22 72 L 47 72 L 47 78 L 22 78 Z M 53 72 L 78 72 L 78 78 L 53 78 Z',
    ),
    const GarmentDetailAsset(
      id: 'shorts_basketball',
      name: 'Long Hardwood Shorts',
      type: 'shorts',
      primaryPath:
          'M 26 12 L 74 12 L 80 86 L 52 86 L 50 52 L 48 86 L 20 86 Z',
      secondaryPath:
          'M 26 12 L 74 12 L 74 20 L 26 20 Z M 20 78 L 48 78 L 48 86 L 20 86 Z M 52 78 L 80 78 L 80 86 L 52 86 Z',
    ),
    const GarmentDetailAsset(
      id: 'shorts_rugby',
      name: 'Short Rugby Cut',
      type: 'shorts',
      primaryPath:
          'M 26 20 L 74 20 L 78 68 L 53 68 L 50 46 L 47 68 L 22 68 Z',
      secondaryPath: 'M 26 20 L 74 20 L 74 27 L 26 27 Z',
    ),
    const GarmentDetailAsset(
      id: 'shorts_retro',
      name: '80s Slit-Side Shorts',
      type: 'shorts',
      primaryPath:
          'M 28 18 L 72 18 L 76 66 L 70 72 L 52 72 L 50 46 L 48 72 L 30 72 L 24 66 Z',
      secondaryPath:
          'M 28 18 L 32 18 L 28 68 L 24 66 Z M 72 18 L 68 18 L 72 68 L 76 66 Z',
    ),
    const GarmentDetailAsset(
      id: 'shorts_compression',
      name: '2-in-1 Compression',
      type: 'shorts',
      primaryPath:
          'M 28 16 L 72 16 L 76 70 L 53 70 L 50 46 L 47 70 L 24 70 Z',
      secondaryPath:
          'M 26 70 L 46 70 L 46 84 L 26 84 Z M 54 70 L 74 70 L 74 84 L 54 84 Z',
    ),
  ];

  static final List<GarmentDetailAsset> socksStyles = [
    const GarmentDetailAsset(
      id: 'socks_hooped',
      name: 'Turnover Hooped Socks',
      type: 'socks',
      primaryPath:
          'M 28 12 L 44 12 L 44 72 L 54 84 L 24 84 L 28 72 Z M 56 12 L 72 12 L 72 72 L 76 84 L 46 84 L 56 72 Z',
      secondaryPath:
          'M 28 12 L 44 12 L 44 24 L 28 24 Z M 56 12 L 72 12 L 72 24 L 56 24 Z M 28 36 L 44 36 L 44 42 L 28 42 Z M 56 36 L 72 36 L 72 42 L 56 42 Z',
    ),
    const GarmentDetailAsset(
      id: 'socks_solid',
      name: 'Solid Pro Knee Socks',
      type: 'socks',
      primaryPath:
          'M 28 12 L 44 12 L 44 72 L 54 84 L 24 84 L 28 72 Z M 56 12 L 72 12 L 72 72 L 76 84 L 46 84 L 56 72 Z',
      secondaryPath:
          'M 28 12 L 44 12 L 44 20 L 28 20 Z M 56 12 L 72 12 L 72 20 L 56 20 Z',
    ),
    const GarmentDetailAsset(
      id: 'socks_striped',
      name: 'Multi-Band Guard Socks',
      type: 'socks',
      primaryPath:
          'M 28 12 L 44 12 L 44 72 L 54 84 L 24 84 L 28 72 Z M 56 12 L 72 12 L 72 72 L 76 84 L 46 84 L 56 72 Z',
      secondaryPath:
          'M 28 20 L 44 20 L 44 26 L 28 26 Z M 28 30 L 44 30 L 44 36 L 28 36 Z M 28 40 L 44 40 L 44 46 L 28 46 Z M 56 20 L 72 20 L 72 26 L 56 26 Z M 56 30 L 72 30 L 72 36 L 56 36 Z M 56 40 L 72 40 L 72 46 L 56 46 Z',
    ),
    const GarmentDetailAsset(
      id: 'socks_grip',
      name: 'Tech Grip Tape Socks',
      type: 'socks',
      primaryPath:
          'M 28 12 L 44 12 L 44 72 L 54 84 L 24 84 L 28 72 Z M 56 12 L 72 12 L 72 72 L 76 84 L 46 84 L 56 72 Z',
      secondaryPath:
          'M 28 52 L 44 52 L 44 60 L 28 60 Z M 56 52 L 72 52 L 72 60 L 56 60 Z',
    ),
  ];

  static JerseyTemplateAsset templateById(String id) =>
      templates.firstWhere((e) => e.id == id, orElse: () => templates.first);

  static GarmentDetailAsset collarById(String id) =>
      collars.firstWhere((e) => e.id == id, orElse: () => collars.first);

  static GarmentDetailAsset cuffById(String id) =>
      cuffs.firstWhere((e) => e.id == id, orElse: () => cuffs.first);

  static GarmentDetailAsset trimById(String id) =>
      trims.firstWhere((e) => e.id == id, orElse: () => trims.first);

  static GarmentDetailAsset shortsById(String id) => shortsStyles
      .firstWhere((e) => e.id == id, orElse: () => shortsStyles.first);

  static GarmentDetailAsset socksById(String id) =>
      socksStyles.firstWhere((e) => e.id == id, orElse: () => socksStyles.first);
}
