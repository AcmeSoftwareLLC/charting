import 'dart:math' as math;

import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/extensions/extensions.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/enums/drawing_tool_state.dart';
import '../../../../models/axis_range.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../theme/painting_styles/line_style.dart';
import '../../../../widgets/color_picker/color_picker_dropdown_button.dart';
import '../../../../widgets/dropdown/line_thickness/line_thickness_dropdown_button.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'fibfan_adding_preview_desktop.dart';
import 'fibfan_adding_preview_mobile.dart';

/// A single fan ray's Fibonacci fraction and its label.
class _FibLevel {
  const _FibLevel(this.fraction, this.label);

  /// Fraction of the start->end span this ray's far point sits at, e.g.
  /// `0.618` for the 61.8% ray. `0` and `1` are the two rays that bound the
  /// fan (0% runs horizontal through the start point; 100% is the start->end
  /// line itself, extended).
  final double fraction;

  /// The label shown next to this ray, e.g. `'61.8%'`.
  final String label;
}

/// The five rays a Fibonacci fan is conventionally drawn with, in ascending
/// order (used to pick adjacent pairs for the shaded wedges between them).
const List<_FibLevel> _fibFanLevels = <_FibLevel>[
  _FibLevel(0, '0%'),
  _FibLevel(0.382, '38.2%'),
  _FibLevel(0.5, '50%'),
  _FibLevel(0.618, '61.8%'),
  _FibLevel(1, '100%'),
];

/// A single fan ray's projected geometry, computed once per paint/hit-test
/// call and reused throughout.
class _FanRay {
  const _FanRay({required this.level, required this.farOffset});

  final _FibLevel level;

  /// Where this ray exits the chart's bounds, starting from the anchor
  /// ([FibfanInteractableDrawing.startPoint]) and passing through the point
  /// at this ray's fraction of the start->end span.
  final Offset farOffset;
}

