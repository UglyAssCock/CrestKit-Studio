import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(CrestKitStudioApp(prefs: prefs));
}

class CrestKitStudioApp extends StatefulWidget {
  final SharedPreferences prefs;
  const CrestKitStudioApp({super.key, required this.prefs});

  @override
  State<CrestKitStudioApp> createState() => _CrestKitStudioAppState();
}

class _CrestKitStudioAppState extends State<CrestKitStudioApp> {
  late bool _isDark;
  late double _gridSize;
  late bool _snapToGrid;
  late int _defaultExportSize;

  @override
  void initState() {
    super.initState();
    _isDark = widget.prefs.getBool('is_dark') ?? true;
    _gridSize = widget.prefs.getDouble('grid_size') ?? 10.0;
    _snapToGrid = widget.prefs.getBool('snap_to_grid') ?? false;
    _defaultExportSize = widget.prefs.getInt('export_size') ?? 2048;
  }

  void _updateSettings({
    bool? isDark,
    double? gridSize,
    bool? snapToGrid,
    int? defaultExportSize,
  }) {
    setState(() {
      if (isDark != null) {
        _isDark = isDark;
        widget.prefs.setBool('is_dark', isDark);
      }
      if (gridSize != null) {
        _gridSize = gridSize;
        widget.prefs.setDouble('grid_size', gridSize);
      }
      if (snapToGrid != null) {
        _snapToGrid = snapToGrid;
        widget.prefs.setBool('snap_to_grid', snapToGrid);
      }
      if (defaultExportSize != null) {
        _defaultExportSize = defaultExportSize;
        widget.prefs.setInt('export_size', defaultExportSize);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF00E5A3);
    return MaterialApp(
      title: 'CrestKit Studio',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: seed,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: seed,
      ),
      home: HomeScreen(
        prefs: widget.prefs,
        isDark: _isDark,
        gridSize: _gridSize,
        snapToGrid: _snapToGrid,
        defaultExportSize: _defaultExportSize,
        onUpdateSettings: _updateSettings,
      ),
    );
  }
}
