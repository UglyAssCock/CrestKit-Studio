import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import '../painters/jersey_painter.dart';

class SquadSheet extends StatefulWidget {
  final StudioProject project;
  final KitSet kit;
  final ValueChanged<SquadPlayer> onApplyPlayer;
  final VoidCallback onMutateSquad;

  const SquadSheet({
    super.key,
    required this.project,
    required this.kit,
    required this.onApplyPlayer,
    required this.onMutateSquad,
  });

  @override
  State<SquadSheet> createState() => _SquadSheetState();
}

class _SquadSheetState extends State<SquadSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _numCtrl = TextEditingController(text: '12');
  bool _showNumberGenerator = false;

  void _addPlayer() {
    final name = _nameCtrl.text.trim().toUpperCase();
    final numVal = int.tryParse(_numCtrl.text.trim()) ?? 0;
    if (name.isEmpty) return;
    setState(() {
      widget.project.squad.add(
        SquadPlayer(name: name, number: numVal.clamp(0, 99)),
      );
      _nameCtrl.clear();
    });
    widget.onMutateSquad();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Squad Batch Preview & Number Set (0-99)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                FilterChip(
                  label: const Text('0-99 Grid'),
                  selected: _showNumberGenerator,
                  onSelected: (v) => setState(() => _showNumberGenerator = v),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_showNumberGenerator) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Player Name',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _numCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '#',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addPlayer,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    mainAxisExtent: 190,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: widget.project.squad.length,
                  itemBuilder: (context, index) {
                    final p = widget.project.squad[index];
                    final previewJersey = widget.kit.jersey.copy()
                      ..playerName = p.name
                      ..playerNumber = p.number.toString();
                    return Card(
                      child: InkWell(
                        onTap: () {
                          widget.onApplyPlayer(p);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  painter: JerseyPainter(
                                    jersey: previewJersey,
                                    crest: widget.kit.crest,
                                    layers: widget.kit.layers,
                                    viewMode: JerseyViewMode.back,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              Text(
                                '#${p.number} ${p.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.delete_outline, size: 16),
                                onPressed: () {
                                  setState(
                                      () => widget.project.squad.removeAt(index));
                                  widget.onMutateSquad();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 74,
                    mainAxisExtent: 56,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: 100,
                  itemBuilder: (context, numIdx) {
                    return OutlinedButton(
                      onPressed: () {
                        widget.onApplyPlayer(
                          SquadPlayer(
                            name: widget.kit.jersey.playerName,
                            number: numIdx,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        '$numIdx',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
