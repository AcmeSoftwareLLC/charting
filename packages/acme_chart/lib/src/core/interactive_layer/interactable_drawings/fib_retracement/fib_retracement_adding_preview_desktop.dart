import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/enums/drawing_tool_state.dart';
import '../../../../core/interactive_layer/interactable_drawings/drawing_v2.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import 'fib_retracement_adding_preview.dart';

/// A class to show a preview and handle adding a
/// [FibRetracementInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour].
class FibRetracementAddingPreviewDesktop extends FibRetracementAddingPreview {
  /// Initializes [FibRetracementAddingPreviewDesktop].
  FibRetracementAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 2));
  }

  Offset? _hoverPosition;
  EdgePoint? _hoverPoint;

  @override
  String get id => 'fib-retracement-adding-preview-desktop';

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
    _hoverPoint = EdgePoint(
      epoch: epochFromX(event.localPosition.dx),
      quote: quoteFromY(event.localPosition.dy),
    );
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

    final EdgePoint? hoverPoint = _hoverPoint;
    if (hoverPoint != null) {
      // Preview the full retracement fan (levels + shaded bands) live,
      // following the cursor, instead of just a bare reference line — the
      // user should see what they're about to place before the second
      // click commits it. `endPoint` is only set for the duration of this
      // paint call and restored to null right after, so the real second
      // click (which relies on `endPoint` still being null to know it
      // hasn't been placed yet) isn't affected.
      Set<DrawingToolState> mockGetDrawingState(DrawingV2 drawing) => {
        DrawingToolState.selected,
      };
      interactableDrawing.endPoint = hoverPoint;
      try {
        interactableDrawing.paint(
          canvas,
          size,
          epochToX,
          quoteToY,
          animationInfo,
          chartConfig,
          chartTheme,
          mockGetDrawingState,
        );
      } finally {
        // Always clear this back to null, even if the delegated paint
        // throws — otherwise the real second click's `endPoint ??= ...`
        // (in createPoint) would silently no-op forever, since it'd see
        // this leftover hover value instead of null.
        interactableDrawing.endPoint = null;
      }
      drawPointAlignmentGuides(
        canvas,
        size,
        _hoverPosition!,
        lineColor: lineStyle.color,
      );
    } else {
      drawFocusedCircle(paintStyle, lineStyle, canvas, startOffset, 10, 3);
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