/// Interactable drawing implementation for the Fibonacci fan drawing tool.
///
/// Anchors two points ([startPoint], [endPoint]) defining a base price span,
/// then fans five rays out from [startPoint] — one per [_fibFanLevels]
/// fraction of that span — each extended to the edge of the visible chart.
/// This is the classic Fibonacci fan: diagonal rays sharing a common origin,
/// not the horizontal retracement-style levels [TradeRatioInteractableDrawing]
/// draws.
class FibfanInteractableDrawing
    extends InteractableDrawing<FibfanDrawingToolConfig> {
  /// Initializes [FibfanInteractableDrawing].
  FibfanInteractableDrawing({
    required FibfanDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// The anchor all fan rays originate from.
  EdgePoint? startPoint;

  /// Defines the base span the fan's fractions are measured against.
  EdgePoint? endPoint;

  /// Tracks which point is being dragged, if any.
  ///
  /// [null]: dragging the whole fan.
  ///
  /// [true]: dragging the start anchor.
  ///
  /// [false]: dragging the end anchor.
  bool? isDraggingStartPoint;

  /// Extends the ray from [start] through [through] until it exits the
  /// rectangle bounded by (0, 0) and [drawingContext.contentSize], returning
  /// the exit point. Falls back to [through] itself if it can't make
  /// progress in that direction (already at/past the boundary).
  ///
  /// Uses [DrawingContext.contentSize] rather than [DrawingContext.fullSize]
  /// because the latter extends into the Y-axis label column — a ray (and
  /// its percentage label) reaching all the way to `fullSize` would render
  /// underneath the Y-axis's own opaque background and be invisible.
  Offset _extendToEdge(Offset start, Offset through) {
    final double dx = through.dx - start.dx;
    final double dy = through.dy - start.dy;

    if (dx == 0 && dy == 0) {
      return through;
    }

    final Size size = drawingContext.contentSize;
    double tMax = double.infinity;

    if (dx > 0) {
      tMax = math.min(tMax, (size.width - start.dx) / dx);
    } else if (dx < 0) {
      tMax = math.min(tMax, (0 - start.dx) / dx);
    }

    if (dy > 0) {
      tMax = math.min(tMax, (size.height - start.dy) / dy);
    } else if (dy < 0) {
      tMax = math.min(tMax, (0 - start.dy) / dy);
    }

    if (tMax.isInfinite || tMax <= 0) {
      return through;
    }

    return Offset(start.dx + dx * tMax, start.dy + dy * tMax);
  }

  /// Projects all five fan rays for the current [startPoint]/[endPoint] and
  /// chart size.
  List<_FanRay> _rays(EpochToX epochToX, QuoteToY quoteToY) {
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final double dy = endOffset.dy - startOffset.dy;

    return _fibFanLevels.map((_FibLevel level) {
      final Offset through = Offset(
        endOffset.dx,
        startOffset.dy + dy * level.fraction,
      );
      return _FanRay(
        level: level,
        farOffset: _extendToEdge(startOffset, through),
      );
    }).toList();
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
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

    final double startDistance = (details.localPosition - startOffset).distance;
    final double endDistance = (details.localPosition - endOffset).distance;

    if (startDistance <= hitTestMargin) {
      isDraggingStartPoint = true;
    } else if (endDistance <= hitTestMargin) {
      isDraggingStartPoint = false;
    } else {
      isDraggingStartPoint = null;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
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

    if ((offset - startOffset).distance <= hitTestMargin ||
        (offset - endOffset).distance <= hitTestMargin) {
      return true;
    }

    for (final _FanRay ray in _rays(epochToX, quoteToY)) {
      if (_isNearSegment(offset, startOffset, ray.farOffset)) {
        return true;
      }
    }

    return false;
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
    if (startPoint == null || endPoint == null) {
      return;
    }

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final List<_FanRay> rays = _rays(epochToX, quoteToY);

    // Shade the wedge between each pair of adjacent rays, matching how a
    // Fibonacci fan is conventionally drawn.
    for (int i = 0; i < rays.length - 1; i++) {
      final Path wedge = Path()
        ..moveTo(startOffset.dx, startOffset.dy)
        ..lineTo(rays[i].farOffset.dx, rays[i].farOffset.dy)
        ..lineTo(rays[i + 1].farOffset.dx, rays[i + 1].farOffset.dy)
        ..close();
      canvas.drawPath(
        wedge,
        paintStyle.fillPaintStyle(config.fillStyle.color, lineStyle.thickness),
      );
    }

    for (final _FanRay ray in rays) {
      canvas.drawLine(
        startOffset,
        ray.farOffset,
        paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness),
      );

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(text: ray.level.label, style: config.labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(
          ray.farOffset.dx - labelPainter.width - 4,
          ray.farOffset.dy - labelPainter.height - 2,
        ),
      );
    }

    if (drawingState.contains(DrawingToolState.selected)) {
      final Paint neonPaint = Paint()
        ..color = lineStyle.color.withValues(alpha: 0.4)
        ..strokeWidth = 8 * animationInfo.stateChangePercent
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(startOffset, endOffset, neonPaint);
    }

    if (drawingState.contains(DrawingToolState.selected) ||
        drawingState.contains(DrawingToolState.hovered) ||
        drawingState.contains(DrawingToolState.dragging)) {
      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      drawPointOffset(
        endOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );

      if (drawingState.contains(DrawingToolState.dragging) &&
          isDraggingStartPoint != null) {
        final Offset draggedOffset = isDraggingStartPoint!
            ? startOffset
            : endOffset;
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          draggedOffset,
          10 * animationInfo.stateChangePercent,
          3 * animationInfo.stateChangePercent,
        );
      } else if ((drawingState.contains(DrawingToolState.selected) ||
              drawingState.contains(DrawingToolState.hovered)) &&
          !drawingState.contains(DrawingToolState.dragging)) {
        drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          drawingState.contains(DrawingToolState.selected)
              ? 10 * animationInfo.stateChangePercent
              : 10,
          drawingState.contains(DrawingToolState.selected)
              ? 3 * animationInfo.stateChangePercent
              : 3,
          endOffset,
        );
      }
    }

    if (drawingState.contains(DrawingToolState.dragging)) {
      if (isDraggingStartPoint == null) {
        drawPointAlignmentGuides(
          canvas,
          size,
          startOffset,
          lineColor: lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          endOffset,
          lineColor: lineStyle.color,
        );
      } else {
        drawPointAlignmentGuides(
          canvas,
          size,
          isDraggingStartPoint! ? startOffset : endOffset,
          lineColor: lineStyle.color,
        );
      }
    }
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    final Offset delta = details.delta;

    if (isDraggingStartPoint != null) {
      final EdgePoint pointBeingDragged = isDraggingStartPoint!
          ? startPoint!
          : endPoint!;

      final Offset currentOffset = Offset(
        epochToX(pointBeingDragged.epoch),
        quoteToY(pointBeingDragged.quote),
      );
      final Offset newOffset = currentOffset + delta;

      final EdgePoint updatedPoint = EdgePoint(
        epoch: epochFromX(newOffset.dx),
        quote: quoteFromY(newOffset.dy),
      );

      if (isDraggingStartPoint!) {
        startPoint = updatedPoint;
      } else {
        endPoint = updatedPoint;
      }
    } else {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      final Offset newStartOffset = startOffset + delta;
      final Offset newEndOffset = endOffset + delta;

      startPoint = EdgePoint(
        epoch: epochFromX(newStartOffset.dx),
        quote: quoteFromY(newStartOffset.dy),
      );
      endPoint = EdgePoint(
        epoch: epochFromX(newEndOffset.dx),
        quote: quoteFromY(newEndOffset.dy),
      );
    }
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    isDraggingStartPoint = null;
    config = getUpdatedConfig();
  }

  @override
  FibfanDrawingToolConfig getUpdatedConfig() =>
      config.copyWith(edgePoints: <EdgePoint>[?startPoint, ?endPoint]);

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      (startPoint?.isInEpochRange(
            epochRange.leftEpoch,
            epochRange.rightEpoch,
          ) ??
          true) ||
      (endPoint?.isInEpochRange(epochRange.leftEpoch, epochRange.rightEpoch) ??
          true);

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => FibfanAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => FibfanAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
    children: <Widget>[
      _buildLineThicknessIcon(onUpdate),
      const SizedBox(width: 4),
      _buildLineColorPickerIcon(onUpdate),
      const SizedBox(width: 4),
      _buildFillColorPickerIcon(onUpdate),
    ],
  );

  Widget _buildLineColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
    width: 32,
    height: 32,
    child: ColorPickerDropdownButton(
      currentColor: config.lineStyle.color,
      onColorChanged: (newColor) => onUpdate(
        config.copyWith(lineStyle: config.lineStyle.copyWith(color: newColor)),
      ),
    ),
  );

  Widget _buildFillColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
    width: 32,
    height: 32,
    child: ColorPickerDropdownButton(
      currentColor: config.fillStyle.color,
      onColorChanged: (newColor) => onUpdate(
        config.copyWith(fillStyle: config.fillStyle.copyWith(color: newColor)),
      ),
    ),
  );

  Widget _buildLineThicknessIcon(UpdateDrawingTool onUpdate) =>
      LineThicknessDropdownButton(
        thickness: config.lineStyle.thickness,
        onValueChanged: (double newValue) {
          onUpdate(
            config.copyWith(
              lineStyle: config.lineStyle.copyWith(thickness: newValue),
            ),
          );
        },
      );
}
