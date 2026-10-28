import 'package:flutter/material.dart';
import '../data/presets.dart';
import '../models/scene_models.dart';
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
  late int _kitIndex;
  late BackgroundPreset _bgPreset;
  bool _mannequinMode = true;
  bool _showAllKitsLineup = false;

  @override
  void initState() {
    super.initState();
    _kitIndex = widget.initialKitIndex;
    _bgPreset = PresetLibrary.backgrounds.firstWhere(
      (b) => b.id == widget.project.backgroundId,
      orElse: () => PresetLibrary.backgrounds.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeKit = widget.project.kits[_kitIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} Showcase'),
        actions: [
          IconButton(
            tooltip: 'Toggle Mannequin / Flat-Lay',
            icon: Icon(
              _mannequinMode ? Icons.accessibility_new : Icons.layers_outlined,
            ),
            onPressed: () => setState(() => _mannequinMode = !_mannequinMode),
          ),
          IconButton(
            tooltip: 'Compare All Kits Lineup',
            icon: Icon(_showAllKitsLineup ? Icons.person : Icons.view_column),
            onPressed: () =>
                setState(() => _showAllKitsLineup = !_showAllKitsLineup),
          ),
          IconButton(
            tooltip: 'Export PDF Spec Sheet',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final bytes =
                  await ExportUtils.generateProjectPdfBytes(widget.project);
              await ExportUtils.shareBytes(
                bytes: bytes,
                fileName: '${widget.project.name}_Kits.pdf',
                mimeType: 'application/pdf',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: BackgroundPainter(
                    preset: _bgPreset,
                    showMannequinOutline: _mannequinMode && !_showAllKitsLineup,
                  ),
                ),
                if (_showAllKitsLineup)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: widget.project.kits.map((kit) {
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 64,
                                width: 64,
                                child: CustomPaint(
                                  painter: CrestPainter(
                                    crest: kit.crest,
                                    layers: kit.layers,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: CustomPaint(
                                  size: const Size(200, 320),
                                  painter: JerseyPainter(
                                    jersey: kit.jersey,
                                    crest: kit.crest,
                                    crestLayers: kit.layers,
                                    viewMode: 'full',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                kit.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CustomPaint(
                          painter: JerseyPainter(
                            jersey: activeKit.jersey,
                            crest: activeKit.crest,
                            crestLayers: activeKit.layers,
                            viewMode: 'full',
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: CustomPaint(
                      painter: CrestPainter(
                        crest: activeKit.crest,
                        layers: activeKit.layers,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.project.kits.length, (i) {
                    final k = widget.project.kits[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(k.name),
                        selected: _kitIndex == i,
                        onSelected: (_) => setState(() => _kitIndex = i),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: PresetLibrary.backgrounds.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final bg = PresetLibrary.backgrounds[index];
                      final selected = bg.id == _bgPreset.id;
                      return ChoiceChip(
                        label: Text(
                          bg.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _bgPreset = bg;
                            widget.project.backgroundId = bg.id;
                          });
                        },
                      );
                    },
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
