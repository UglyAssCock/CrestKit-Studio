import 'package:flutter/material.dart';
import '../models/scene_models.dart';

class ColorPickerSheet extends StatefulWidget {
  final int initialColor;
  final StudioProject project;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<StudioProject> onProjectPaletteUpdated;

  const ColorPickerSheet({
    super.key,
    required this.initialColor,
    required this.project,
    required this.onColorSelected,
    required this.onProjectPaletteUpdated,
  });

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late HSVColor _hsv;
  late TextEditingController _hexCtrl;

  static const List<int> _presetSwatches = [
    0xFFDC2626,
    0xFFB91C1C,
    0xFFF97316,
    0xFFFACC15,
    0xFFD4AF37,
    0xFF16A34A,
    0xFF10B981,
    0xFF00E5A3,
    0xFF06B6D4,
    0xFF38BDF8,
    0xFF1D4ED8,
    0xFF1E3A8A,
    0xFF7C3AED,
    0xFF581C87,
    0xFFEC4899,
    0xFFF43F5E,
    0xFFFFFFFF,
    0xFFE2E8F0,
    0xFF94A3B8,
    0xFF475569,
    0xFF1E293B,
    0xFF0F172A,
    0xFF090D16,
    0xFF000000,
  ];

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(Color(widget.initialColor));
    _hexCtrl = TextEditingController(text: _toHex(widget.initialColor));
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  String _toHex(int val) =>
      (val & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  void _setColorFromInt(int val) {
    setState(() {
      _hsv = HSVColor.fromColor(Color(val));
      _hexCtrl.text = _toHex(val);
    });
  }

  List<int> _harmonyColors() {
    final comp = _hsv.withHue((_hsv.hue + 180) % 360).toColor().value;
    final ana1 = _hsv.withHue((_hsv.hue + 30) % 360).toColor().value;
    final ana2 = _hsv.withHue((_hsv.hue + 330) % 360).toColor().value;
    final tri1 = _hsv.withHue((_hsv.hue + 120) % 360).toColor().value;
    final tri2 = _hsv.withHue((_hsv.hue + 240) % 360).toColor().value;
    return [comp, ana1, ana2, tri1, tri2];
  }

  void _applyAndClose(int colorVal) {
    if (!widget.project.recentColors.contains(colorVal)) {
      widget.project.recentColors.insert(0, colorVal);
      if (widget.project.recentColors.length > 12) {
        widget.project.recentColors.removeLast();
      }
      widget.onProjectPaletteUpdated(widget.project);
    }
    widget.onColorSelected(colorVal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hsv.toColor();
    final harmonies = _harmonyColors();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white38, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _hexCtrl,
                      decoration: const InputDecoration(
                        labelText: 'HEX Color',
                        prefixText: '#',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (v) {
                        final cleaned = v.replaceAll('#', '').trim();
                        if (cleaned.length == 6) {
                          final parsed = int.tryParse('FF$cleaned', radix: 16);
                          if (parsed != null) _setColorFromInt(parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () => _applyAndClose(currentColor.value),
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Club Team Palette (Tap to use, Long-press to overwrite with current)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _teamSlot(
                    label: 'Primary',
                    colorVal: widget.project.primaryTeamColor,
                    onTap: () =>
                        _setColorFromInt(widget.project.primaryTeamColor),
                    onLongPress: () {
                      setState(() {
                        widget.project.primaryTeamColor = currentColor.value;
                      });
                      widget.onProjectPaletteUpdated(widget.project);
                    },
                  ),
                  const SizedBox(width: 8),
                  _teamSlot(
                    label: 'Secondary',
                    colorVal: widget.project.secondaryTeamColor,
                    onTap: () =>
                        _setColorFromInt(widget.project.secondaryTeamColor),
                    onLongPress: () {
                      setState(() {
                        widget.project.secondaryTeamColor = currentColor.value;
                      });
                      widget.onProjectPaletteUpdated(widget.project);
                    },
                  ),
                  const SizedBox(width: 8),
                  _teamSlot(
                    label: 'Accent',
                    colorVal: widget.project.accentTeamColor,
                    onTap: () =>
                        _setColorFromInt(widget.project.accentTeamColor),
                    onLongPress: () {
                      setState(() {
                        widget.project.accentTeamColor = currentColor.value;
                      });
                      widget.onProjectPaletteUpdated(widget.project);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSlider(
                label: 'Hue (${_hsv.hue.round()}°)',
                value: _hsv.hue,
                max: 360,
                onChanged: (v) => setState(() {
                  _hsv = _hsv.withHue(v);
                  _hexCtrl.text = _toHex(_hsv.toColor().value);
                }),
              ),
              _buildSlider(
                label: 'Saturation (${(_hsv.saturation * 100).round()}%)',
                value: _hsv.saturation,
                max: 1.0,
                onChanged: (v) => setState(() {
                  _hsv = _hsv.withSaturation(v);
                  _hexCtrl.text = _toHex(_hsv.toColor().value);
                }),
              ),
              _buildSlider(
                label: 'Brightness (${(_hsv.value * 100).round()}%)',
                value: _hsv.value,
                max: 1.0,
                onChanged: (v) => setState(() {
                  _hsv = _hsv.withValue(v);
                  _hexCtrl.text = _toHex(_hsv.toColor().value);
                }),
              ),
              const SizedBox(height: 8),
              const Text(
                'Color Harmonies (Complementary, Analogous, Triadic)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: harmonies.map((c) => _swatchChip(c)).toList(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Studio Swatches & Recent Colors',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...widget.project.recentColors,
                  ..._presetSwatches.where(
                    (c) => !widget.project.recentColors.contains(c),
                  ),
                ].map((c) => _swatchChip(c)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamSlot({
    required String label,
    required int colorVal,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(colorVal),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 115,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(0.0, max),
            min: 0.0,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _swatchChip(int colorVal) {
    return GestureDetector(
      onTap: () => _setColorFromInt(colorVal),
      onDoubleTap: () => _applyAndClose(colorVal),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Color(colorVal),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white38),
        ),
      ),
    );
  }
}
