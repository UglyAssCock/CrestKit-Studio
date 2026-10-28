import 'package:flutter/material.dart';
import '../data/shields.dart';
import '../data/divisions.dart';
import '../data/elements.dart';
import '../data/patterns.dart';
import '../data/jerseys.dart';
import '../data/presets.dart';
import '../utils/svg_parser.dart';

class AssetLibrarySheet extends StatefulWidget {
  final int initialTab;
  final ValueChanged<ShieldAsset> onSelectShield;
  final ValueChanged<DivisionAsset> onSelectDivision;
  final ValueChanged<EmblemAsset> onSelectElement;
  final ValueChanged<PatternAsset> onSelectPattern;
  final ValueChanged<JerseyTemplateAsset> onSelectTemplate;
  final ValueChanged<KitPresetData> onSelectPresetKit;
  final VoidCallback onRandomMix;

  const AssetLibrarySheet({
    super.key,
    this.initialTab = 0,
    required this.onSelectShield,
    required this.onSelectDivision,
    required this.onSelectElement,
    required this.onSelectPattern,
    required this.onSelectTemplate,
    required this.onSelectPresetKit,
    required this.onRandomMix,
  });

  @override
  State<AssetLibrarySheet> createState() => _AssetLibrarySheetState();
}

class _AssetLibrarySheetState extends State<AssetLibrarySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedElementCategory = 'All';
  static final Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 5),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allElements = ElementLibrary.all;
    final filteredElements = allElements.where((e) {
      final matchesCat = _selectedElementCategory == 'All' ||
          (_selectedElementCategory == 'Favorites' && _favorites.contains(e.id)) ||
          e.category == _selectedElementCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          e.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search 500+ shields, emblems, patterns, kits...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Mix'),
                  onPressed: () {
                    widget.onRandomMix();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: 'Shields (${ShieldLibrary.all.length})'),
              Tab(text: 'Divisions (${DivisionLibrary.all.length})'),
              Tab(text: 'Emblems (${allElements.length})'),
              Tab(text: 'Patterns (${PatternLibrary.all.length})'),
              Tab(text: 'Jerseys (${JerseyLibrary.templates.length})'),
              Tab(text: 'Preset Kits (${PresetLibrary.presetKits.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPathGrid(
                  scrollCtrl: scrollCtrl,
                  items: ShieldLibrary.all
                      .where((s) => s.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .map((s) => (s.id, s.name, s.category, s.path, () {
                            widget.onSelectShield(s);
                            Navigator.pop(context);
                          }))
                      .toList(),
                ),
                _buildPathGrid(
                  scrollCtrl: scrollCtrl,
                  items: DivisionLibrary.all
                      .where((d) => d.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .map((d) => (d.id, d.name, d.category, d.path, () {
                            widget.onSelectDivision(d);
                            Navigator.pop(context);
                          }))
                      .toList(),
                ),
                Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          'All',
                          'Favorites',
                          ...ElementLibrary.categories.skip(1),
                        ].map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: _selectedElementCategory == cat,
                              onSelected: (_) => setState(
                                  () => _selectedElementCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: _buildPathGrid(
                        scrollCtrl: scrollCtrl,
                        items: filteredElements
                            .map((e) => (e.id, e.name, e.category, e.path, () {
                                  widget.onSelectElement(e);
                                  Navigator.pop(context);
                                }))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                _buildPathGrid(
                  scrollCtrl: scrollCtrl,
                  items: PatternLibrary.all
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .map((p) => (p.id, p.name, p.category, p.svgPath, () {
                            widget.onSelectPattern(p);
                            Navigator.pop(context);
                          }))
                      .toList(),
                ),
                _buildPathGrid(
                  scrollCtrl: scrollCtrl,
                  items: JerseyLibrary.templates
                      .where((t) => t.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .map((t) => (
                            t.id,
                            t.name,
                            t.category,
                            '${t.bodyFrontPath} ${t.sleevesFrontPath}',
                            () {
                              widget.onSelectTemplate(t);
                              Navigator.pop(context);
                            }
                          ))
                      .toList(),
                ),
                GridView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 175,
                    mainAxisExtent: 120,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: PresetLibrary.presetKits.length,
                  itemBuilder: (context, index) {
                    final preset = PresetLibrary.presetKits[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          widget.onSelectPresetKit(preset);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      backgroundColor:
                                          Color(preset.primaryColor),
                                      radius: 12),
                                  const SizedBox(width: 4),
                                  CircleAvatar(
                                      backgroundColor:
                                          Color(preset.secondaryColor),
                                      radius: 12),
                                  const SizedBox(width: 4),
                                  CircleAvatar(
                                      backgroundColor:
                                          Color(preset.accentColor),
                                      radius: 12),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                preset.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                '${preset.sport} • ${preset.style}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathGrid({
    required ScrollController scrollCtrl,
    required List<(String id, String name, String cat, String path, VoidCallback onTap)>
        items,
  }) {
    return GridView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisExtent: 130,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFav = _favorites.contains(item.$1);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: item.$5,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _MiniPathThumbnailPainter(
                            svgPath: item.$4,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        item.$3,
                        maxLines: 1,
                        style:
                            const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 15,
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.redAccent : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFav) {
                          _favorites.remove(item.$1);
                        } else {
                          _favorites.add(item.$1);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniPathThumbnailPainter extends CustomPainter {
  final String svgPath;
  final Color color;

  const _MiniPathThumbnailPainter({
    required this.svgPath,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final dx = (size.width - side) / 2;
    final dy = (size.height - side) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    if (svgPath.trim().isEmpty) {
      canvas.drawRect(
        Rect.fromLTWH(side * 0.15, side * 0.15, side * 0.7, side * 0.7),
        Paint()..color = color,
      );
    } else {
      final path = SvgParser.parse(svgPath, targetSize: Size(side, side));
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniPathThumbnailPainter oldDelegate) =>
      oldDelegate.svgPath != svgPath || oldDelegate.color != color;
}
