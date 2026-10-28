class DivisionAsset {
  final String id;
  final String name;
  final String category;
  final String path;

  const DivisionAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.path,
  });
}

class DivisionLibrary {
  static String _stripesV(int count) {
    final sb = StringBuffer();
    final step = 100.0 / (count * 2);
    for (int i = 0; i < count; i++) {
      final x1 = (i * 2 * step).toStringAsFixed(1);
      final x2 = ((i * 2 + 1) * step).toStringAsFixed(1);
      sb.write('M $x1 0 L $x2 0 L $x2 100 L $x1 100 Z ');
    }
    return sb.toString().trim();
  }

  static String _stripesH(int count) {
    final sb = StringBuffer();
    final step = 100.0 / (count * 2);
    for (int i = 0; i < count; i++) {
      final y1 = (i * 2 * step).toStringAsFixed(1);
      final y2 = ((i * 2 + 1) * step).toStringAsFixed(1);
      sb.write('M 0 $y1 L 100 $y1 L 100 $y2 L 0 $y2 Z ');
    }
    return sb.toString().trim();
  }

  static String _chequy(int grid) {
    final sb = StringBuffer();
    final size = 100.0 / grid;
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        if ((r + c).isEven) {
          final x1 = (c * size).toStringAsFixed(1);
          final y1 = (r * size).toStringAsFixed(1);
          final x2 = ((c + 1) * size).toStringAsFixed(1);
          final y2 = ((r + 1) * size).toStringAsFixed(1);
          sb.write('M $x1 $y1 L $x2 $y1 L $x2 $y2 L $x1 $y2 Z ');
        }
      }
    }
    return sb.toString().trim();
  }

  static String _lozengy(int grid) {
    final sb = StringBuffer();
    final size = 100.0 / grid;
    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        final cx = (c + 0.5) * size;
        final cy = (r + 0.5) * size;
        final half = size * 0.5;
        sb.write(
            'M ${cx.toStringAsFixed(1)} ${(cy - half).toStringAsFixed(1)} L ${(cx + half).toStringAsFixed(1)} ${cy.toStringAsFixed(1)} L ${cx.toStringAsFixed(1)} ${(cy + half).toStringAsFixed(1)} L ${(cx - half).toStringAsFixed(1)} ${cy.toStringAsFixed(1)} Z ');
      }
    }
    return sb.toString().trim();
  }

  static final List<DivisionAsset> all = [
    const DivisionAsset(
      id: 'solid',
      name: 'Solid Field',
      category: 'Classic',
      path: 'M 0 0 L 0 0 Z',
    ),
    const DivisionAsset(
      id: 'per_pale',
      name: 'Per Pale (Vertical Split)',
      category: 'Partitions',
      path: 'M 50 0 L 100 0 L 100 100 L 50 100 Z',
    ),
    const DivisionAsset(
      id: 'per_fess',
      name: 'Per Fess (Horizontal Split)',
      category: 'Partitions',
      path: 'M 0 50 L 100 50 L 100 100 L 0 100 Z',
    ),
    const DivisionAsset(
      id: 'per_bend',
      name: 'Per Bend (Diagonal)',
      category: 'Partitions',
      path: 'M 0 0 L 100 0 L 100 100 Z',
    ),
    const DivisionAsset(
      id: 'per_bend_sinister',
      name: 'Per Bend Sinister',
      category: 'Partitions',
      path: 'M 0 0 L 100 0 L 0 100 Z',
    ),
    const DivisionAsset(
      id: 'per_chevron',
      name: 'Per Chevron',
      category: 'Partitions',
      path: 'M 0 100 L 50 45 L 100 100 Z',
    ),
    const DivisionAsset(
      id: 'per_saltire',
      name: 'Per Saltire',
      category: 'Partitions',
      path: 'M 0 0 L 100 0 L 50 50 Z M 0 100 L 100 100 L 50 50 Z',
    ),
    const DivisionAsset(
      id: 'quartered',
      name: 'Quartered (Quarterly)',
      category: 'Partitions',
      path: 'M 0 0 L 50 0 L 50 50 L 0 50 Z M 50 50 L 100 50 L 100 100 L 50 100 Z',
    ),
    const DivisionAsset(
      id: 'tierced_pale',
      name: 'Tierced in Pale',
      category: 'Partitions',
      path: 'M 33.3 0 L 66.6 0 L 66.6 100 L 33.3 100 Z',
    ),
    const DivisionAsset(
      id: 'tierced_fess',
      name: 'Tierced in Fess',
      category: 'Partitions',
      path: 'M 0 33.3 L 100 33.3 L 100 66.6 L 0 66.6 Z',
    ),
    const DivisionAsset(
      id: 'pall',
      name: 'Heraldic Pall (Y)',
      category: 'Ordinaries',
      path: 'M 0 0 L 18 0 L 50 42 L 82 0 L 100 0 L 58 52 L 58 100 L 42 100 L 42 52 Z',
    ),
    const DivisionAsset(
      id: 'pile',
      name: 'Heraldic Pile (V)',
      category: 'Ordinaries',
      path: 'M 20 0 L 80 0 L 50 90 Z',
    ),
    const DivisionAsset(
      id: 'chief',
      name: 'Chief (Top Band)',
      category: 'Ordinaries',
      path: 'M 0 0 L 100 0 L 100 28 L 0 28 Z',
    ),
    const DivisionAsset(
      id: 'base_band',
      name: 'Base (Bottom Band)',
      category: 'Ordinaries',
      path: 'M 0 72 L 100 72 L 100 100 L 0 100 Z',
    ),
    const DivisionAsset(
      id: 'canton',
      name: 'Canton (Top Left Corner)',
      category: 'Ordinaries',
      path: 'M 0 0 L 40 0 L 40 40 L 0 40 Z',
    ),
    const DivisionAsset(
      id: 'cross_st_george',
      name: 'St George Cross',
      category: 'Crosses',
      path: 'M 40 0 L 60 0 L 60 40 L 100 40 L 100 60 L 60 60 L 60 100 L 40 100 L 40 60 L 0 60 L 0 40 L 40 40 Z',
    ),
    const DivisionAsset(
      id: 'cross_nordic',
      name: 'Nordic Offset Cross',
      category: 'Crosses',
      path: 'M 28 0 L 44 0 L 44 42 L 100 42 L 100 58 L 44 58 L 44 100 L 28 100 L 28 58 L 0 58 L 0 42 L 28 42 Z',
    ),
    const DivisionAsset(
      id: 'cross_st_andrew',
      name: 'St Andrew Saltire',
      category: 'Crosses',
      path: 'M 0 12 L 12 0 L 50 38 L 88 0 L 100 12 L 62 50 L 100 88 L 88 100 L 50 62 L 12 100 L 0 88 L 38 50 Z',
    ),
    const DivisionAsset(
      id: 'cross_maltese',
      name: 'Maltese Cross Field',
      category: 'Crosses',
      path: 'M 50 42 L 32 14 L 50 22 L 68 14 Z M 58 50 L 86 32 L 78 50 L 86 68 Z M 50 58 L 68 86 L 50 78 L 32 86 Z M 42 50 L 14 68 L 22 50 L 14 32 Z',
    ),
    const DivisionAsset(
      id: 'cross_celtic',
      name: 'Celtic Ring Cross',
      category: 'Crosses',
      path: 'M 42 0 L 58 0 L 58 100 L 42 100 Z M 0 42 L 100 42 L 100 58 L 0 58 Z M 50 26 A 24 24 0 1 0 50 74 A 24 24 0 1 0 50 26 Z',
    ),
    const DivisionAsset(
      id: 'chevron_single',
      name: 'Chevron',
      category: 'Ordinaries',
      path: 'M 0 70 L 50 30 L 100 70 L 100 88 L 50 48 L 0 88 Z',
    ),
    const DivisionAsset(
      id: 'chevron_double',
      name: 'Double Chevron',
      category: 'Ordinaries',
      path: 'M 0 60 L 50 20 L 100 60 L 100 72 L 50 32 L 0 72 Z M 0 84 L 50 44 L 100 84 L 100 96 L 50 56 L 0 96 Z',
    ),
    const DivisionAsset(
      id: 'bend_sash',
      name: 'Bend (Diagonal Sash)',
      category: 'Ordinaries',
      path: 'M 0 18 L 18 0 L 100 82 L 82 100 Z',
    ),
    const DivisionAsset(
      id: 'bend_sinister_sash',
      name: 'Bend Sinister Sash',
      category: 'Ordinaries',
      path: 'M 82 0 L 100 18 L 18 100 L 0 82 Z',
    ),
    DivisionAsset(
      id: 'paly_4',
      name: 'Paly (4 Stripes)',
      category: 'Stripes',
      path: _stripesV(4),
    ),
    DivisionAsset(
      id: 'paly_6',
      name: 'Paly (6 Stripes)',
      category: 'Stripes',
      path: _stripesV(6),
    ),
    DivisionAsset(
      id: 'barry_4',
      name: 'Barry (4 Hoops)',
      category: 'Stripes',
      path: _stripesH(4),
    ),
    DivisionAsset(
      id: 'barry_6',
      name: 'Barry (6 Hoops)',
      category: 'Stripes',
      path: _stripesH(6),
    ),
    DivisionAsset(
      id: 'chequy_4',
      name: 'Chequy (4x4)',
      category: 'Patterns',
      path: _chequy(4),
    ),
    DivisionAsset(
      id: 'chequy_6',
      name: 'Chequy Flag (6x6)',
      category: 'Patterns',
      path: _chequy(6),
    ),
    DivisionAsset(
      id: 'lozengy_4',
      name: 'Lozengy Diamonds',
      category: 'Patterns',
      path: _lozengy(4),
    ),
    DivisionAsset(
      id: 'fusilly_6',
      name: 'Fusilly Bavarian',
      category: 'Patterns',
      path: _lozengy(6),
    ),
    const DivisionAsset(
      id: 'gyronny',
      name: 'Gyronny of 8',
      category: 'Patterns',
      path: 'M 50 50 L 50 0 L 100 0 Z M 50 50 L 100 50 L 100 100 Z M 50 50 L 50 100 L 0 100 Z M 50 50 L 0 50 L 0 0 Z',
    ),
    const DivisionAsset(
      id: 'stars_field',
      name: 'Stars Scatter Field',
      category: 'Patterns',
      path: 'M 25 18 L 28 26 L 36 26 L 30 31 L 32 39 L 25 34 L 18 39 L 20 31 L 14 26 L 22 26 Z M 75 18 L 78 26 L 86 26 L 80 31 L 82 39 L 75 34 L 68 39 L 70 31 L 64 26 L 72 26 Z M 50 58 L 53 66 L 61 66 L 55 71 L 57 79 L 50 74 L 43 79 L 45 71 L 39 66 L 47 66 Z',
    ),
  ];

  static DivisionAsset byId(String id) {
    return all.firstWhere((e) => e.id == id, orElse: () => all.first);
  }
}
