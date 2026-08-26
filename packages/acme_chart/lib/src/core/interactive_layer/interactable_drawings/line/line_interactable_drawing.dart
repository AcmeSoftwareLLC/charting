import 'dart:math' as math;

import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import '../segment/segment_interactable_drawing.dart';
import 'line_adding_preview_desktop.dart';
import 'line_adding_preview_mobile.dart';

/// Interactable drawing implementation for the line drawing tool.
///
/// Its two anchor points (start/end), hit-test near them, drag, toolbar,
/// and hover/selection measurement label are all exactly
/// [SegmentInteractableDrawing]'s, inherited unmodified via `super.paint`
/// and `super.hitTest`. What makes it "Line" rather than "Segment": the
/// rendered — and clickable — line doesn't stop at those two points, it
/// extends past both of them to the chart's edges, the same way
/// Horizontal/Vertical extend across their one dimension; Line generalizes
/// that to whatever slope its two anchors define. The anchors themselves
/// never move from where they're placed/dragged — only the extension
/// redraws each frame, computed fresh from their current positions.
class LineInteractableDrawing extends SegmentInteractableDrawing {
  /// Initializes [LineInteractableDrawing].
  LineInteractableDrawing({
    required LineDrawingToolConfig super.config,
    required super.startPoint,
    required super.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  });

  /// Extends the ray from [through] away from [from] — i.e. starting at
  /// [from] and continuing in the direction opposite [through] — until it
  /// exits the rectangle bounded by (0, 0) and
  /// [DrawingContext.contentSize] (not `fullSize`, which extends into the
  /// Y-axis label column; a line reaching that far would render, and be
  /// clickable, underneath the Y-axis's own opaque background).
  Offset _extendToEdge(Offset from, Offset through) {
    final double dx = from.dx - through.dx;
    final double dy = from.dy - through.dy;

    if (dx == 0 && dy == 0) {
      return from;
    }

    final Size size = drawingContext.contentSize;
    double tMax = double.infinity;

    if (dx > 0) {
      tMax = math.min(tMax, (size.width - from.dx) / dx);
    } else if (dx < 0) {
      tMax = math.min(tMax, (0 - from.dx) / dx);
    }

    if (dy > 0) {
      tMax = math.min(tMax, (size.height - from.dy) / dy);
    } else if (dy < 0) {
      tMax = math.min(tMax, (0 - from.dy) / dy);
    }

    if (tMax.isInfinite || tMax <= 0) {
      return from;
    }

    return Offset(from.dx + dx * tMax, from.dy + dy * tMax);
  }

  /// Checks whether [offset] is within [hitTestMargin] of the bounded
  /// segment between [start] and [end].
  bool _isNearSegment(Offset offset, Offset start, Offset end) {
    final double segmentLength = (end - start).distance;
    if (segmentLength < 1) {
      return (offset - start).distance <= hitTestMargin;
    }

    final double distance =
        ((end.dy - start.dy) * offset.dx -
                (end.dx - start.dx) * offset.dy +
                end.dx * start.dy -
                end.dy * start.dx)
            .abs() /
        segmentLength;

    final double dotProduct =
        (offset.dx - start.dx) * (end.dx - start.dx) +
        (offset.dy - start.dy) * (end.dy - start.dy);
    final bool isWithinSegment =
        dotProduct >= 0 && dotProduct <= segmentLength * segmentLength;

    return isWithinSegment && distance <= hitTestMargin;
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    // Anchors + the bounded segment between them, exactly like Segment.
    if (super.hitTest(offset, epochToX, quoteToY)) {
      return true;
    }

    if (startPoint == null || endPoint == null) {
      return false;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final Offset extendedStart = _extendToEdge(startOffset, endOffset);
    final Offset extendedEnd = _extendToEdge(endOffset, startOffset);

    return _isNearSegment(offset, extendedStart, startOffset) ||
        _isNearSegment(offset, endOffset, extendedEnd);
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
    // Draws the bounded segment, glow, point markers, alignment guides, and
    // hover/selection measurement label exactly like Segment does.
    super.paint(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      chartConfig,
      chartTheme,
      getDrawingState,
    );

    if (startPoint == null || endPoint == null) {
      return;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final Offset extendedStart = _extendToEdge(startOffset, endOffset);
    final Offset extendedEnd = _extendToEdge(endOffset, startOffset);

    final LineStyle lineStyle = config.lineStyle;
    final Paint linePaint = DrawingPaintStyle().linePaintStyle(
      lineStyle.color,
      lineStyle.thickness,
    );

    // Continue the line past both anchors to the chart's edges, using the
    // same style — visually one continuous, longer line.
    canvas
      ..drawLine(extendedStart, startOffset, linePaint)
      ..drawLine(endOffset, extendedEnd, linePaint);
  }

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => LineAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => LineAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );
}
