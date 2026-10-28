import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/divisions.dart';
import '../data/elements.dart';
import '../data/patterns.dart';
import '../data/shields.dart';
import '../utils/svg_parser.dart';

class AssetLibrarySheet extends StatefulWidget {
  final SharedPreferences prefs;
  final ValueChanged<ShieldAsset> onSelectShield;
  final ValueChanged<DivisionAsset> onSelectDivision;
  final ValueChanged<EmblemAsset> onInsertEmblem;
  final ValueChanged<PatternAsset> onSelectPattern;
  final VoidCallback onRandomizeAll;
  final VoidCallback onMixCrest;

  const AssetLibrarySheet({
    super.key,
    required this.prefs,
    required this.onSelectShield,
    required this.onSelectDivision,
    required this.onInsertEmblem,
    required this.onSelectPattern,
    required this.onRandomizeAll,
    required this.onMixCrest,
  });

  @override
  State<AssetLibrarySheet> createState() => _AssetLibrarySheetState();
}

class _AssetLibrarySheetState extends State<AssetLibrarySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedElementCategory = 'All';
  late Set<String> _favorites;
  late List<String> _recentIds;
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _favorites =
        (widget.prefs.getStringList('fav_assets') ?? const <String>[]).toSet();
    _recentIds =
        List<String>.from(widget.prefs.getStringList('recent_assets') ?? []);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
      widget.prefs.setStringList('fav_assets', _favorites.toList());
    });
  }

  void _recordRecent(String id) {
    _recentIds.remove(id);
    _recentIds.insert(0, id);
    if (_recentIds.length > 24) _recentIds.removeLast();
    widget.prefs.setStringList('recent_assets', _recentIds);
  }

  @override
  Widget build(BuildContext context) {
    final shields = ShieldLibrary.all.where((s) {
      final matchesSearch =
          s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFav = !_onlyFavorites || _favorites.contains(s.id);
      return matchesSearch && matchesFav;
    }).toList();

    final divisions = DivisionLibrary.all.where((d) {
      final matchesSearch =
          d.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFav = !_onlyFavorites || _favorites.contains(d.id);
      return matchesSearch && matchesFav;
    }).toList();

    final elements = ElementLibrary.all.where((e) {
      final matchesCat = _selectedElementCategory == 'All' ||
          e.category == _selectedElementCategory;
      final matchesSearch =
          e.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFav = !_onlyFavorites || _favorites.contains(e.id);
      return matchesCat && matchesSearch && matchesFav;
    }).toList();

    final patterns = PatternLibrary.all.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFav = !_onlyFavorites || _favorites.contains(p.id);
      return matchesSearch && matchesFav;
    }).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF00E5A3)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '2D Vector Asset Library',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.shuffle, size: 16),
                    label: const Text('Mix Crest'),
                    onPressed: () {
                      widget.onMixCrest();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    avatar: const Icon(Icons.casino, size: 16),
                    label: const Text('Randomize'),
                    onPressed: () {
                      widget.onRandomizeAll();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search shields, lions, crowns, patterns...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: _onlyFavorites,
                    label: Text('Favs (${_favorites.length})'),
                    avatar: Icon(
                      _onlyFavorites ? Icons.star : Icons.star_border,
                      size: 16,
                    ),
                    onSelected: (v) => setState(() => _onlyFavorites = v),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: 'Emblems (${elements.length})'),
                Tab(text: 'Shields (${shields.length})'),
                Tab(text: 'Divisions (${divisions.length})'),
                Tab(text: 'Patterns (${patterns.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Emblems with category filter chips
                  Column(
                    children: [
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: ElementLibrary.categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (context, idx) {
                            final cat = ElementLibrary.categories[idx];
                            final selected = _selectedElementCategory == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: selected,
                              onSelected: (_) => setState(
                                () => _selectedElementCategory = cat,
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: elements.length,
                          itemBuilder: (context, index) {
                            final item = elements[index];
                            return _buildPathCard(
                              id: item.id,
                              title: item.name,
                              svgPath: item.path,
                              color: const Color(0xFFD4AF37),
                              onTap: () {
                                _recordRecent(item.id);
                                widget.onInsertEmblem(item);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Shields
                  GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: shields.length,
                    itemBuilder: (context, index) {
                      final item = shields[index];
                      return _buildPathCard(
                        id: item.id,
                        title: item.name,
                        svgPath: item.path,
                        color: const Color(0xFF00E5A3),
                        onTap: () {
                          _recordRecent(item.id);
                          widget.onSelectShield(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),

                  // Tab 3: Heraldic Divisions
                  GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: divisions.length,
                    itemBuilder: (context, index) {
                      final item = divisions[index];
                      return _buildPathCard(
                        id: item.id,
                        title: item.name,
                        svgPath: item.path,
                        color: const Color(0xFF38BDF8),
                        onTap: () {
                          _recordRecent(item.id);
                          widget.onSelectDivision(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),

                  // Tab 4: Patterns
                  GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: patterns.length,
                    itemBuilder: (context, index) {
                      final item = patterns[index];
                      return _buildPathCard(
                        id: item.id,
                        title: item.name,
                        svgPath: item.svgPath,
                        color: const Color(0xFFF43F5E),
                        onTap: () {
                          _recordRecent(item.id);
                          widget.onSelectPattern(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathCard({
    required String id,
    required String title,
    required String svgPath,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isFav = _favorites.contains(id);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => _toggleFavorite(id),
                child: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  size: 15,
                  color: isFav ? Colors.amber : Colors.white38,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CustomPaint(
                  size: const Size(52, 52),
                  painter: _PathThumbPainter(svgPath: svgPath, color: color),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathThumbPainter extends CustomPainter {
  final String svgPath;
  final Color color;

  const _PathThumbPainter({required this.svgPath, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (svgPath.isEmpty) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
        Paint()..color = color.withOpacity(0.5),
      );
      return;
    }
    final unit = SvgPathParser.parse(svgPath);
    final scaled = SvgPathParser.scalePath(unit, size);
    canvas.drawPath(
      scaled,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color
        ..isAntiAlias = true,
    );
    canvas.drawPath(
      scaled,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.45)
        ..strokeWidth = math.max(1.0, size.width * 0.025)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _PathThumbPainter oldDelegate) =>
      oldDelegate.svgPath != svgPath || oldDelegate.color != color;
}
