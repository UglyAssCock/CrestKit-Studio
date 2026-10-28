import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/scene_models.dart';
import '../data/shields.dart';
import '../data/divisions.dart';
import '../data/elements.dart';
import '../data/jerseys.dart';
import '../data/patterns.dart';
import '../data/presets.dart';
import '../utils/svg_parser.dart';
import '../utils/export_utils.dart';
import '../painters/background_painter.dart';
import '../painters/canvas_painter.dart';
import '../painters/jersey_painter.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/asset_library_sheet.dart';
import '../widgets/layer_panel_sheet.dart';
import '../widgets/squad_sheet.dart';
import 'presentation_screen.dart';

enum StudioWorkspace { crest, jersey, vector }

class StudioScreen extends StatefulWidget {
  final StudioProject project;
  final ValueChanged<StudioProject> onSave;
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

  const StudioScreen({
    super.key,
    required this.project,
    required this.onSave,
    required this.isDark,
    required this.gridSize,
    required this.snapToGrid,
    required this.defaultExportSize,
    required this.onUpdateSettings,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final GlobalKey _canvasBoundaryKey = GlobalKey();
  final TransformationController _transformController =
      TransformationController();
  final Uuid _uuid = const Uuid();

  late StudioProject _project;
  int _activeKitIndex = 0;
  int _activeLayerIndex = 0;
  String? _selectedShapeId;
  int? _selectedNodeIndex;

  StudioWorkspace _workspace = StudioWorkspace.crest;
  JerseyViewMode _jerseyView = JerseyViewMode.front;
  String _selectedJerseyZone = 'body';
  VectorTool _activeTool = VectorTool.select;

  bool _showGrid = true;
  bool _symmetryMode = false;
  bool _nodeEditMode = false;
  bool _oneHandedMode = false;
  bool _eyedropperActive = false;

  Offset _floatingPalettePos = const Offset(12, 86);
  Offset? _dragStartCanvas;
  List<VectorNode> _freehandPoints = [];

  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  File? _referenceFile;

  KitSet get _kit => _project.kits[_activeKitIndex];

  VectorLayer get _activeLayer {
    if (_kit.layers.isEmpty) {
      _kit.layers.add(VectorLayer(id: 'layer_default', name: 'Layer 1'));
    }
    if (_activeLayerIndex >= _kit.layers.length) {
      _activeLayerIndex = _kit.layers.length - 1;
    }
    return _kit.layers[_activeLayerIndex];
  }

  VectorShape? get _selectedShape {
    if (_selectedShapeId == null) return null;
    for (final layer in _kit.layers) {
      for (final shape in layer.shapes) {
        if (shape.id == _selectedShapeId) return shape;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _project = widget.project.copy();
    if (_project.referenceImagePath != null &&
        _project.referenceImagePath!.isNotEmpty) {
      final f = File(_project.referenceImagePath!);
      if (f.existsSync()) _referenceFile = f;
    }
    _pushHistory();
    if (_kit.layers.isNotEmpty && _kit.layers.first.shapes.isNotEmpty) {
      _selectedShapeId = _kit.layers.first.shapes.first.id;
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _pushHistory() {
    final snap = _project.toJsonString();
    if (_undoStack.isEmpty || _undoStack.last != snap) {
      _undoStack.add(snap);
      if (_undoStack.length > 60) {
        _undoStack.removeAt(0);
      }
      _redoStack.clear();
    }
    _project.updatedAt = DateTime.now();
    widget.onSave(_project);
  }

  void _undo() {
    if (_undoStack.length <= 1) return;
    final current = _undoStack.removeLast();
    _redoStack.add(current);
    setState(() {
      _project = StudioProject.fromJsonString(_undoStack.last);
    });
    widget.onSave(_project);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    _undoStack.add(next);
    setState(() {
      _project = StudioProject.fromJsonString(next);
    });
    widget.onSave(_project);
  }

  double _snapVal(double v) {
    if (!widget.snapToGrid || widget.gridSize <= 0) return v;
    final step = widget.gridSize;
    return (v / step).round() * step;
  }

  Offset _toNormalizedCanvas(Offset localPos, Size boxSize) {
    final side = math.min(boxSize.width, boxSize.height);
    final ox = (boxSize.width - side) / 2.0;
    final oy = (boxSize.height - side) / 2.0;
    final nx = ((localPos.dx - ox) / side) * 100.0;
    final ny = ((localPos.dy - oy) / side) * 100.0;
    return Offset(nx.clamp(0.0, 100.0), ny.clamp(0.0, 100.0));
  }

  void _handleCanvasTapDown(TapDownDetails details, Size canvasSize) {
    final norm = _toNormalizedCanvas(details.localPosition, canvasSize);

    if (_eyedropperActive) {
      final sampled = _sampleColorAt(norm);
      setState(() {
        _eyedropperActive = false;
        _addRecentColor(sampled);
        if (_workspace == StudioWorkspace.jersey) {
          _kit.jersey.zoneColors[_selectedJerseyZone] = sampled;
        } else if (_selectedShape != null) {
          _selectedShape!.fillColor = sampled;
        } else {
          _kit.crest.shieldPrimaryColor = sampled;
        }
      });
      _pushHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Picked #${sampled.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_workspace == StudioWorkspace.jersey &&
        _activeTool == VectorTool.select) {
      final hitZone = JerseyPainter.hitTestZone(
        norm,
        _jerseyView,
      );
      if (hitZone != null) {
        setState(() {
          _selectedJerseyZone = hitZone;
        });
      }
      return;
    }

    if (_activeTool == VectorTool.pen) {
      _addOrEditPenNode(norm);
      return;
    }

    if (_activeTool == VectorTool.select) {
      if (_nodeEditMode && _selectedShape != null) {
        final s = _selectedShape!;
        if (s.nodes.isEmpty) {
          s.nodes = SvgParser.svgPathToNodes(s.svgPath);
        }
        for (int i = 0; i < s.nodes.length; i++) {
          final nodeCanvas = _shapeLocalToCanvas(s, s.nodes[i].position);
          if ((nodeCanvas - norm).distance < 6.0) {
            setState(() => _selectedNodeIndex = i);
            return;
          }
        }
      }

      for (int li = _kit.layers.length - 1; li >= 0; li--) {
        final layer = _kit.layers[li];
        if (!layer.visible || layer.locked) continue;
        for (int si = layer.shapes.length - 1; si >= 0; si--) {
          final shape = layer.shapes[si];
          final dist = (Offset(shape.tx, shape.ty) - norm).distance;
          final radius = 36.0 * math.max(shape.scaleX.abs(), shape.scaleY.abs());
          if (dist <= radius) {
            setState(() {
              _activeLayerIndex = li;
              _selectedShapeId = shape.id;
              _selectedNodeIndex = null;
            });
            return;
          }
        }
      }
    } else {
      _insertPrimitiveAt(norm);
    }
  }

  Offset _shapeLocalToCanvas(VectorShape s, Offset localPt) {
    final dx = (localPt.dx - 50.0) * s.scaleX * (s.flipH ? -1 : 1);
    final dy = (localPt.dy - 50.0) * s.scaleY * (s.flipV ? -1 : 1);
    final rad = s.rotation * math.pi / 180.0;
    final rx = dx * math.cos(rad) - dy * math.sin(rad);
    final ry = dx * math.sin(rad) + dy * math.cos(rad);
    return Offset(s.tx + rx, s.ty + ry);
  }

  Offset _canvasToShapeLocal(VectorShape s, Offset canvasPt) {
    final dx = canvasPt.dx - s.tx;
    final dy = canvasPt.dy - s.ty;
    final rad = -s.rotation * math.pi / 180.0;
    final rx = dx * math.cos(rad) - dy * math.sin(rad);
    final ry = dx * math.sin(rad) + dy * math.cos(rad);
    final lx = 50.0 + (rx / (s.scaleX == 0 ? 0.01 : s.scaleX)) * (s.flipH ? -1 : 1);
    final ly = 50.0 + (ry / (s.scaleY == 0 ? 0.01 : s.scaleY)) * (s.flipV ? -1 : 1);
    return Offset(lx.clamp(0.0, 100.0), ly.clamp(0.0, 100.0));
  }

  int _sampleColorAt(Offset norm) {
    for (final layer in _kit.layers.reversed) {
      if (!layer.visible) continue;
      for (final shape in layer.shapes.reversed) {
        if ((Offset(shape.tx, shape.ty) - norm).distance < 22) {
          return shape.fillColor;
        }
      }
    }
    if (_workspace == StudioWorkspace.jersey) {
      final zone = JerseyPainter.hitTestZone(norm, _jerseyView) ?? 'body';
      return _kit.jersey.zoneColors[zone] ?? _project.primaryTeamColor;
    }
    return norm.dx < 50
        ? _kit.crest.divisionColor1
        : _kit.crest.divisionColor2;
  }

  void _addOrEditPenNode(Offset norm) {
    if (_activeLayer.locked) return;
    setState(() {
      var shape = _selectedShape;
      if (shape == null || !shape.name.startsWith('Pen Path')) {
        final n = VectorNode(x: norm.dx, y: norm.dy, ctrl1X: norm.dx + 6, ctrl1Y: norm.dy - 6);
        final created = VectorShape(
          id: 'shape_${_uuid.v4().substring(0, 8)}',
          name: 'Pen Path ${_activeLayer.shapes.length + 1}',
          svgPath: 'M ${norm.dx.toStringAsFixed(1)} ${norm.dy.toStringAsFixed(1)}',
          nodes: [n],
          closed: false,
          fillType: FillType.solid,
          fillColor: _project.accentTeamColor,
          strokeColor: _project.primaryTeamColor,
          strokeWidth: 2.2,
          tx: 50,
          ty: 50,
          scaleX: 1.0,
          scaleY: 1.0,
        );
        _activeLayer.shapes.add(created);
        _selectedShapeId = created.id;
        _selectedNodeIndex = 0;
        _nodeEditMode = true;
      } else {
        final localPt = _canvasToShapeLocal(shape, norm);
        shape.nodes.add(VectorNode(
          x: localPt.dx,
          y: localPt.dy,
          ctrl1X: (localPt.dx + 8).clamp(0.0, 100.0),
          ctrl1Y: (localPt.dy - 8).clamp(0.0, 100.0),
        ));
        shape.svgPath = SvgParser.nodesToSvgPath(shape.nodes, shape.closed);
        _selectedNodeIndex = shape.nodes.length - 1;
      }

      if (_symmetryMode && _selectedShape != null) {
        _syncSymmetryClone(_selectedShape!);
      }
    });
    _pushHistory();
  }

  void _insertPrimitiveAt(Offset norm) {
    if (_activeLayer.locked) return;
    final sx = _snapVal(norm.dx);
    final sy = _snapVal(norm.dy);
    String path = '';
    String label = 'Shape';
    bool closed = true;

    switch (_activeTool) {
      case VectorTool.rect:
        label = 'Rectangle';
        path = 'M 18 24 L 82 24 L 82 76 L 18 76 Z';
        break;
      case VectorTool.roundRect:
        label = 'Rounded Rect';
        path =
            'M 26 22 L 74 22 Q 84 22 84 32 L 84 68 Q 84 78 74 78 L 26 78 Q 16 78 16 68 L 16 32 Q 16 22 26 22 Z';
        break;
      case VectorTool.circle:
        label = 'Circle';
        path = 'M 50 14 A 36 36 0 1 0 50 86 A 36 36 0 1 0 50 14 Z';
        break;
      case VectorTool.ellipse:
        label = 'Ellipse';
        path = 'M 50 22 A 40 28 0 1 0 50 78 A 40 28 0 1 0 50 22 Z';
        break;
      case VectorTool.polygon:
        label = 'Hexagon';
        path = SvgParser.createPolygonPath(6, 38);
        break;
      case VectorTool.star:
        label = 'Star';
        path = SvgParser.createStarPath(5, 42, 18);
        break;
      case VectorTool.line:
        label = 'Line';
        path = 'M 16 84 L 84 16';
        closed = false;
        break;
      default:
        return;
    }

    final shape = VectorShape(
      id: 'shape_${_uuid.v4().substring(0, 8)}',
      name: label,
      svgPath: path,
      nodes: SvgParser.svgPathToNodes(path),
      closed: closed,
      fillColor: _project.accentTeamColor,
      strokeColor: _project.secondaryTeamColor,
      strokeWidth: 2.0,
      tx: sx,
      ty: sy,
      scaleX: 0.45,
      scaleY: 0.45,
    );

    setState(() {
      _activeLayer.shapes.add(shape);
      _selectedShapeId = shape.id;
      _activeTool = VectorTool.select;
      if (_symmetryMode) {
        _syncSymmetryClone(shape);
      }
    });
    _pushHistory();
  }

  void _syncSymmetryClone(VectorShape source) {
    final mirrorId = '${source.id}_sym';
    _activeLayer.shapes.removeWhere((s) => s.id == mirrorId);
    final clone = source.copy(newId: mirrorId);
    clone.name = '${source.name} (Mirror)';
    clone.tx = 100.0 - source.tx;
    clone.flipH = !source.flipH;
    clone.rotation = -source.rotation;
    _activeLayer.shapes.add(clone);
  }

  void _handlePanStart(DragStartDetails details, Size canvasSize) {
    if (_activeLayer.locked) return;
    final norm = _toNormalizedCanvas(details.localPosition, canvasSize);
    _dragStartCanvas = norm;

    if (_activeTool == VectorTool.brush) {
      _freehandPoints = [VectorNode(x: norm.dx, y: norm.dy)];
      final brushShape = VectorShape(
        id: 'shape_${_uuid.v4().substring(0, 8)}',
        name: 'Brush Stroke',
        svgPath: 'M ${norm.dx.toStringAsFixed(1)} ${norm.dy.toStringAsFixed(1)}',
        nodes: List.from(_freehandPoints),
        closed: false,
        fillColor: 0x00000000,
        strokeColor: _project.accentTeamColor,
        strokeWidth: 3.0,
        tx: 50,
        ty: 50,
        scaleX: 1.0,
        scaleY: 1.0,
      );
      setState(() {
        _activeLayer.shapes.add(brushShape);
        _selectedShapeId = brushShape.id;
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size canvasSize) {
    if (_activeLayer.locked) return;
    final norm = _toNormalizedCanvas(details.localPosition, canvasSize);

    if (_activeTool == VectorTool.brush && _selectedShape != null) {
      if (_freehandPoints.isEmpty ||
          (_freehandPoints.last.position - norm).distance > 1.8) {
        setState(() {
          _freehandPoints.add(VectorNode(x: norm.dx, y: norm.dy));
          _selectedShape!.nodes = List.from(_freehandPoints);
          _selectedShape!.svgPath =
              SvgParser.nodesToSvgPath(_freehandPoints, false);
        });
      }
      return;
    }

    if (_activeTool == VectorTool.select && _selectedShape != null) {
      final s = _selectedShape!;
      if (_nodeEditMode &&
          _selectedNodeIndex != null &&
          _selectedNodeIndex! < s.nodes.length) {
        final localPt = _canvasToShapeLocal(s, norm);
        setState(() {
          s.nodes[_selectedNodeIndex!].x = _snapVal(localPt.dx);
          s.nodes[_selectedNodeIndex!].y = _snapVal(localPt.dy);
          s.svgPath = SvgParser.nodesToSvgPath(s.nodes, s.closed);
          if (_symmetryMode) _syncSymmetryClone(s);
        });
        return;
      }

      if (_dragStartCanvas != null) {
        final delta = norm - _dragStartCanvas!;
        _dragStartCanvas = norm;
        setState(() {
          s.tx = _snapVal((s.tx + delta.dx).clamp(2.0, 98.0));
          s.ty = _snapVal((s.ty + delta.dy).clamp(2.0, 98.0));
          if (_symmetryMode) _syncSymmetryClone(s);
        });
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStartCanvas = null;
    if (_activeTool == VectorTool.brush && _selectedShape != null) {
      if (_symmetryMode) {
        setState(() => _syncSymmetryClone(_selectedShape!));
      }
    }
    _pushHistory();
  }

  void _addRecentColor(int colorVal) {
    _project.recentColors.remove(colorVal);
    _project.recentColors.insert(0, colorVal);
    if (_project.recentColors.length > 18) {
      _project.recentColors.removeLast();
    }
  }

  void _randomizeMix() {
    final rng = math.Random();
    final shield = ShieldLibrary.all[rng.nextInt(ShieldLibrary.all.length)];
    final div = DivisionLibrary.all[rng.nextInt(DivisionLibrary.all.length)];
    final elem = ElementLibrary.all[rng.nextInt(ElementLibrary.all.length)];
    final pat = PatternLibrary.all[rng.nextInt(PatternLibrary.all.length)];
    final palettes = [
      [0xFF0F172A, 0xFF00E5A3, 0xFFFFFFFF],
      [0xFFDC2626, 0xFFFFFFFF, 0xFFD4AF37],
      [0xFF1E3A8A, 0xFFFACC15, 0xFFFFFFFF],
      [0xFF111827, 0xFFF43F5E, 0xFF38BDF8],
      [0xFF064E3B, 0xFFD4AF37, 0xFFFFFFFF],
      [0xFF31102F, 0xFFEC4899, 0xFFFDE047],
    ];
    final pal = palettes[rng.nextInt(palettes.length)];

    setState(() {
      _project.primaryTeamColor = pal[0];
      _project.secondaryTeamColor = pal[1];
      _project.accentTeamColor = pal[2];

      _kit.crest.shieldId = shield.id;
      _kit.crest.divisionId = div.id;
      _kit.crest.shieldPrimaryColor = pal[0];
      _kit.crest.divisionColor1 = pal[0];
      _kit.crest.divisionColor2 = pal[1];
      _kit.crest.shieldStrokeColor = pal[2];
      _kit.crest.bordureColor = pal[2];
      _kit.crest.bannerColor = pal[2];
      _kit.crest.bannerTextColor = pal[0];

      _kit.jersey.zoneColors['body'] = pal[0];
      _kit.jersey.zoneColors['sleeves'] = pal[1];
      _kit.jersey.zoneColors['collar'] = pal[2];
      _kit.jersey.zoneColors['cuffs'] = pal[2];
      _kit.jersey.zoneColors['shorts'] = pal[1];
      _kit.jersey.zoneColors['socks'] = pal[0];
      _kit.jersey.bodyPattern.patternId = pat.id;
      _kit.jersey.bodyPattern.primaryColor = pal[0];
      _kit.jersey.bodyPattern.secondaryColor = pal[1];

      final newShape = VectorShape(
        id: 'shape_${_uuid.v4().substring(0, 8)}',
        name: elem.name,
        svgPath: elem.path,
        nodes: SvgParser.svgPathToNodes(elem.path),
        fillColor: pal[2],
        strokeColor: pal[0],
        strokeWidth: 1.8,
        tx: 50,
        ty: 50,
        scaleX: 0.54,
        scaleY: 0.54,
      );
      _activeLayer.shapes
        ..clear()
        ..add(newShape);
      _selectedShapeId = newShape.id;
    });
    _pushHistory();
  }

  Future<void> _pickReferenceImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    setState(() {
      _referenceFile = File(xfile.path);
      _project.referenceImagePath = xfile.path;
    });
    _pushHistory();
  }

  void _openAssetLibrary({int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AssetLibrarySheet(
        initialTab: initialTab,
        onSelectShield: (shield) {
          setState(() => _kit.crest.shieldId = shield.id);
          _pushHistory();
        },
        onSelectDivision: (div) {
          setState(() => _kit.crest.divisionId = div.id);
          _pushHistory();
        },
        onSelectElement: (elem) {
          final shape = VectorShape(
            id: 'shape_${_uuid.v4().substring(0, 8)}',
            name: elem.name,
            svgPath: elem.path,
            nodes: SvgParser.svgPathToNodes(elem.path),
            fillColor: _project.accentTeamColor,
            strokeColor: _project.primaryTeamColor,
            strokeWidth: 1.5,
            tx: 50,
            ty: 50,
            scaleX: 0.5,
            scaleY: 0.5,
          );
          setState(() {
            _activeLayer.shapes.add(shape);
            _selectedShapeId = shape.id;
          });
          _pushHistory();
        },
        onSelectPattern: (pat) {
          setState(() {
            _kit.jersey.bodyPattern.patternId = pat.id;
            _workspace = StudioWorkspace.jersey;
          });
          _pushHistory();
        },
        onSelectTemplate: (tpl) {
          setState(() {
            _kit.jersey.templateId = tpl.id;
            _workspace = StudioWorkspace.jersey;
          });
          _pushHistory();
        },
        onSelectPresetKit: (preset) {
          setState(() {
            _project.kits[_activeKitIndex] = preset.toKitSet();
            _project.primaryTeamColor = preset.primaryColor;
            _project.secondaryTeamColor = preset.secondaryColor;
            _project.accentTeamColor = preset.accentColor;
            if (_kit.layers.isNotEmpty &&
                _kit.layers.first.shapes.isNotEmpty) {
              _selectedShapeId = _kit.layers.first.shapes.first.id;
            }
          });
          _pushHistory();
        },
        onRandomMix: _randomizeMix,
      ),
    );
  }

  void _openColorPicker({
    required String title,
    required int currentColor,
    required ValueChanged<int> onColorSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ColorPickerSheet(
        title: title,
        initialColor: currentColor,
        project: _project,
        onSelectColor: (c) {
          setState(() {
            _addRecentColor(c);
            onColorSelected(c);
          });
          _pushHistory();
        },
        onUpdateTeamPalette: (p, s, a) {
          setState(() {
            _project.primaryTeamColor = p;
            _project.secondaryTeamColor = s;
            _project.accentTeamColor = a;
          });
          _pushHistory();
        },
        onActivateEyedropper: () {
          Navigator.pop(context);
          setState(() => _eyedropperActive = true);
        },
      ),
    );
  }

  void _openLayerPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => LayerPanelSheet(
        kit: _kit,
        activeLayerIndex: _activeLayerIndex,
        selectedShapeId: _selectedShapeId,
        onSelectLayerAndShape: (li, sid) {
          setState(() {
            _activeLayerIndex = li;
            _selectedShapeId = sid;
          });
        },
        onMutate: () {
          setState(() {});
          _pushHistory();
        },
      ),
    );
  }

  void _openSquadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SquadSheet(
        project: _project,
        kit: _kit,
        onApplyPlayer: (player) {
          setState(() {
            _kit.jersey.playerName = player.name;
            _kit.jersey.playerNumber = player.number.toString();
            _workspace = StudioWorkspace.jersey;
            _jerseyView = JerseyViewMode.back;
          });
          _pushHistory();
        },
        onMutateSquad: () {
          setState(() {});
          _pushHistory();
        },
      ),
    );
  }

  void _openExportSheet() {
    int exportRes = widget.defaultExportSize;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export & Share (${_kit.name} Kit)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('PNG Resolution: '),
                    const Spacer(),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1024, label: Text('1024px')),
                        ButtonSegment(value: 2048, label: Text('2048px')),
                        ButtonSegment(value: 4096, label: Text('4096px')),
                      ],
                      selected: {exportRes},
                      onSelectionChanged: (s) =>
                          setModalState(() => exportRes = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Share PNG'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ExportUtils.exportAndSharePng(
                          _canvasBoundaryKey,
                          exportRes,
                          '${_project.name}_${_kit.name}_$exportRes',
                        );
                      },
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.code),
                      label: const Text('Export 2D SVG'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final svg = ExportUtils.generateSvg(
                          _kit,
                          includeJersey: _workspace == StudioWorkspace.jersey,
                        );
                        await ExportUtils.shareSvgString(
                          svg,
                          '${_project.name}_${_kit.name}',
                        );
                      },
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF Print Sheet'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ExportUtils.exportAndSharePdf(_project, _kit);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddTextDialog() {
    final ctrl = TextEditingController(text: 'CLUB FC');
    String styleId = _selectedShape?.textStyleId ?? 'block';
    TextWarpMode warp = _selectedShape?.textWarp ?? TextWarpMode.arcUp;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Insert 2D Vector Text'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Text Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: styleId,
                  decoration: const InputDecoration(labelText: 'Font Style'),
                  items: PresetLibrary.textStyles
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('${t.name} (${t.category})'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => styleId = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TextWarpMode>(
                  value: warp,
                  decoration: const InputDecoration(labelText: 'Text Warp'),
                  items: TextWarpMode.values
                      .map((w) => DropdownMenuItem(
                            value: w,
                            child: Text(w.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => warp = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  final s = VectorShape(
                    id: 'shape_${_uuid.v4().substring(0, 8)}',
                    name: 'Text: $text',
                    svgPath: 'M 20 40 L 80 40 L 80 60 L 20 60 Z',
                    textContent: text,
                    textStyleId: styleId,
                    textWarp: warp,
                    fontSize: 13.0,
                    fillColor: _project.accentTeamColor,
                    outlineColor: _project.primaryTeamColor,
                    outlineWidth: 2.0,
                    doubleOutlineColor: _project.secondaryTeamColor,
                    doubleOutlineWidth: 0.8,
                    tx: 50,
                    ty: 50,
                    scaleX: 0.8,
                    scaleY: 0.8,
                  );
                  setState(() {
                    _activeLayer.shapes.add(s);
                    _selectedShapeId = s.id;
                  });
                  _pushHistory();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Insert'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Row(
          children: [
            Flexible(
              child: Text(
                _project.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _activeKitIndex,
                isDense: true,
                items: List.generate(
                  _project.kits.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      _project.kits[i].name,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                onChanged: (idx) {
                  if (idx != null) {
                    setState(() {
                      _activeKitIndex = idx;
                      _activeLayerIndex = 0;
                      _selectedShapeId = _kit.layers.isNotEmpty &&
                              _kit.layers.first.shapes.isNotEmpty
                          ? _kit.layers.first.shapes.first.id
                          : null;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: _undoStack.length > 1 ? _undo : null,
          ),
          IconButton(
            tooltip: 'Redo',
            icon: const Icon(Icons.redo),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
          ),
          IconButton(
            tooltip: 'Mix & Randomize',
            icon: const Icon(Icons.shuffle),
            onPressed: _randomizeMix,
          ),
          IconButton(
            tooltip: 'Presentation Stage',
            icon: const Icon(Icons.slideshow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PresentationScreen(
                    project: _project,
                    initialKitIndex: _activeKitIndex,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Export & Share',
            icon: const Icon(Icons.ios_share),
            onPressed: _openExportSheet,
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                SizedBox(width: 300, child: _buildInspectorPanel()),
                const VerticalDivider(width: 1),
                Expanded(child: _buildCanvasStack()),
              ],
            )
          : Column(
              children: [
                _buildWorkspaceHeaderBar(),
                Expanded(child: _buildCanvasStack()),
                _buildInspectorPanel(),
              ],
            ),
    );
  }

  Widget _buildWorkspaceHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SegmentedButton<StudioWorkspace>(
              segments: const [
                ButtonSegment(
                  value: StudioWorkspace.crest,
                  icon: Icon(Icons.shield_outlined, size: 16),
                  label: Text('Crest'),
                ),
                ButtonSegment(
                  value: StudioWorkspace.jersey,
                  icon: Icon(Icons.checkroom_outlined, size: 16),
                  label: Text('Jersey'),
                ),
                ButtonSegment(
                  value: StudioWorkspace.vector,
                  icon: Icon(Icons.pentagon_outlined, size: 16),
                  label: Text('Vector'),
                ),
              ],
              selected: {_workspace},
              onSelectionChanged: (s) => setState(() => _workspace = s.first),
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.auto_awesome_mosaic, size: 16),
              label: const Text('Assets'),
              onPressed: () => _openAssetLibrary(
                initialTab: _workspace == StudioWorkspace.jersey ? 3 : 0,
              ),
            ),
            const SizedBox(width: 6),
            ActionChip(
              avatar: const Icon(Icons.layers_outlined, size: 16),
              label: Text('Layers (${_kit.layers.length})'),
              onPressed: _openLayerPanel,
            ),
            const SizedBox(width: 6),
            ActionChip(
              avatar: const Icon(Icons.groups_outlined, size: 16),
              label: Text('Squad (${_project.squad.length})'),
              onPressed: _openSquadSheet,
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('Symmetry'),
              selected: _symmetryMode,
              onSelected: (v) => setState(() => _symmetryMode = v),
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('Grid'),
              selected: _showGrid,
              onSelected: (v) => setState(() => _showGrid = v),
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('One-Hand UI'),
              selected: _oneHandedMode,
              onSelected: (v) => setState(() => _oneHandedMode = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(
                  backgroundId: _project.backgroundId,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: () {
                  _transformController.value = Matrix4.identity();
                },
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.5,
                  maxScale: 5.0,
                  panEnabled: _activeTool == VectorTool.select &&
                      _selectedShape == null,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _handleCanvasTapDown(d, canvasSize),
                    onPanStart: (d) => _handlePanStart(d, canvasSize),
                    onPanUpdate: (d) => _handlePanUpdate(d, canvasSize),
                    onPanEnd: _handlePanEnd,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_referenceFile != null)
                          Opacity(
                            opacity: _project.referenceOpacity,
                            child: Image.file(
                              _referenceFile!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        RepaintBoundary(
                          key: _canvasBoundaryKey,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: CustomPaint(
                              painter: CanvasPainter(
                                kit: _kit,
                                showCrest: _workspace == StudioWorkspace.crest,
                                showJersey: _workspace == StudioWorkspace.jersey,
                                jerseyView: _jerseyView,
                                selectedJerseyZone: _selectedJerseyZone,
                                selectedShapeId: _selectedShapeId,
                                selectedNodeIndex: _selectedNodeIndex,
                                showGrid: false,
                                gridSize: widget.gridSize,
                                symmetryMode: false,
                                nodeEditMode: false,
                              ),
                            ),
                          ),
                        ),
                        if (_showGrid || _symmetryMode || _selectedShape != null)
                          IgnorePointer(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: CustomPaint(
                                painter: CanvasOverlayGuidesPainter(
                                  kit: _kit,
                                  selectedShapeId: _selectedShapeId,
                                  selectedNodeIndex: _selectedNodeIndex,
                                  showGrid: _showGrid,
                                  gridSize: widget.gridSize,
                                  symmetryMode: _symmetryMode,
                                  nodeEditMode: _nodeEditMode,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_workspace == StudioWorkspace.jersey)
              Positioned(
                top: 10,
                right: 10,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<JerseyViewMode>(
                        value: _jerseyView,
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: JerseyViewMode.front,
                            child: Text('Front View'),
                          ),
                          DropdownMenuItem(
                            value: JerseyViewMode.back,
                            child: Text('Back View'),
                          ),
                          DropdownMenuItem(
                            value: JerseyViewMode.sleeve,
                            child: Text('Sleeve Detail'),
                          ),
                          DropdownMenuItem(
                            value: JerseyViewMode.shortsAndSocks,
                            child: Text('Shorts & Socks'),
                          ),
                          DropdownMenuItem(
                            value: JerseyViewMode.fullKit,
                            child: Text('Full Kit Sheet'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _jerseyView = v);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: _floatingPalettePos.dx,
              top: _oneHandedMode
                  ? math.max(120, constraints.maxHeight - 280)
                  : _floatingPalettePos.dy,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _floatingPalettePos = Offset(
                      (_floatingPalettePos.dx + d.delta.dx)
                          .clamp(4.0, constraints.maxWidth - 64.0),
                      (_floatingPalettePos.dy + d.delta.dy)
                          .clamp(4.0, constraints.maxHeight - 240.0),
                    );
                  });
                },
                child: _buildFloatingToolPalette(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingToolPalette() {
    const tools = [
      (VectorTool.select, Icons.near_me_outlined, 'Select'),
      (VectorTool.pen, Icons.timeline, 'Pen (Bézier)'),
      (VectorTool.brush, Icons.gesture, 'Brush'),
      (VectorTool.rect, Icons.crop_square, 'Rectangle'),
      (VectorTool.roundRect, Icons.rounded_corner, 'Round Rect'),
      (VectorTool.circle, Icons.circle_outlined, 'Circle'),
      (VectorTool.polygon, Icons.hexagon_outlined, 'Polygon'),
      (VectorTool.star, Icons.star_border, 'Star'),
      (VectorTool.line, Icons.horizontal_rule, 'Line'),
    ];
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
            ...tools.map((t) {
              final selected = _activeTool == t.$1;
              return IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: t.$3,
                isSelected: selected,
                icon: Icon(
                  t.$2,
                  size: 19,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => setState(() => _activeTool = t.$1),
              );
            }),
            const Divider(height: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Insert Text',
              icon: const Icon(Icons.text_fields, size: 19),
              onPressed: _openAddTextDialog,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Eyedropper',
              icon: Icon(
                Icons.colorize,
                size: 19,
                color: _eyedropperActive
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () =>
                  setState(() => _eyedropperActive = !_eyedropperActive),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Reference Image',
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
              onPressed: _pickReferenceImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectorPanel() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 270),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Crest Builder'),
                Tab(text: 'Jersey Zones'),
                Tab(text: 'Shape & Nodes'),
                Tab(text: 'Text & Stage'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCrestInspector(),
                  _buildJerseyInspector(),
                  _buildShapeInspector(),
                  _buildTextAndStageInspector(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrestInspector() {
    final c = _kit.crest;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              icon: const Icon(Icons.shield_outlined, size: 18),
              label: Text('Shield: ${ShieldLibrary.byId(c.shieldId).name}'),
              onPressed: () => _openAssetLibrary(initialTab: 0),
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.grid_view, size: 18),
              label: Text('Division: ${DivisionLibrary.byId(c.divisionId).name}'),
              onPressed: () => _openAssetLibrary(initialTab: 1),
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.pets, size: 18),
              label: const Text('+ Add Emblem'),
              onPressed: () => _openAssetLibrary(initialTab: 2),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _colorChip('Field 1', c.divisionColor1, (val) {
                c.divisionColor1 = val;
                c.shieldPrimaryColor = val;
              }),
              _colorChip('Field 2', c.divisionColor2, (val) {
                c.divisionColor2 = val;
                c.shieldSecondaryColor = val;
              }),
              _colorChip('Outline', c.shieldStrokeColor, (val) {
                c.shieldStrokeColor = val;
              }),
              _colorChip('Bordure', c.bordureColor, (val) {
                c.bordureColor = val;
              }),
              _colorChip('Banner', c.bannerColor, (val) {
                c.bannerColor = val;
              }),
              _colorChip('Banner Text', c.bannerTextColor, (val) {
                c.bannerTextColor = val;
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Outlines:'),
            const SizedBox(width: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1x')),
                ButtonSegment(value: 2, label: Text('2x')),
                ButtonSegment(value: 3, label: Text('3x')),
              ],
              selected: {c.outlineCount},
              onSelectionChanged: (s) {
                setState(() => c.outlineCount = s.first);
                _pushHistory();
              },
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Bordure'),
              selected: c.hasBordure,
              onSelected: (v) {
                setState(() => c.hasBordure = v);
                _pushHistory();
              },
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('Arc Text'),
              selected: c.arcBannerText,
              onSelected: (v) {
                setState(() => c.arcBannerText = v);
                _pushHistory();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: c.topBannerText,
                decoration: const InputDecoration(
                  labelText: 'Top Banner',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() => c.topBannerText = v);
                  _pushHistory();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: c.bottomBannerText,
                decoration: const InputDecoration(
                  labelText: 'Bottom Ribbon',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() => c.bottomBannerText = v);
                  _pushHistory();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJerseyInspector() {
    final j = _kit.jersey;
    const zones = [
      'body',
      'sleeves',
      'collar',
      'cuffs',
      'side_panels',
      'yoke',
      'trim',
      'inner_collar',
      'shorts',
      'shorts_trim',
      'socks',
      'socks_turnover',
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: zones.map((zone) {
              final selected = _selectedJerseyZone == zone;
              final col = Color(j.zoneColors[zone] ?? 0xFFFFFFFF);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: col, radius: 8),
                  label: Text(zone.replaceAll('_', ' ').toUpperCase()),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedJerseyZone = zone);
                    _openColorPicker(
                      title: 'Zone: ${zone.toUpperCase()}',
                      currentColor: j.zoneColors[zone] ?? 0xFFFFFFFF,
                      onColorSelected: (val) => j.zoneColors[zone] = val,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              icon: const Icon(Icons.checkroom, size: 16),
              label: Text(JerseyLibrary.templateById(j.templateId).name),
              onPressed: () => _openAssetLibrary(initialTab: 4),
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.texture, size: 16),
              label: Text(
                  'Pattern: ${PatternLibrary.byId(j.bodyPattern.patternId).name}'),
              onPressed: () => _openAssetLibrary(initialTab: 3),
            ),
            _colorChip('Pattern 1', j.bodyPattern.primaryColor, (v) {
              j.bodyPattern.primaryColor = v;
            }),
            _colorChip('Pattern 2', j.bodyPattern.secondaryColor, (v) {
              j.bodyPattern.secondaryColor = v;
            }),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: j.collarId,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Collar'),
                items: JerseyLibrary.collars
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => j.collarId = v);
                    _pushHistory();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: j.trimId,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Trim / Stripes'),
                items: JerseyLibrary.trims
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => j.trimId = v);
                    _pushHistory();
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Pattern Scale'),
            Expanded(
              child: Slider(
                value: j.bodyPattern.scale.clamp(0.4, 2.5),
                min: 0.4,
                max: 2.5,
                onChanged: (v) => setState(() => j.bodyPattern.scale = v),
                onChangeEnd: (_) => _pushHistory(),
              ),
            ),
            const Text('Angle'),
            Expanded(
              child: Slider(
                value: j.bodyPattern.rotation.clamp(-180.0, 180.0),
                min: -180.0,
                max: 180.0,
                onChanged: (v) => setState(() => j.bodyPattern.rotation = v),
                onChangeEnd: (_) => _pushHistory(),
              ),
            ),
            FilterChip(
              label: const Text('Shading'),
              selected: j.fabricShading,
              onSelected: (v) {
                setState(() => j.fabricShading = v);
                _pushHistory();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShapeInspector() {
    final s = _selectedShape;
    if (s == null) {
      return Center(
        child: TextButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('No shape selected — Tap to browse 200+ Emblems'),
          onPressed: () => _openAssetLibrary(initialTab: 2),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _colorChip('Fill', s.fillColor, (val) => s.fillColor = val),
              _colorChip('Stroke', s.strokeColor, (val) => s.strokeColor = val),
              FilterChip(
                label: const Text('Edit Nodes'),
                selected: _nodeEditMode,
                onSelected: (v) => setState(() {
                  _nodeEditMode = v;
                  if (v && s.nodes.isEmpty) {
                    s.nodes = SvgParser.svgPathToNodes(s.svgPath);
                  }
                }),
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.flip, size: 16),
                label: const Text('Flip H'),
                onPressed: () {
                  setState(() => s.flipH = !s.flipH);
                  _pushHistory();
                },
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.flip_camera_android, size: 16),
                label: const Text('Flip V'),
                onPressed: () {
                  setState(() => s.flipV = !s.flipV);
                  _pushHistory();
                },
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                onPressed: () {
                  setState(() {
                    for (final l in _kit.layers) {
                      l.shapes.removeWhere((item) => item.id == s.id);
                    }
                    _selectedShapeId = null;
                  });
                  _pushHistory();
                },
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Text('Scale'),
            Expanded(
              child: Slider(
                value: s.scaleX.clamp(0.1, 2.0),
                min: 0.1,
                max: 2.0,
                onChanged: (v) => setState(() {
                  s.scaleX = v;
                  s.scaleY = v;
                }),
                onChangeEnd: (_) => _pushHistory(),
              ),
            ),
            const Text('Rotate'),
            Expanded(
              child: Slider(
                value: s.rotation.clamp(-180.0, 180.0),
                min: -180.0,
                max: 180.0,
                onChanged: (v) => setState(() => s.rotation = v),
                onChangeEnd: (_) => _pushHistory(),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Stroke'),
            Expanded(
              child: Slider(
                value: s.strokeWidth.clamp(0.0, 10.0),
                min: 0.0,
                max: 10.0,
                onChanged: (v) => setState(() => s.strokeWidth = v),
                onChangeEnd: (_) => _pushHistory(),
              ),
            ),
            const Text('Dash'),
            Expanded(
              child: Slider(
                value: s.dashLength.clamp(0.0, 20.0),
                min: 0.0,
                max: 20.0,
                onChanged: (v) => setState(() {
                  s.dashLength = v;
                  s.dashGap = v > 0 ? v * 0.6 : 0.0;
                }),
                onChangeEnd: (_) => _pushHistory(),
              ),
            ),
            DropdownButton<FillType>(
              value: s.fillType,
              isDense: true,
              items: const [
                DropdownMenuItem(value: FillType.solid, child: Text('Solid')),
                DropdownMenuItem(
                    value: FillType.linearGradient, child: Text('Linear Grad')),
                DropdownMenuItem(
                    value: FillType.radialGradient, child: Text('Radial Grad')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => s.fillType = v);
                  _pushHistory();
                }
              },
            ),
          ],
        ),
        if (_nodeEditMode)
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Node'),
                onPressed: () {
                  setState(() {
                    s.nodes.add(VectorNode(x: 50, y: 50));
                    s.svgPath = SvgParser.nodesToSvgPath(s.nodes, s.closed);
                  });
                  _pushHistory();
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.remove, size: 16),
                label: const Text('Delete Node'),
                onPressed: _selectedNodeIndex != null && s.nodes.length > 2
                    ? () {
                        setState(() {
                          s.nodes.removeAt(_selectedNodeIndex!);
                          _selectedNodeIndex = null;
                          s.svgPath =
                              SvgParser.nodesToSvgPath(s.nodes, s.closed);
                        });
                        _pushHistory();
                      }
                    : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTextAndStageInspector() {
    final j = _kit.jersey;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: j.playerName,
                decoration: const InputDecoration(
                  labelText: 'Back Player Name',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() => j.playerName = v.toUpperCase());
                  _pushHistory();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: j.playerNumber,
                decoration: const InputDecoration(
                  labelText: 'Number (0-99)',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() => j.playerNumber = v);
                  _pushHistory();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: j.sponsorText,
                decoration: const InputDecoration(
                  labelText: 'Front Sponsor',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() => j.sponsorText = v);
                  _pushHistory();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _colorChip('Number Fill', j.numberFillColor,
                  (v) => j.numberFillColor = v),
              _colorChip('Outline 1', j.numberOutlineColor,
                  (v) => j.numberOutlineColor = v),
              _colorChip('Outline 2', j.numberDoubleOutlineColor,
                  (v) => j.numberDoubleOutlineColor = v),
              _colorChip('Sponsor', j.sponsorColor, (v) => j.sponsorColor = v),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Front #'),
                selected: j.showFrontNumber,
                onSelected: (v) {
                  setState(() => j.showFrontNumber = v);
                  _pushHistory();
                },
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Chest Crest'),
                selected: j.showChestCrest,
                onSelected: (v) {
                  setState(() => j.showChestCrest = v);
                  _pushHistory();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: j.numberStyleId,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Number Font'),
                items: PresetLibrary.textStyles
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => j.numberStyleId = v);
                    _pushHistory();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _project.backgroundId,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Stage Background'),
                items: PresetLibrary.backgrounds
                    .map((b) =>
                        DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _project.backgroundId = v);
                    _pushHistory();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorChip(String label, int colorValue, ValueChanged<int> onPicked) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        avatar: CircleAvatar(
          backgroundColor: Color(colorValue),
          radius: 9,
        ),
        label: Text(label),
        onPressed: () => _openColorPicker(
          title: label,
          currentColor: colorValue,
          onColorSelected: onPicked,
        ),
      ),
    );
  }
}
