import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import 'channel_adding_preview.dart';

/// A class to show a preview and handle adding a [ChannelInteractableDrawing]
/// to the chart. It's for when we're on [InteractiveLayerDesktopBehaviour].
class ChannelAddingPreviewDesktop extends ChannelAddingPreview {
  /// Initializes [ChannelAddingPreviewDesktop].
  ChannelAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 3));
  }

  Offset? _hoverPosition;

  @override
  String get id => 'channel-adding-preview-desktop';

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

    drawPointOffset(
      startOffset,
      epochToX,
      quoteToY,
      canvas,
      paintStyle,
      lineStyle,
    );

    final middlePoint = interactableDrawing.middlePoint;
    if (middlePoint == null) {
      if (_hoverPosition != null) {
        drawPreviewLine(canvas, startOffset, _hoverPosition!, lineStyle);
        drawPointAlignmentGuides(
          canvas,
          size,
          _hoverPosition!,
          lineColor: lineStyle.color,
        );
      }
      return;
    }

    final Offset middleOffset = edgePointToOffset(
      middlePoint,
      epochToX,
      quoteToY,
    );

    canvas.drawLine(
      startOffset,
      middleOffset,
      paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness),
    );
    drawPointOffset(
      middleOffset,
      epochToX,
      quoteToY,
      canvas,
      paintStyle,
      lineStyle,
    );

    if (_hoverPosition != null) {
      final double height = middleOffset.dy - _hoverPosition!.dy;
      final Offset endOffset = Offset(middleOffset.dx, _hoverPosition!.dy);
      final Offset secondLineStart = Offset(
        startOffset.dx,
        startOffset.dy - height,
      );

      // Walk the perimeter as bottom-left -> bottom-right -> top-right ->
      // top-left so the preview stays a proper (non-self-intersecting)
      // parallelogram regardless of draw direction.
      final bool startIsLeft = startOffset.dx <= middleOffset.dx;
      drawPreviewParallelogram(
        canvas,
        <Offset>[
          startIsLeft ? startOffset : middleOffset,
          startIsLeft ? middleOffset : startOffset,
          startIsLeft ? endOffset : secondLineStart,
          startIsLeft ? secondLineStart : endOffset,
        ],
        lineStyle,
      );
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
