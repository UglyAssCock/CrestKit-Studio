import 'dart:math' as math;

class PatternAsset {
  final String id;
  final String name;
  final String category;
  final String svgPath;
  final bool isGradient;

  const PatternAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.svgPath,
    this.isGradient = false,
  });
}

class PatternLibrary {
  static List<PatternAsset>? _cached;

  static List<PatternAsset> get all {
    if (_cached != null) return _cached!;
    _cached = _buildAll();
    return _cached!;
  }

  static PatternAsset byId(String id) =>
      all.firstWhere((e) => e.id == id, orElse: () => all.first);

  static String _vStripes(int count, double dutyCycle) {
    final sb = StringBuffer();
    final step = 100.0 / count;
    final w = step * dutyCycle;
    for (int i = 0; i < count; i++) {
      final x1 = (i * step).toStringAsFixed(1);
      final x2 = (i * step + w).toStringAsFixed(1);
      sb.write('M $x1 0 L $x2 0 L $x2 100 L $x1 100 Z ');
    }
    return sb.toString().trim();
  }

  static String _hHoops(int count, double dutyCycle) {
    final sb = StringBuffer();
    final step = 100.0 / count;
    final h = step * dutyCycle;
    for (int i = 0; i < count; i++) {
      final y1 = (i * step).toStringAsFixed(1);
      final y2 = (i * step + h).toStringAsFixed(1);
      sb.write('M 0 $y1 L 100 $y1 L 100 $y2 L 0 $y2 Z ');
    }
    return sb.toString().trim();
  }

  static String _chevrons(int count, bool pointDown) {
    final sb = StringBuffer();
    final step = 100.0 / count;
    for (int i = 0; i < count; i++) {
      final y = i * step;
      final tip = pointDown ? y + 18 : y - 18;
      sb.write(
          'M 0 ${y.toStringAsFixed(1)} L 50 ${tip.toStringAsFixed(1)} L 100 ${y.toStringAsFixed(1)} L 100 ${(y + step * 0.45).toStringAsFixed(1)} L 50 ${(tip + step * 0.45).toStringAsFixed(1)} L 0 ${(y + step * 0.45).toStringAsFixed(1)} Z ');
    }
    return sb.toString().trim();
  }

