import 'package:flutter/material.dart';
import '../models/scene_models.dart';

class ColorPickerSheet extends StatefulWidget {
  final String title;
  final int initialColor;
  final StudioProject project;
  final ValueChanged<int> onSelectColor;
  final void Function(int primary, int secondary, int accent)
      onUpdateTeamPalette;
  final VoidCallback onActivateEyedropper;

  const ColorPickerSheet({
    super.key,
    required this.title,
    required this.initialColor,
    required this.project,
    required this.onSelectColor,
    required this.onUpdateTeamPalette,
    required this.onActivateEyedropper,
  });

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late HSVColor _hsv;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(Color(widget.initialColor));
    _hexController = TextEditingController(text: _toHex(widget.initialColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _toHex(int val) =>
      val.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

  void _updateFromHsv(HSVColor next) {
    setState(() {
      _hsv = next;
      final c = next.toColor().value;
      _hexController.text = _toHex(c);
    });
    widget.onSelectColor(_hsv.toColor().value);
  }

  List<Color> _harmonies() {
    final comp = _hsv.withHue((_hsv.hue + 180) % 360).toColor();
    final ana1 = _hsv.withHue((_hsv.hue + 30) % 360).toColor();
    final ana2 = _hsv.withHue((_hsv.hue + 330) % 360).toColor();
    final tri1 = _hsv.withHue((_hsv.hue + 120) % 360).toColor();
    final tri2 = _hsv.withHue((_hsv.hue + 240) % 360).toColor();
    return [comp, ana1, ana2, tri1, tri2];
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _hsv.toColor();
    return Padding(
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
                CircleAvatar(backgroundColor: currentColor, radius: 16),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.colorize, size: 16),
                  label: const Text('Eyedropper'),
                  onPressed: widget.onActivateEyedropper,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 60, child: Text('Hue')),
                Expanded(
                  child: Slider(
                    value: _hsv.hue,
                    min: 0,
                    max: 360,
                    onChanged: (v) => _updateFromHsv(_hsv.withHue(v)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 60, child: Text('Sat')),
                Expanded(
                  child: Slider(
                    value: _hsv.saturation,
                    min: 0,
                    max: 1,
                    onChanged: (v) => _updateFromHsv(_hsv.withSaturation(v)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 60, child: Text('Value')),
                Expanded(
                  child: Slider(
                    value: _hsv.value,
                    min: 0,
                    max: 1,
                    onChanged: (v) => _updateFromHsv(_hsv.withValue(v)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _hexController,
                    decoration: const InputDecoration(
                      prefixText: '#',
                      labelText: 'HEX',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      final clean = v.replaceAll('#', '').trim();
                      if (clean.length == 6) {
                        final parsed = int.tryParse('FF$clean', radix: 16);
                        if (parsed != null) {
                          _updateFromHsv(HSVColor.fromColor(Color(parsed)));
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: [
                      ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor:
                              Color(widget.project.primaryTeamColor),
                        ),
                        label: const Text('Set 1°'),
                        onPressed: () => widget.onUpdateTeamPalette(
                          currentColor.value,
                          widget.project.secondaryTeamColor,
                          widget.project.accentTeamColor,
                        ),
                      ),
                      ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor:
                              Color(widget.project.secondaryTeamColor),
                        ),
                        label: const Text('Set 2°'),
                        onPressed: () => widget.onUpdateTeamPalette(
                          widget.project.primaryTeamColor,
                          currentColor.value,
                          widget.project.accentTeamColor,
                        ),
                      ),
                      ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor:
                              Color(widget.project.accentTeamColor),
                        ),
                        label: const Text('Set 3°'),
                        onPressed: () => widget.onUpdateTeamPalette(
                          widget.project.primaryTeamColor,
                          widget.project.secondaryTeamColor,
                          currentColor.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Harmony Suggestions (Complementary / Analogous / Triadic)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _harmonies().map((c) {
                return GestureDetector(
                  onTap: () => _updateFromHsv(HSVColor.fromColor(c)),
                  child: CircleAvatar(backgroundColor: c, radius: 15),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recent Project Colors',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.project.recentColors.map((val) {
                return GestureDetector(
                  onTap: () => _updateFromHsv(HSVColor.fromColor(Color(val))),
                  child: CircleAvatar(backgroundColor: Color(val), radius: 14),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
