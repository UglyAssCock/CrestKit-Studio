import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/presets.dart';
import '../models/scene_models.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _uuid = const Uuid();
  late TabController _tabController;
  List<StudioProject> _projects = [];
  String _selectedSportFilter = 'All';
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _showOnboarding = !(widget.prefs.getBool('onboarding_done') ?? false);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    final rawList = widget.prefs.getStringList('saved_projects') ?? [];
    if (rawList.isEmpty) {
      final starter = StudioProject(
        id: 'proj_starter',
        name: 'Oran Athletic FC',
      );
      _projects = [starter];
      _saveProjects();
    } else {
      _projects = rawList
          .map((s) {
            try {
              return StudioProject.fromJsonString(s);
            } catch (_) {
              return null;
            }
          })
          .whereType<StudioProject>()
          .toList();
    }
  }

  void _saveProjects() {
    final encoded = _projects.map((p) => p.toJsonString()).toList();
    widget.prefs.setStringList('saved_projects', encoded);
  }

  void _openProject(StudioProject project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudioScreen(
          project: project,
          prefs: widget.prefs,
          gridSize: widget.gridSize,
          snapToGrid: widget.snapToGrid,
          defaultExportSize: widget.defaultExportSize,
          onSave: () {
            project.updatedAt = DateTime.now();
            _saveProjects();
            if (mounted) setState(() {});
          },
        ),
      ),
    );
    setState(() {});
  }

  void _createNewProject() async {
    final ctrl = TextEditingController(text: 'New Club FC');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Club Project'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Club / Team Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final name = ctrl.text.trim().isEmpty ? 'Untitled FC' : ctrl.text.trim();
      final proj = StudioProject(
        id: 'proj_${_uuid.v4().substring(0, 8)}',
        name: name,
      );
      setState(() {
        _projects.insert(0, proj);
      });
      _saveProjects();
      _openProject(proj);
    }
  }

  void _createProjectFromPreset(KitPresetData preset) {
    final kit = preset.toKitSet();
    final proj = StudioProject(
      id: 'proj_${_uuid.v4().substring(0, 8)}',
      name: preset.name,
      primaryTeamColor: preset.primaryColor,
      secondaryTeamColor: preset.secondaryColor,
      accentTeamColor: preset.accentColor,
      kits: [
        kit..name = 'Home',
        kit.copy()
          ..id = 'away'
          ..name = 'Away',
        kit.copy()
          ..id = 'third'
          ..name = 'Third',
        kit.copy()
          ..id = 'gk'
          ..name = 'Goalkeeper',
      ],
    );
    setState(() {
      _projects.insert(0, proj);
    });
    _saveProjects();
    _openProject(proj);
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Studio Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: widget.isDark,
                onChanged: (v) {
                  widget.onUpdateSettings(isDark: v);
                  setDialogState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Snap to Grid'),
                value: widget.snapToGrid,
                onChanged: (v) {
                  widget.onUpdateSettings(snapToGrid: v);
                  setDialogState(() {});
                },
              ),
              ListTile(
                title: Text('Grid Step (${widget.gridSize.round()} units)'),
                subtitle: Slider(
                  value: widget.gridSize,
                  min: 5.0,
                  max: 25.0,
                  divisions: 4,
                  onChanged: (v) {
                    widget.onUpdateSettings(gridSize: v);
                    setDialogState(() {});
                  },
                ),
              ),
              ListTile(
                title: const Text('Default PNG Export Resolution'),
                trailing: DropdownButton<int>(
                  value: widget.defaultExportSize,
                  items: const [
                    DropdownMenuItem(value: 1024, child: Text('1024 px')),
                    DropdownMenuItem(value: 2048, child: Text('2048 px (2K)')),
                    DropdownMenuItem(value: 4096, child: Text('4096 px (4K)')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      widget.onUpdateSettings(defaultExportSize: v);
                      setDialogState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _showOnboarding = true);
              },
              child: const Text('Replay Onboarding'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () {
          widget.prefs.setBool('onboarding_done', true);
          setState(() => _showOnboarding = false);
        },
      );
    }

    final sports = [
      'All',
      'Football',
      'Basketball',
      'Rugby',
      'Cricket',
      'Esports',
      'Hockey',
      'Baseball',
      'Cycling',
      'Gridiron',
      'Volleyball',
    ];

    final filteredPresets = PresetLibrary.presetKits.where((p) {
      if (_selectedSportFilter == 'All') return true;
      return p.sport == _selectedSportFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield, color: Color(0xFF00E5A3)),
            SizedBox(width: 8),
            Text(
              'CrestKit Studio',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Theme',
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onUpdateSettings(isDark: !widget.isDark),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettingsDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.folder_special_outlined),
              text: 'My Clubs (${_projects.length})',
            ),
            Tab(
              icon: const Icon(Icons.style_outlined),
              text: 'Preset Kits (${PresetLibrary.presetKits.length})',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProject,
        icon: const Icon(Icons.add),
        label: const Text('New Club'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Saved Club Projects
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: _projects.length,
            itemBuilder: (context, index) {
              final project = _projects[index];
              final homeKit = project.kits.first;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openProject(project),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black12,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  size: const Size(90, 90),
                                  painter: CrestPainter(
                                    crest: homeKit.crest,
                                    layers: homeKit.layers,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: CustomPaint(
                                  size: const Size(90, 90),
                                  painter: JerseyPainter(
                                    jersey: homeKit.jersey,
                                    crest: homeKit.crest,
                                    crestLayers: homeKit.layers,
                                    viewMode: 'front',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${project.kits.length} Kits • ${project.squad.length} Players',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (action) async {
                                if (action == 'rename') {
                                  final c = TextEditingController(
                                    text: project.name,
                                  );
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Rename Club'),
                                      content: TextField(controller: c),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Rename'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true && c.text.trim().isNotEmpty) {
                                    setState(() => project.name = c.text.trim());
                                    _saveProjects();
                                  }
                                } else if (action == 'duplicate') {
                                  setState(() {
                                    _projects.insert(
                                      index + 1,
                                      project.copy(
                                        newId:
                                            'proj_${_uuid.v4().substring(0, 8)}',
                                        newName: '${project.name} Copy',
                                      ),
                                    );
                                  });
                                  _saveProjects();
                                } else if (action == 'delete' &&
                                    _projects.length > 1) {
                                  setState(() => _projects.removeAt(index));
                                  _saveProjects();
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text('Duplicate'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab 2: 42 Preset Kits Gallery
          Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: sports.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = sports[i];
                    return ChoiceChip(
                      label: Text(s),
                      selected: _selectedSportFilter == s,
                      onSelected: (_) =>
                          setState(() => _selectedSportFilter = s),
                    );
                  },
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filteredPresets.length,
                  itemBuilder: (context, index) {
                    final preset = filteredPresets[index];
                    final sampleKit = preset.toKitSet();
                    return Card(
                      child: InkWell(
                        onTap: () => _createProjectFromPreset(preset),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomPaint(
                                        size: const Size(80, 80),
                                        painter: CrestPainter(
                                          crest: sampleKit.crest,
                                          layers: sampleKit.layers,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: CustomPaint(
                                        size: const Size(80, 80),
                                        painter: JerseyPainter(
                                          jersey: sampleKit.jersey,
                                          crest: sampleKit.crest,
                                          crestLayers: sampleKit.layers,
                                          viewMode: 'front',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                preset.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${preset.sport} • ${preset.style}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