  static String _checker(int grid) {
    final sb = StringBuffer();
    final s = 100.0 / grid;
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        if ((r + c).isEven) {
          final x1 = (c * s).toStringAsFixed(1);
          final y1 = (r * s).toStringAsFixed(1);
          final x2 = ((c + 1) * s).toStringAsFixed(1);
          final y2 = ((r + 1) * s).toStringAsFixed(1);
          sb.write('M $x1 $y1 L $x2 $y1 L $x2 $y2 L $x1 $y2 Z ');
        }
      }
    }
    return sb.toString().trim();
  }

  static String _diamonds(int grid, double scale) {
    final sb = StringBuffer();
    final s = 100.0 / grid;
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        final cx = (c + 0.5) * s;
        final cy = (r + 0.5) * s;
        final rHalf = s * 0.5 * scale;
        sb.write(
            'M ${cx.toStringAsFixed(1)} ${(cy - rHalf).toStringAsFixed(1)} L ${(cx + rHalf).toStringAsFixed(1)} ${cy.toStringAsFixed(1)} L ${cx.toStringAsFixed(1)} ${(cy + rHalf).toStringAsFixed(1)} L ${(cx - rHalf).toStringAsFixed(1)} ${cy.toStringAsFixed(1)} Z ');
      }
    }
    return sb.toString().trim();
  }

  static String _dots(int grid, double radius) {
    final sb = StringBuffer();
    final s = 100.0 / grid;
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        final cx = (c + 0.5) * s;
        final cy = (r + 0.5) * s;
        sb.write(
            'M ${cx.toStringAsFixed(1)} ${(cy - radius).toStringAsFixed(1)} A ${radius.toStringAsFixed(1)} ${radius.toStringAsFixed(1)} 0 1 0 ${cx.toStringAsFixed(1)} ${(cy + radius).toStringAsFixed(1)} A ${radius.toStringAsFixed(1)} ${radius.toStringAsFixed(1)} 0 1 0 ${cx.toStringAsFixed(1)} ${(cy - radius).toStringAsFixed(1)} Z ');
      }
    }
    return sb.toString().trim();
  }

  static String _hexGrid(int rows, int cols) {
    final sb = StringBuffer();
    final dx = 100.0 / cols;
    final dy = 100.0 / rows;
    final r = math.min(dx, dy) * 0.42;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cx = (col + (row.isOdd ? 0.75 : 0.25)) * dx;
        final cy = (row + 0.5) * dy;
        for (int k = 0; k < 6; k++) {
          final a = (k * 60.0) * math.pi / 180.0;
          final px = cx + r * math.cos(a);
          final py = cy + r * math.sin(a);
          sb.write('${k == 0 ? 'M' : 'L'} ${px.toStringAsFixed(1)} ${py.toStringAsFixed(1)} ');
        }
        sb.write('Z ');
      }
    }
    return sb.toString().trim();
  }

  static String _waves(int rows) {
    final sb = StringBuffer();
    final step = 100.0 / rows;
    for (int i = 0; i < rows; i++) {
      final y = i * step;
      sb.write(
          'M 0 ${y.toStringAsFixed(1)} Q 25 ${(y - 8).toStringAsFixed(1)} 50 ${y.toStringAsFixed(1)} Q 75 ${(y + 8).toStringAsFixed(1)} 100 ${y.toStringAsFixed(1)} L 100 ${(y + 5).toStringAsFixed(1)} Q 75 ${(y + 13).toStringAsFixed(1)} 50 ${(y + 5).toStringAsFixed(1)} Q 25 ${(y - 3).toStringAsFixed(1)} 0 ${(y + 5).toStringAsFixed(1)} Z ');
    }
    return sb.toString().trim();
  }

  static String _zigzags(int rows) {
    final sb = StringBuffer();
    final step = 100.0 / rows;
    for (int i = 0; i < rows; i++) {
      final y = i * step;
      sb.write(
          'M 0 ${y.toStringAsFixed(1)} L 20 ${(y - 7).toStringAsFixed(1)} L 40 ${y.toStringAsFixed(1)} L 60 ${(y - 7).toStringAsFixed(1)} L 80 ${y.toStringAsFixed(1)} L 100 ${(y - 7).toStringAsFixed(1)} L 100 ${(y - 1).toStringAsFixed(1)} L 80 ${(y + 6).toStringAsFixed(1)} L 60 ${(y - 1).toStringAsFixed(1)} L 40 ${(y + 6).toStringAsFixed(1)} L 20 ${(y - 1).toStringAsFixed(1)} L 0 ${(y + 6).toStringAsFixed(1)} Z ');
    }
    return sb.toString().trim();
  }

  static List<PatternAsset> _buildAll() => [
        const PatternAsset(
            id: 'solid', name: 'Solid Pure', category: 'Classic', svgPath: ''),
        PatternAsset(
            id: 'stripes_vertical',
            name: 'Classic 5 Stripes',
            category: 'Stripes',
            svgPath: _vStripes(5, 0.5)),
        PatternAsset(
            id: 'stripes_thin',
            name: 'Pinstripes (12)',
            category: 'Stripes',
            svgPath: _vStripes(12, 0.25)),
        PatternAsset(
            id: 'stripes_wide',
            name: 'Wide 3 Stripes',
            category: 'Stripes',
            svgPath: _vStripes(3, 0.5)),
        const PatternAsset(
          id: 'stripes_uneven',
          name: 'Uneven Barcode Stripes',
          category: 'Stripes',
          svgPath:
              'M 10 0 L 18 0 L 18 100 L 10 100 Z M 24 0 L 28 0 L 28 100 L 24 100 Z M 38 0 L 62 0 L 62 100 L 38 100 Z M 72 0 L 76 0 L 76 100 L 72 100 Z M 82 0 L 90 0 L 90 100 L 82 100 Z',
        ),
        const PatternAsset(
          id: 'stripes_center_band',
          name: 'Ajax Center Pillar',
          category: 'Stripes',
          svgPath: 'M 34 0 L 66 0 L 66 100 L 34 100 Z',
        ),
        const PatternAsset(
          id: 'stripes_double_center',
          name: 'Twin Racing Stripes',
          category: 'Stripes',
          svgPath:
              'M 36 0 L 46 0 L 46 100 L 36 100 Z M 54 0 L 64 0 L 64 100 L 54 100 Z',
        ),
        PatternAsset(
            id: 'hoops_horizontal',
            name: 'Celtic 6 Hoops',
            category: 'Hoops & Sashes',
            svgPath: _hHoops(6, 0.5)),
        PatternAsset(
            id: 'hoops_thin',
            name: 'Fine 10 Hoops',
            category: 'Hoops & Sashes',
            svgPath: _hHoops(10, 0.35)),
        PatternAsset(
            id: 'hoops_wide',
            name: 'Broad 3 Hoops',
            category: 'Hoops & Sashes',
            svgPath: _hHoops(3, 0.5)),
        const PatternAsset(
          id: 'chest_band',
          name: 'Boca Chest Ring',
          category: 'Hoops & Sashes',
          svgPath: 'M 0 32 L 100 32 L 100 54 L 0 54 Z',
        ),
        const PatternAsset(
          id: 'sash_right',
          name: 'River Diagonal Sash',
          category: 'Hoops & Sashes',
          svgPath: 'M 0 16 L 18 0 L 100 82 L 82 100 Z',
        ),
        const PatternAsset(
          id: 'sash_left',
          name: 'Reverse Diagonal Sash',
          category: 'Hoops & Sashes',
          svgPath: 'M 82 0 L 100 16 L 18 100 L 0 82 Z',
        ),
        const PatternAsset(
          id: 'sash_double',
          name: 'Double Diagonal Sash',
          category: 'Hoops & Sashes',
          svgPath:
              'M 0 8 L 12 0 L 100 88 L 88 96 Z M 0 26 L 10 18 L 88 96 L 78 100 Z',
        ),
        const PatternAsset(
          id: 'diagonal_stripes',
          name: 'Diagonal Repeat Bars',
          category: 'Hoops & Sashes',
          svgPath:
              'M 0 0 L 20 0 L 0 20 Z M 40 0 L 60 0 L 0 60 L 0 40 Z M 80 0 L 100 0 L 0 100 L 0 80 Z M 100 20 L 100 40 L 40 100 L 20 100 Z M 100 60 L 100 80 L 80 100 L 60 100 Z',
        ),
        PatternAsset(
            id: 'chevron_down',
            name: 'Velez V-Chevron',
            category: 'Geometric',
            svgPath: _chevrons(2, true)),
        PatternAsset(
            id: 'chevron_up',
            name: 'Ascending Chevrons',
            category: 'Geometric',
            svgPath: _chevrons(3, false)),
        PatternAsset(
            id: 'chevron_multi',
            name: 'Multi-Chevron Armor',
            category: 'Geometric',
            svgPath: _chevrons(6, true)),
        PatternAsset(
            id: 'checkerboard',
            name: 'Croatia Checker (6x6)',
            category: 'Geometric',
            svgPath: _checker(6)),
        PatternAsset(
            id: 'checker_small',
            name: 'Micro Racing Check (10x10)',
            category: 'Geometric',
            svgPath: _checker(10)),
        PatternAsset(
            id: 'harlequin',
            name: 'Monaco Harlequin Diamonds',
            category: 'Geometric',
            svgPath: _diamonds(5, 0.95)),
        PatternAsset(
            id: 'argyle',
            name: 'Heritage Argyle Grid',
            category: 'Geometric',
            svgPath: _diamonds(4, 0.7)),
        const PatternAsset(
          id: 'houndstooth',
          name: 'Classic Houndstooth',
          category: 'Geometric',
          svgPath:
              'M 10 10 L 30 10 L 40 0 L 40 20 L 30 30 L 10 30 Z M 60 10 L 80 10 L 90 0 L 90 20 L 80 30 L 60 30 Z M 10 60 L 30 60 L 40 50 L 40 70 L 30 80 L 10 80 Z M 60 60 L 80 60 L 90 50 L 90 70 L 80 80 L 60 80 Z',
        ),
        const PatternAsset(
            id: 'gradient_vertical',
            name: 'Vertical Fade Gradient',
            category: 'Gradients',
            svgPath: '',
            isGradient: true),
        const PatternAsset(
            id: 'gradient_horizontal',
            name: 'Horizontal Fade Gradient',
            category: 'Gradients',
            svgPath: '',
            isGradient: true),
        const PatternAsset(
            id: 'gradient_radial',
            name: 'Core Radial Burst',
            category: 'Gradients',
            svgPath: '',
            isGradient: true),
        const PatternAsset(
          id: 'camo_woodland',
          name: 'Woodland Camo',
          category: 'Camo & Wild',
          svgPath:
              'M 10 12 Q 34 4 46 22 Q 30 38 12 28 Z M 58 18 Q 88 10 92 36 Q 70 48 54 32 Z M 18 54 Q 48 42 56 68 Q 34 86 12 72 Z M 64 60 Q 92 54 88 86 Q 62 94 58 74 Z',
        ),
        const PatternAsset(
          id: 'camo_urban',
          name: 'Angular Splinter Camo',
          category: 'Camo & Wild',
          svgPath:
              'M 6 8 L 42 14 L 30 38 L 8 28 Z M 56 6 L 94 22 L 76 46 L 52 28 Z M 14 52 L 54 48 L 42 84 L 8 76 Z M 62 56 L 94 64 L 82 94 L 54 82 Z',
        ),
        const PatternAsset(
          id: 'camo_digital',
          name: 'Digital Pixel Camo',
          category: 'Camo & Wild',
          svgPath:
              'M 10 10 L 30 10 L 30 20 L 40 20 L 40 30 L 10 30 Z M 60 15 L 85 15 L 85 35 L 70 35 L 70 25 L 60 25 Z M 20 55 L 50 55 L 50 75 L 30 75 L 30 85 L 20 85 Z M 65 60 L 90 60 L 90 85 L 65 85 Z',
        ),
        PatternAsset(
            id: 'leopard_spots',
            name: 'Leopard Rosettes',
            category: 'Camo & Wild',
            svgPath: _dots(5, 6.5)),
        const PatternAsset(
          id: 'tiger_stripes',
          name: 'Bengal Tiger Slash',
          category: 'Camo & Wild',
          svgPath:
              'M 0 12 Q 36 22 68 8 L 42 26 Q 18 28 0 22 Z M 100 28 Q 62 38 28 32 L 58 46 Q 82 44 100 38 Z M 0 54 Q 44 64 78 52 L 48 68 Q 20 70 0 64 Z M 100 74 Q 58 86 22 76 L 56 92 Q 82 90 100 84 Z',
        ),
        const PatternAsset(
          id: 'zebra_stripes',
          name: 'Savanna Zebra Waves',
          category: 'Camo & Wild',
          svgPath:
              'M 0 8 Q 30 24 60 6 Q 80 0 100 14 L 100 24 Q 76 12 56 20 Q 28 36 0 18 Z M 0 42 Q 36 58 68 38 L 100 48 L 100 58 L 66 50 Q 34 70 0 52 Z M 0 76 Q 34 92 70 72 L 100 82 L 100 92 L 68 84 Q 34 102 0 86 Z',
        ),
        PatternAsset(
            id: 'snakeskin',
            name: 'Viper Scale Mesh',
            category: 'Camo & Wild',
            svgPath: _diamonds(8, 0.85)),
        PatternAsset(
            id: 'polka_dots',
            name: 'King of the Mountains Dots',
            category: 'Modern & Tech',
            svgPath: _dots(4, 7.5)),
        PatternAsset(
            id: 'micro_dots',
            name: 'Halftone Matrix Dots',
            category: 'Modern & Tech',
            svgPath: _dots(9, 2.6)),
        const PatternAsset(
          id: 'triangles_grid',
          name: 'Prism Triangle Tessellation',
          category: 'Geometric',
          svgPath:
              'M 0 0 L 25 0 L 12.5 25 Z M 25 0 L 50 0 L 37.5 25 Z M 50 0 L 75 0 L 62.5 25 Z M 75 0 L 100 0 L 87.5 25 Z M 12.5 25 L 37.5 25 L 25 50 Z M 37.5 25 L 62.5 25 L 50 50 Z M 62.5 25 L 87.5 25 L 75 50 Z M 0 50 L 25 50 L 12.5 75 Z M 25 50 L 50 50 L 37.5 75 Z M 50 50 L 75 50 L 62.5 75 Z M 75 50 L 100 50 L 87.5 75 Z',
        ),
        PatternAsset(
            id: 'hex_mesh',
            name: 'Hexagon Cyber Mesh',
            category: 'Modern & Tech',
            svgPath: _hexGrid(5, 5)),
        PatternAsset(
            id: 'honeycomb',
            name: 'Dense Honeycomb Cells',
            category: 'Modern & Tech',
            svgPath: _hexGrid(8, 8)),
        PatternAsset(
            id: 'ocean_wave',
            name: 'Atlantic Wave Currents',
            category: 'Organic',
            svgPath: _waves(6)),
        const PatternAsset(
          id: 'flame_licks',
          name: 'Inferno Rising Flames',
          category: 'Organic',
          svgPath:
              'M 0 100 L 12 62 L 22 78 L 36 44 L 48 72 L 62 36 L 74 68 L 88 52 L 100 100 Z',
        ),
        const PatternAsset(
          id: 'lightning_bolts',
          name: 'High-Voltage Storm',
          category: 'Organic',
          svgPath:
              'M 28 0 L 8 46 L 26 46 L 12 96 L 46 40 L 26 40 Z M 78 4 L 54 52 L 74 52 L 58 100 L 94 44 L 72 44 Z',
        ),
        const PatternAsset(
          id: 'paint_splatter',
          name: 'Street Art Paint Splatter',
          category: 'Organic',
          svgPath:
              'M 26 22 Q 38 12 44 26 Q 58 24 48 38 Q 54 52 38 46 Q 22 54 24 36 Q 12 28 26 22 Z M 72 64 Q 84 56 88 70 Q 96 78 82 84 Q 72 94 66 80 Q 54 74 72 64 Z M 18 74 A 6 6 0 1 0 30 74 A 6 6 0 1 0 18 74 Z M 68 20 A 5 5 0 1 0 78 20 A 5 5 0 1 0 68 20 Z',
        ),
        const PatternAsset(
          id: 'brush_stroke',
          name: 'Sumi-e Brush Strokes',
          category: 'Organic',
          svgPath:
              'M 4 18 L 94 12 L 88 26 L 8 30 Z M 12 48 L 96 42 L 90 58 L 6 58 Z M 6 76 L 92 72 L 84 88 L 14 88 Z',
        ),
        const PatternAsset(
          id: 'smoke_haze',
          name: 'Flare Smoke Swirls',
          category: 'Organic',
          svgPath:
              'M 10 30 Q 40 5 65 30 T 95 25 L 95 45 Q 65 65 40 40 T 10 50 Z M 5 75 Q 35 50 65 75 T 95 70 L 95 90 Q 65 105 35 85 T 5 90 Z',
        ),
        const PatternAsset(
          id: 'ink_blot',
          name: 'Rorschach Symmetry Ink',
          category: 'Organic',
          svgPath:
              'M 50 10 Q 78 18 68 42 Q 88 56 64 76 L 50 90 L 36 76 Q 12 56 32 42 Q 22 18 50 10 Z',
        ),
        const PatternAsset(
          id: 'grunge_texture',
          name: 'Distressed Concrete Grunge',
          category: 'Organic',
          svgPath:
              'M 8 12 L 26 16 L 18 28 Z M 64 8 L 88 14 L 74 26 Z M 36 38 L 58 34 L 48 52 Z M 12 62 L 32 58 L 24 78 Z M 68 58 L 92 66 L 78 86 Z M 42 82 L 58 78 L 52 94 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_1',
          name: 'Sublimation Shard V1',
          category: 'Sublimation',
          svgPath:
              'M 0 0 L 50 32 L 100 0 L 100 22 L 50 54 L 0 22 Z M 0 46 L 50 78 L 100 46 L 100 68 L 50 100 L 0 68 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_2',
          name: 'Sublimation Origami V2',
          category: 'Sublimation',
          svgPath:
              'M 0 0 L 42 28 L 0 56 Z M 100 0 L 58 28 L 100 56 Z M 50 34 L 84 68 L 50 100 L 16 68 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_3',
          name: 'Sublimation Sonic Pulse V3',
          category: 'Sublimation',
          svgPath:
              'M 50 10 L 90 50 L 50 90 L 10 50 Z M 50 28 L 72 50 L 50 72 L 28 50 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_4',
          name: 'Sublimation Wing Fracture V4',
          category: 'Sublimation',
          svgPath:
              'M 0 12 L 46 38 L 38 52 L 0 34 Z M 100 12 L 54 38 L 62 52 L 100 34 Z M 0 56 L 44 78 L 36 92 L 0 74 Z M 100 56 L 56 78 L 64 92 L 100 74 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_5',
          name: 'Sublimation Speed Lines V5',
          category: 'Sublimation',
          svgPath:
              'M 12 0 L 22 0 L 6 100 L 0 100 Z M 34 0 L 42 0 L 26 100 L 18 100 Z M 58 0 L 66 0 L 82 100 L 74 100 Z M 78 0 L 88 0 L 100 100 L 94 100 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_6',
          name: 'Sublimation Prism Burst V6',
          category: 'Sublimation',
          svgPath:
              'M 50 50 L 0 0 L 24 0 Z M 50 50 L 76 0 L 100 0 Z M 50 50 L 100 36 L 100 64 Z M 50 50 L 100 100 L 76 100 Z M 50 50 L 24 100 L 0 100 Z M 50 50 L 0 64 L 0 36 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_7',
          name: 'Sublimation Cyber Grid V7',
          category: 'Sublimation',
          svgPath:
              'M 0 20 L 100 20 L 100 23 L 0 23 Z M 0 50 L 100 50 L 100 53 L 0 53 Z M 0 80 L 100 80 L 100 83 L 0 83 Z M 20 0 L 23 0 L 23 100 L 20 100 Z M 50 0 L 53 0 L 53 100 L 50 100 Z M 80 0 L 83 0 L 83 100 L 80 100 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_8',
          name: 'Sublimation Arrowhead V8',
          category: 'Sublimation',
          svgPath:
              'M 50 4 L 86 36 L 70 36 L 50 18 L 30 36 L 14 36 Z M 50 38 L 86 70 L 70 70 L 50 52 L 30 70 L 14 70 Z M 50 72 L 86 100 L 70 100 L 50 84 L 30 100 L 14 100 Z',
        ),
        const PatternAsset(
          id: 'sublimation_geo_9',
          name: 'Sublimation Isometric Cube V9',
          category: 'Sublimation',
          svgPath:
              'M 50 12 L 84 30 L 50 48 L 16 30 Z M 16 30 L 50 48 L 50 86 L 16 68 Z',
        ),
        PatternAsset(
          id: 'sublimation_geo_10',
          name: 'Sublimation Bruised Banana V10',
          category: 'Sublimation',
          svgPath: _zigzags(5),
        ),
        const PatternAsset(
          id: 'aztec_tribal',
          name: 'Aztec Temple Frieze',
          category: 'Retro & Heritage',
          svgPath:
              'M 0 20 L 20 20 L 20 10 L 40 10 L 40 20 L 60 20 L 60 10 L 80 10 L 80 20 L 100 20 L 100 32 L 0 32 Z M 0 68 L 20 68 L 20 58 L 40 58 L 40 68 L 60 68 L 60 58 L 80 58 L 80 68 L 100 68 L 100 80 L 0 80 Z',
        ),
        PatternAsset(
            id: 'mosaic_tiles',
            name: 'Gaudí Mosaic Tiles',
            category: 'Geometric',
            svgPath: _diamonds(7, 0.65)),
        PatternAsset(
            id: 'pixel_matrix',
            name: '8-Bit Arcade Matrix',
            category: 'Modern & Tech',
            svgPath: _checker(8)),
        const PatternAsset(
          id: 'circuit_board',
          name: 'Motherboard Circuit Traces',
          category: 'Modern & Tech',
          svgPath:
              'M 10 10 L 40 10 L 55 25 L 55 60 L 50 60 L 50 27 L 38 15 L 10 15 Z M 85 15 L 65 35 L 65 85 L 60 85 L 60 33 L 82 11 Z M 20 45 L 35 60 L 35 90 L 30 90 L 30 62 L 16 48 Z',
        ),
        PatternAsset(
            id: 'carbon_fiber',
            name: 'Carbon Fiber Weave',
            category: 'Modern & Tech',
            svgPath: _checker(12)),
        PatternAsset(
            id: 'breathable_mesh',
            name: 'Aero Perforated Mesh',
            category: 'Modern & Tech',
            svgPath: _dots(10, 1.8)),
        const PatternAsset(
          id: 'half_and_half',
          name: 'Blackburn Half & Half',
          category: 'Classic',
          svgPath: 'M 50 0 L 100 0 L 100 100 L 50 100 Z',
        ),
        const PatternAsset(
          id: 'quartered_kit',
          name: 'Bristol Quartered Field',
          category: 'Classic',
          svgPath:
              'M 0 0 L 50 0 L 50 50 L 0 50 Z M 50 50 L 100 50 L 100 100 L 50 100 Z',
        ),
        const PatternAsset(
          id: 'stars_scatter',
          name: 'Champions Star Constellation',
          category: 'Retro & Heritage',
          svgPath:
              'M 22 14 L 25 22 L 33 22 L 27 27 L 29 35 L 22 30 L 15 35 L 17 27 L 11 22 L 19 22 Z M 76 20 L 79 28 L 87 28 L 81 33 L 83 41 L 76 36 L 69 41 L 71 33 L 65 28 L 73 28 Z M 48 56 L 51 64 L 59 64 L 53 69 L 55 77 L 48 72 L 41 77 L 43 69 L 37 64 L 45 64 Z',
        ),
        const PatternAsset(
          id: 'sunburst_center',
          name: 'Radial Sunburst Rays',
          category: 'Retro & Heritage',
          svgPath:
              'M 50 50 L 42 0 L 58 0 Z M 50 50 L 86 0 L 100 14 Z M 50 50 L 100 42 L 100 58 Z M 50 50 L 100 86 L 86 100 Z M 50 50 L 58 100 L 42 100 Z M 50 50 L 14 100 L 0 86 Z M 50 50 L 0 58 L 0 42 Z M 50 50 L 0 14 L 14 0 Z',
        ),
        const PatternAsset(
          id: 'rising_rays',
          name: 'Horizon Rising Rays',
          category: 'Retro & Heritage',
          svgPath:
              'M 50 100 L 0 70 L 0 50 Z M 50 100 L 0 20 L 16 0 Z M 50 100 L 40 0 L 60 0 Z M 50 100 L 84 0 L 100 20 Z M 50 100 L 100 50 L 100 70 Z',
        ),
        PatternAsset(
            id: 'retro_70s_waves',
            name: 'Retro 70s Groovy Waves',
            category: 'Retro & Heritage',
            svgPath: _waves(4)),
        PatternAsset(
            id: 'retro_90s_zigzags',
            name: 'Retro 90s Keeper Zigzags',
            category: 'Retro & Heritage',
            svgPath: _zigzags(4)),
        const PatternAsset(
          id: 'cross_st_george_kit',
          name: 'Inter / England Cross',
          category: 'Classic',
          svgPath:
              'M 42 0 L 58 0 L 58 36 L 100 36 L 100 52 L 58 52 L 58 100 L 42 100 L 42 52 L 0 52 L 0 36 L 42 36 Z',
        ),
      ];
}
