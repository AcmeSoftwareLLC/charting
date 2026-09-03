import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/fib_retracement/fib_retracement_drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/enums/drawing_tool_state.dart';
import '../../../../models/axis_range.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../theme/painting_styles/line_style.dart';
import '../../../../widgets/color_picker/color_picker_dropdown_button.dart';
import '../../../../widgets/dropdown/line_thickness/line_thickness_dropdown_button.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'fib_retracement_adding_preview_desktop.dart';
import 'fib_retracement_adding_preview_mobile.dart';

/// A single retracement level's Fibonacci fraction and its label.
class _FibLevel {
  const _FibLevel(this.fraction, this.label);

  /// Fraction of the end->start span this level sits at, e.g. `0.618` for
  /// the 61.8% level. `0` sits at the end anchor's price, `1` at the start
  /// anchor's price; fractions beyond `1` (e.g. `1.618`) extrapolate past
  /// the start anchor in the same direction.
  final double fraction;

  /// The label shown next to this level, e.g. `'61.8%'`.
  final String label;
}

/// The nine levels a Fibonacci retracement is conventionally drawn with, in
/// ascending order (used to pick adjacent pairs for the shaded bands between
/// them). Matches ChartIQ's `fibRetracement` recommended levels.
const List<_FibLevel> _fibRetracementLevels = <_FibLevel>[
  _FibLevel(0, '0%'),
  _FibLevel(0.236, '23.6%'),
  _FibLevel(0.382, '38.2%'),
  _FibLevel(0.5, '50%'),
  _FibLevel(0.618, '61.8%'),
  _FibLevel(0.786, '78.6%'),
  _FibLevel(1, '100%'),
  _FibLevel(1.382, '138.2%'),
  _FibLevel(1.618, '161.8%'),
];

/// A single level's projected on-screen geometry, computed once per
/// paint/hit-test call and reused throughout.
class _RetracementLine {
  const _RetracementLine({
    required this.level,
    required this.nearOffset,
    required this.farOffset,
  });

  final _FibLevel level;

  /// Where this level's line starts: the point on the (possibly
  /// extrapolated) diagonal line through [FibRetracementInteractableDrawing.startPoint]
  /// and [FibRetracementInteractableDrawing.endPoint] at this level's
  /// fraction of that span.
  final Offset nearOffset;

  /// Where this level's line ends: always the right edge of the chart's
  /// content area (excluding the Y-axis label column), at the same height
  /// as [nearOffset].
  final Offset farOffset;
}

/// Interactable drawing implementation for the Fibonacci retracement
/// drawing tool.
///
/// Anchors two points ([startPoint], [endPoint]) defining a base price
/// span, then draws [_fibRetracementLevels] as horizontal lines: each
/// level's line starts on the diagonal line through the two anchors (at
/// that level's fraction between [endPoint]'s price and [startPoint]'s
/// price) and extends horizontally to the chart's right edge. This is the
/// classic Fibonacci retracement — horizontal levels along a shared
/// diagonal — not the diagonal rays [FibfanInteractableDrawing] fans out,
/// nor the draggable/extendable levels [TradeRatioInteractableDrawing]
/// draws.
class FibRetracementInteractableDrawing
    extends InteractableDrawing<FibRetracementDrawingToolConfig> {
  /// Initializes [FibRetracementInteractableDrawing].
  FibRetracementInteractableDrawing({
    required FibRetracementDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// The anchor whose price maps to the 100% level.
  EdgePoint? startPoint;

  /// The anchor whose price maps to the 0% level.
  EdgePoint? endPoint;

  /// Tracks which point is being dragged, if any.
  ///
  /// [null]: dragging the whole drawing.
  ///
  /// [true]: dragging the start anchor.
  ///
  /// [false]: dragging the end anchor.
  bool? isDraggingStartPoint;

  /// Projects all nine retracement levels for the current
  /// [startPoint]/[endPoint] and chart size.
  List<_RetracementLine> _lines(EpochToX epochToX, QuoteToY quoteToY) {
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    // contentSize excludes the Y-axis label column; extending to fullSize
    // would put the level lines' labels underneath the Y-axis's own opaque
    // background, making them invisible.
    final double farX = drawingContext.contentSize.width;

    return _fibRetracementLevels.map((_FibLevel level) {
      final double t = level.fraction;
      final Offset nearOffset = Offset(
        endOffset.dx + (startOffset.dx - endOffset.dx) * t,
        endOffset.dy + (startOffset.dy - endOffset.dy) * t,
      );
      return _RetracementLine(
        level: level,
        nearOffset: nearOffset,
        farOffset: Offset(farX, nearOffset.dy),
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

    for (final _RetracementLine line in _lines(epochToX, quoteToY)) {
      if (_isNearSegment(offset, line.nearOffset, line.farOffset)) {
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
    final List<_RetracementLine> lines = _lines(epochToX, quoteToY);

    canvas.drawLine(
      startOffset,
      endOffset,
      paintStyle.linePaintStyle(
        lineStyle.color.withValues(alpha: 0.25),
        lineStyle.thickness,
      ),
    );

    // Shade the band between each pair of adjacent levels, matching how a
    // Fibonacci retracement is conventionally drawn.
    for (int i = 0; i < lines.length - 1; i++) {
      final Path band = Path()
        ..moveTo(lines[i].nearOffset.dx, lines[i].nearOffset.dy)
        ..lineTo(lines[i].farOffset.dx, lines[i].farOffset.dy)
        ..lineTo(lines[i + 1].farOffset.dx, lines[i + 1].farOffset.dy)
        ..lineTo(lines[i + 1].nearOffset.dx, lines[i + 1].nearOffset.dy)
        ..close();
      canvas.drawPath(
        band,
        paintStyle.fillPaintStyle(config.fillStyle.color, lineStyle.thickness),
      );
    }

    for (final _RetracementLine line in lines) {
      canvas.drawLine(
        line.nearOffset,
        line.farOffset,
        paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness),
      );

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(text: line.level.label, style: config.labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(
          line.farOffset.dx - labelPainter.width - 4,
          line.farOffset.dy - labelPainter.height - 2,
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
  FibRetracementDrawingToolConfig getUpdatedConfig() =>
      config.copyWith(edgePoints: <EdgePoint>[?startPoint, ?endPoint]);

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) {
    if (startPoint == null || endPoint == null) {
      return true;
    }

    // Every level's line always extends out to the chart's right edge, so
    // the drawing stays at least partially visible as long as the anchors
    // haven't both scrolled off past the right side of the viewport.
    final bool startPastRight = startPoint!.epoch > epochRange.rightEpoch;
    final bool endPastRight = endPoint!.epoch > epochRange.rightEpoch;
    return !(startPastRight && endPastRight);
  }

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => FibRetracementAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => FibRetracementAddingPreviewMobile(
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
