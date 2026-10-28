import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/scene_models.dart';
import '../data/presets.dart';
import '../painters/crest_painter.dart';
import '../painters/jersey_painter.dart';
import 'onboarding_screen.dart';
import 'studio_screen.dart';

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isDark;
  final double gridSize;
  final bool snapToGrid;
  final int defaultExportSize;
  final void Function({
    bool? isDark,
    double? gridSize,
    bool? snapToGrid,
    int? defaultExportSize,
  }) onUpdateSettings;

  const HomeScreen({
    super.key,
    required this.prefs,
    required this.isDark,
    required this.gridSize,
    required this.snapToGrid,
    required this.defaultExportSize,
    required this.onUpdateSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _storageKey = 'crestkit_saved_projects_v1';
  final Uuid _uuid = const Uuid();
  List<StudioProject> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seenOnboarding = widget.prefs.getBool('seen_onboarding') ?? false;
      if (!seenOnboarding && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(
              onFinish: () {
                widget.prefs.setBool('seen_onboarding', true);
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    });
  }

  void _loadProjects() {
    final rawList = widget.prefs.getStringList(_storageKey);
    if (rawList != null && rawList.isNotEmpty) {
      _projects = rawList
          .map((e) {
            try {
              return StudioProject.fromJsonString(e);
            } catch (_) {
              return null;
            }
          })
          .whereType<StudioProject>()
          .toList();
    }
    if (_projects.isEmpty) {
      _projects = [
        StudioProject(id: 'club_default_1', name: 'CrestKit United FC'),
      ];
      _persistProjects();
    }
    setState(() {});
  }

  void _persistProjects() {
    widget.prefs.setStringList(
      _storageKey,
      _projects.map((p) => p.toJsonString()).toList(),
    );
  }

  void _saveOrUpdateProject(StudioProject updated) {
    final idx = _projects.indexWhere((p) => p.id == updated.id);
    setState(() {
      if (idx >= 0) {
        _projects[idx] = updated;
      } else {
        _projects.insert(0, updated);
      }
    });
    _persistProjects();
  }

  void _openProject(StudioProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudioScreen(
          project: project,
          onSave: _saveOrUpdateProject,
          isDark: widget.isDark,
          gridSize: widget.gridSize,
          snapToGrid: widget.snapToGrid,
          defaultExportSize: widget.defaultExportSize,
          onUpdateSettings: widget.onUpdateSettings,
        ),
      ),
    );
  }

  void _createNewProject({KitPresetData? fromPreset}) {
    final id = 'proj_${_uuid.v4().substring(0, 8)}';
    final proj = StudioProject(
      id: id,
      name: fromPreset != null ? fromPreset.name : 'New Club ${_projects.length + 1}',
      primaryTeamColor: fromPreset?.primaryColor ?? 0xFFDC2626,
      secondaryTeamColor: fromPreset?.secondaryColor ?? 0xFFFFFFFF,
      accentTeamColor: fromPreset?.accentColor ?? 0xFFD4AF37,
    );
    if (fromPreset != null) {
      proj.kits[0] = fromPreset.toKitSet();
    }
    _saveOrUpdateProject(proj);
    _openProject(proj);
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Studio Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Dark Theme'),
              value: widget.isDark,
              onChanged: (v) {
                widget.onUpdateSettings(isDark: v);
                Navigator.pop(ctx);
              },
            ),
            SwitchListTile(
              title: const Text('Snap to Grid'),
              value: widget.snapToGrid,
              onChanged: (v) {
                widget.onUpdateSettings(snapToGrid: v);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Grid Size'),
              trailing: DropdownButton<double>(
                value: widget.gridSize,
                items: const [
                  DropdownMenuItem(value: 5.0, child: Text('5 px')),
                  DropdownMenuItem(value: 10.0, child: Text('10 px')),
                  DropdownMenuItem(value: 20.0, child: Text('20 px')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    widget.onUpdateSettings(gridSize: v);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Default PNG Export'),
              trailing: DropdownButton<int>(
                value: widget.defaultExportSize,
                items: const [
                  DropdownMenuItem(value: 1024, child: Text('1024 px')),
                  DropdownMenuItem(value: 2048, child: Text('2048 px')),
                  DropdownMenuItem(value: 4096, child: Text('4096 px')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    widget.onUpdateSettings(defaultExportSize: v);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _renameProjectDialog(StudioProject proj) {
    final ctrl = TextEditingController(text: proj.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Club Project'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                proj.name = ctrl.text.trim();
                _saveOrUpdateProject(proj);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield, color: Color(0xFF00E5A3)),
            SizedBox(width: 10),
            Text(
              'CrestKit Studio',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Onboarding Guide',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OnboardingScreen(
                    onFinish: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Club Project'),
        onPressed: () => _createNewProject(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your Club Projects (${_projects.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 230,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _projects.length,
            itemBuilder: (context, index) {
              final proj = _projects[index];
              final homeKit = proj.kits.first;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openProject(proj),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFF0F172A),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  painter: CrestPainter(
                                    crest: homeKit.crest,
                                    layers: homeKit.layers,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomPaint(
                                  painter: JerseyPainter(
                                    jersey: homeKit.jersey,
                                    crest: homeKit.crest,
                                    layers: homeKit.layers,
                                    viewMode: JerseyViewMode.front,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          proj.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${proj.kits.length} Kits • ${proj.squad.length} Squad'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'rename') {
                              _renameProjectDialog(proj);
                            } else if (action == 'duplicate') {
                              final copy = proj.copy(
                                newId: 'proj_${_uuid.v4().substring(0, 8)}',
                                newName: '${proj.name} Copy',
                              );
                              _saveOrUpdateProject(copy);
                            } else if (action == 'delete' &&
                                _projects.length > 1) {
                              setState(() => _projects.removeAt(index));
                              _persistProjects();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'rename', child: Text('Rename')),
                            PopupMenuItem(
                                value: 'duplicate', child: Text('Duplicate')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Quick-Start From 42 Built-in Club & Esports Presets',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: PresetLibrary.presetKits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final preset = PresetLibrary.presetKits[index];
                final previewKit = preset.toKitSet();
                return SizedBox(
                  width: 150,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _createNewProject(fromPreset: preset),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Expanded(
                              child: CustomPaint(
                                painter: CrestPainter(
                                  crest: previewKit.crest,
                                  layers: previewKit.layers,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              preset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${preset.sport} • ${preset.style}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
