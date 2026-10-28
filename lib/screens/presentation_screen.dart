import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import '../data/presets.dart';
import '../painters/background_painter.dart';
import '../painters/crest_painter.dart';
import '../painters/jersey_painter.dart';
import '../utils/export_utils.dart';

class PresentationScreen extends StatefulWidget {
  final StudioProject project;
  final int initialKitIndex;

  const PresentationScreen({
    super.key,
    required this.project,
    this.initialKitIndex = 0,
  });

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final GlobalKey _stageKey = GlobalKey();
  late int _kitIndex;
  late String _backgroundId;
  bool _flatLayMode = false;

  @override
  void initState() {
    super.initState();
    _kitIndex = widget.initialKitIndex;
    _backgroundId = widget.project.backgroundId;
  }

  KitSet get _kit => widget.project.kits[_kitIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} — Matchday Showcase'),
        actions: [
          FilterChip(
            label: Text(_flatLayMode ? 'Flat-Lay' : 'Mannequin'),
            selected: _flatLayMode,
            onSelected: (v) => setState(() => _flatLayMode = v),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Export 2048px Showcase PNG',
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              ExportUtils.exportAndSharePng(
                _stageKey,
                2048,
                '${widget.project.name}_Showcase',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _stageKey,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BackgroundPainter(backgroundId: _backgroundId),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 88,
                                height: 88,
                                child: CustomPaint(
                                  painter: CrestPainter(
                                    crest: _kit.crest,
                                    layers: _kit.layers,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.project.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      '${_kit.name.toUpperCase()} KIT • 2026/27 OFFICIAL COLLECTION',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _flatLayMode
                                ? AspectRatio(
                                    aspectRatio: 1.0,
                                    child: CustomPaint(
                                      painter: JerseyPainter(
                                        jersey: _kit.jersey,
                                        crest: _kit.crest,
                                        layers: _kit.layers,
                                        viewMode: JerseyViewMode.fullKit,
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: CustomPaint(
                                          painter: JerseyPainter(
                                            jersey: _kit.jersey,
                                            crest: _kit.crest,
                                            layers: _kit.layers,
                                            viewMode: JerseyViewMode.front,
                                          ),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomPaint(
                                          painter: JerseyPainter(
                                            jersey: _kit.jersey,
                                            crest: _kit.crest,
                                            layers: _kit.layers,
                                            viewMode: JerseyViewMode.back,
                                          ),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      widget.project.kits.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(widget.project.kits[i].name),
                          selected: _kitIndex == i,
                          onSelected: (_) => setState(() => _kitIndex = i),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: PresetLibrary.backgrounds.map((bg) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: CircleAvatar(
                            backgroundColor: Color(bg.colors.first),
                            radius: 8,
                          ),
                          label: Text(bg.name),
                          onPressed: () =>
                              setState(() => _backgroundId = bg.id),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
