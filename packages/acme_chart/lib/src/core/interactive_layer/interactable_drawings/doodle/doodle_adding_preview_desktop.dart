import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import 'doodle_adding_preview.dart';

/// A class to show a preview and handle adding a
/// [DoodleInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour].
///
/// Unlike the tap-to-place tools, a doodle is drawn by a single
/// press-drag-release gesture: [onDragStart] begins the stroke,
/// [onDragUpdate] samples points along the drag, and [onDragEnd] finishes
/// it.
class DoodleAddingPreviewDesktop extends DoodleAddingPreview {
  /// Initializes [DoodleAddingPreviewDesktop].
  DoodleAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 1));
  }

  @override
  String get id => 'doodle-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    startStroke(details.localPosition, epochFromX, quoteFromY);
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    extendStrokeByDelta(details.delta, epochFromX, quoteFromY);
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    finishStroke();
    onAddingStateChange(AddingStateInfo(1, 1));
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    if (interactableDrawing.points.isEmpty) {
      return;
    }

    final lineStyle = getLineStyle();
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final List<EdgePoint> points = interactableDrawing.points;

    final Path path = Path()
      ..moveTo(epochToX(points.first.epoch), quoteToY(points.first.quote));
    for (final EdgePoint point in points.skip(1)) {
      path.lineTo(epochToX(point.epoch), quoteToY(point.quote));
    }

    canvas.drawPath(
      path,
      paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // A doodle is drawn by dragging, not tapping — nothing to do here.
  }
}
