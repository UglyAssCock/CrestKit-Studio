import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/scene_models.dart';

class LayerPanelSheet extends StatefulWidget {
  final KitSet kit;
  final int activeLayerIndex;
  final String? selectedShapeId;
  final void Function(int layerIndex, String? shapeId) onSelectLayerAndShape;
  final VoidCallback onMutate;

  const LayerPanelSheet({
    super.key,
    required this.kit,
    required this.activeLayerIndex,
    required this.selectedShapeId,
    required this.onSelectLayerAndShape,
    required this.onMutate,
  });

  @override
  State<LayerPanelSheet> createState() => _LayerPanelSheetState();
}

class _LayerPanelSheetState extends State<LayerPanelSheet> {
  final Uuid _uuid = const Uuid();
  late int _currentLayer;

  @override
  void initState() {
    super.initState();
    _currentLayer = widget.activeLayerIndex;
  }

  @override
  Widget build(BuildContext context) {
    final layers = widget.kit.layers;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, scrollCtrl) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Vector Layers (${layers.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Layer'),
                  onPressed: () {
                    setState(() {
                      layers.add(
                        VectorLayer(
                          id: 'layer_${_uuid.v4().substring(0, 6)}',
                          name: 'Layer ${layers.length + 1}',
                        ),
                      );
                      _currentLayer = layers.length - 1;
                    });
                    widget.onSelectLayerAndShape(_currentLayer, null);
                    widget.onMutate();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ReorderableListView.builder(
                scrollController: scrollCtrl,
                itemCount: layers.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final moved = layers.removeAt(oldIndex);
                    layers.insert(newIndex, moved);
                    _currentLayer = newIndex;
                  });
                  widget.onMutate();
                },
                itemBuilder: (context, index) {
                  final layer = layers[index];
                  final isSelected = index == _currentLayer;
                  return Card(
                    key: ValueKey(layer.id),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35)
                        : null,
                    child: ExpansionTile(
                      initiallyExpanded: isSelected,
                      onExpansionChanged: (_) {
                        setState(() => _currentLayer = index);
                        widget.onSelectLayerAndShape(
                          index,
                          layer.shapes.isNotEmpty ? layer.shapes.first.id : null,
                        );
                      },
                      leading: IconButton(
                        icon: Icon(
                          layer.visible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => layer.visible = !layer.visible);
                          widget.onMutate();
                        },
                      ),
                      title: Text(
                        layer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${layer.shapes.length} shapes • ${(layer.opacity * 100).round()}%'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Lock / Unlock',
                            icon: Icon(
                              layer.locked ? Icons.lock : Icons.lock_open,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() => layer.locked = !layer.locked);
                              widget.onMutate();
                            },
                          ),
                          IconButton(
                            tooltip: 'Duplicate Layer',
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              setState(() {
                                final dup = layer.copy(
                                  newId: 'layer_${_uuid.v4().substring(0, 6)}',
                                )..name = '${layer.name} Copy';
                                layers.insert(index + 1, dup);
                              });
                              widget.onMutate();
                            },
                          ),
                          if (layers.length > 1)
                            IconButton(
                              tooltip: 'Delete Layer',
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () {
                                setState(() {
                                  layers.removeAt(index);
                                  if (_currentLayer >= layers.length) {
                                    _currentLayer = layers.length - 1;
                                  }
                                });
                                widget.onMutate();
                              },
                            ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Text('Opacity'),
                              Expanded(
                                child: Slider(
                                  value: layer.opacity,
                                  min: 0.1,
                                  max: 1.0,
                                  onChanged: (v) {
                                    setState(() => layer.opacity = v);
                                    widget.onMutate();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...layer.shapes.map((shape) {
                          final activeShape = shape.id == widget.selectedShapeId;
                          return ListTile(
                            dense: true,
                            selected: activeShape,
                            leading: CircleAvatar(
                              backgroundColor: Color(shape.fillColor),
                              radius: 10,
                            ),
                            title: Text(shape.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  onPressed: () {
                                    setState(() {
                                      final dup = shape.copy(
                                        newId: 'shape_${_uuid.v4().substring(0, 6)}',
                                      )
                                        ..tx += 6
                                        ..ty += 6;
                                      layer.shapes.add(dup);
                                    });
                                    widget.onMutate();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  onPressed: () {
                                    setState(() => layer.shapes.remove(shape));
                                    widget.onMutate();
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              widget.onSelectLayerAndShape(index, shape.id);
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
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
