import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import 'rectangle_adding_preview.dart';

/// A class to show a preview and handle adding a
/// [RectangleInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour].
class RectangleAddingPreviewDesktop extends RectangleAddingPreview {
  /// Initializes [RectangleAddingPreviewDesktop].
  RectangleAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 2));
  }

  Offset? _hoverPosition;

  @override
  String get id => 'rectangle-adding-preview-desktop';

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  void onHover(
    PointerHoverEvent event,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    _hoverPosition = event.localPosition;
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
    final startPoint = interactableDrawing.startPoint;
    if (startPoint == null) {
      return;
    }

    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final lineStyle = getLineStyle();
    final Offset startOffset = edgePointToOffset(
      startPoint,
      epochToX,
      quoteToY,
    );

    drawFocusedCircle(paintStyle, lineStyle, canvas, startOffset, 10, 3);

    if (_hoverPosition != null) {
      drawPreviewRect(canvas, startOffset, _hoverPosition!, lineStyle);
      drawPointAlignmentGuides(
        canvas,
        size,
        _hoverPosition!,
        lineColor: lineStyle.color,
      );
    }
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    createPoint(details, epochFromX, quoteFromY);
  }
}
