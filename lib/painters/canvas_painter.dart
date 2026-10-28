import 'package:flutter/material.dart';
import '../models/scene_models.dart';
import 'crest_painter.dart';
import 'jersey_painter.dart';

class CanvasPainter extends CustomPainter {
  final KitSet kit;
  final bool showCrest;
  final bool showJersey;
  final JerseyViewMode jerseyView;
  final String selectedJerseyZone;
  final String? selectedShapeId;
  final int? selectedNodeIndex;
  final bool showGrid;
  final double gridSize;
  final bool symmetryMode;
  final bool nodeEditMode;

  const CanvasPainter({
    required this.kit,
    this.showCrest = true,
    this.showJersey = false,
    this.jerseyView = JerseyViewMode.front,
    this.selectedJerseyZone = 'body',
    this.selectedShapeId,
    this.selectedNodeIndex,
    this.showGrid = false,
    this.gridSize = 10.0,
    this.symmetryMode = false,
    this.nodeEditMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showJersey) {
      JerseyPainter(
        jersey: kit.jersey,
        crest: kit.crest,
        layers: kit.layers,
        viewMode: jerseyView,
        highlightedZone: selectedJerseyZone,
      ).paint(canvas, size);
      return;
    }

    if (showCrest) {
      CrestPainter(
        crest: kit.crest,
        layers: kit.layers,
      ).paint(canvas, size);
      return;
    }

    CrestPainter.paintVectorLayersOnly(canvas, size, kit.layers);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}

class CanvasOverlayGuidesPainter extends CustomPainter {
  final KitSet kit;
  final String? selectedShapeId;
  final int? selectedNodeIndex;
  final bool showGrid;
  final double gridSize;
  final bool symmetryMode;
  final bool nodeEditMode;

  const CanvasOverlayGuidesPainter({
    required this.kit,
    this.selectedShapeId,
    this.selectedNodeIndex,
    this.showGrid = true,
    this.gridSize = 10.0,
    this.symmetryMode = false,
    this.nodeEditMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final ox = (size.width - side) / 2.0;
    final oy = (size.height - side) / 2.0;

    canvas.save();
    canvas.translate(ox, oy);

    if (showGrid && gridSize > 0) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 0.8;
      final step = (gridSize / 100.0) * side;
      for (double v = 0; v <= side; v += step) {
        canvas.drawLine(Offset(v, 0), Offset(v, side), gridPaint);
        canvas.drawLine(Offset(0, v), Offset(side, v), gridPaint);
      }
    }

    if (symmetryMode) {
      final symPaint = Paint()
        ..color = const Color(0xFF00E5A3).withValues(alpha: 0.75)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(side / 2, 0), Offset(side / 2, side), symPaint);
    }

    if (selectedShapeId != null) {
      VectorShape? shape;
      for (final l in kit.layers) {
        for (final s in l.shapes) {
          if (s.id == selectedShapeId) {
            shape = s;
            break;
          }
        }
      }

      if (shape != null) {
        final cx = (shape.tx / 100.0) * side;
        final cy = (shape.ty / 100.0) * side;
        final halfW = (38.0 * shape.scaleX.abs() / 100.0) * side;
        final halfH = (38.0 * shape.scaleY.abs() / 100.0) * side;

        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(shape.rotation * 3.14159265 / 180.0);

        final boxRect = Rect.fromCenter(
          center: Offset.zero,
          width: halfW * 2,
          height: halfH * 2,
        );
        canvas.drawRect(
          boxRect,
          Paint()
            ..color = const Color(0xFF00E5A3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );

        for (final corner in [
          boxRect.topLeft,
          boxRect.topRight,
          boxRect.bottomLeft,
          boxRect.bottomRight,
        ]) {
          canvas.drawCircle(
            corner,
            4.5,
            Paint()..color = const Color(0xFF00E5A3),
          );
        }

        if (nodeEditMode && shape.nodes.isNotEmpty) {
          for (int i = 0; i < shape.nodes.length; i++) {
            final n = shape.nodes[i];
            final nx = ((n.x - 50.0) / 100.0) * side * shape.scaleX;
            final ny = ((n.y - 50.0) / 100.0) * side * shape.scaleY;
            final isSelected = i == selectedNodeIndex;
            canvas.drawCircle(
              Offset(nx, ny),
              isSelected ? 6.0 : 4.2,
              Paint()
                ..color =
                    isSelected ? Colors.amberAccent : const Color(0xFF38BDF8),
            );
          }
        }

        canvas.restore();
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CanvasOverlayGuidesPainter oldDelegate) => true;
}
