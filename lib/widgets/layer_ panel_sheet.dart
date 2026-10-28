import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import '../painters/jersey_painter.dart';

class SquadSheet extends StatefulWidget {
  final StudioProject project;
  final KitSet activeKit;
  final ValueChanged<SquadPlayer> onSelectPlayer;
  final VoidCallback onChanged;

  const SquadSheet({
    super.key,
    required this.project,
    required this.activeKit,
    required this.onSelectPlayer,
    required this.onChanged,
  });

  @override
  State<SquadSheet> createState() => _SquadSheetState();
}

class _SquadSheetState extends State<SquadSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addPlayerDialog() async {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController(text: '12');
    final roleCtrl = TextEditingController(text: 'MID');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Squad Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Shirt Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number (0-99)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Position (GK/DEF/MID/FWD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      setState(() {
        widget.project.squad.add(
          SquadPlayer(
            name: nameCtrl.text.trim().toUpperCase(),
            number: (int.tryParse(numCtrl.text) ?? 10).clamp(0, 99),
            role: roleCtrl.text.trim().toUpperCase(),
          ),
        );
      });
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.80,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.groups, color: Color(0xFF00E5A3)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Squad Batch Preview & Number Set (0-99)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _addPlayerDialog,
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Add Player'),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Squad Jerseys (${widget.project.squad.length})'),
                const Tab(text: '0-99 Number Generator'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Batch Squad Jersey Previews
                  GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: widget.project.squad.length,
                    itemBuilder: (context, index) {
                      final player = widget.project.squad[index];
                      final previewJersey = widget.activeKit.jersey.copy()
                        ..playerName = player.name
                        ..playerNumber = player.number.toString();

                      return InkWell(
                        onTap: () {
                          widget.onSelectPlayer(player);
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CustomPaint(
                                    size: const Size(100, 100),
                                    painter: JerseyPainter(
                                      jersey: previewJersey,
                                      crest: widget.activeKit.crest,
                                      crestLayers: widget.activeKit.layers,
                                      viewMode: 'back',
                                    ),
                                  ),
                                ),
                                Text(
                                  '#${player.number} ${player.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      player.role,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          widget.project.squad.removeAt(index);
                                        });
                                        widget.onChanged();
                                      },
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Tab 2: 0-99 Number Set Generator
                  GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 100,
                    itemBuilder: (context, number) {
                      return InkWell(
                        onTap: () {
                          widget.onSelectPlayer(
                            SquadPlayer(
                              name: widget.activeKit.jersey.playerName,
                              number: number,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(
                              widget.activeKit.jersey.zoneColors['body'] ??
                                  0xFFDC2626,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            number.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color:
                                  Color(widget.activeKit.jersey.numberFillColor),
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
      ),
    );
  }
}
