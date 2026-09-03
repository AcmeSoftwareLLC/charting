import 'dart:ui' as ui;

import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
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
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'trend_line_adding_preview_desktop.dart';
import 'trend_line_adding_preview_mobile.dart';

/// Interactable drawing implementation for trend line drawing tool.
///
/// Handles rendering, hit testing, drag interactions, and state management for trend lines.
/// Supports dragging individual points or the entire line with visual feedback and alignment guides.
class TrendLineInteractableDrawing
    extends InteractableDrawing<TrendDrawingToolConfig> {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineInteractableDrawing({
    required TrendDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  // TODO(Ramin): make it non-nullable.
  /// Start point of the line.
  EdgePoint? startPoint;

  /// End point of the line.
  EdgePoint? endPoint;

  /// Tracks which point is being dragged, if any
  ///
  /// [null]: dragging the whole line.
  ///
  /// [true]: dragging the start point.
  ///
  /// [false]: dragging the end point.
  bool? isDraggingStartPoint;

  /// Tracks which point is being long-pressed, if any
  ///
  /// [null]: long pressing the whole line.
  ///
  /// [true]: long pressing the start point.
  ///
  /// [false]: long pressing the end point.
  bool? isLongPressingStartPoint;

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

    // Check if the drag is starting on the start point
    if ((details.localPosition - startOffset).distance <= hitTestMargin) {
      isDraggingStartPoint = true;
      return;
    }

    // Reset the dragging flag
    isDraggingStartPoint = null;

    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the drag is starting on one of the endpoints
    final double startDistance = (details.localPosition - startOffset).distance;
    final double endDistance = (details.localPosition - endOffset).distance;

    // If the drag is starting on the start point
    if (startDistance <= hitTestMargin) {
      isDraggingStartPoint = true;
      return;
    }

    // If the drag is starting on the end point
    if (endDistance <= hitTestMargin) {
      isDraggingStartPoint = false;
      return;
    }

    // If we reach here, the drag is on the line itself, not on a specific point
    // _isDraggingStartPoint remains null, indicating we're dragging the whole line
  }

  @override
  void onLongPressStart(
    Offset localPosition,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    _detectLongPressPoint(localPosition, epochToX, quoteToY);
  }

  @override
  void onLongPressEnd(
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    isLongPressingStartPoint = null;
  }

  /// Determines which point is being long-pressed based on the position
  void _detectLongPressPoint(
    Offset localPosition,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      isLongPressingStartPoint = null;
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

    // Check if the long press is on the start point
    final double startDistance = (localPosition - startOffset).distance;
    final double endDistance = (localPosition - endOffset).distance;

    if (startDistance <= hitTestMargin) {
      isLongPressingStartPoint = true;
    } else if (endDistance <= hitTestMargin) {
      isLongPressingStartPoint = false;
    } else {
      // Long press is on the line itself, not on a specific point
      isLongPressingStartPoint = null;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint != null) {
      final startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );

      if ((offset - startOffset).distance <= hitTestMargin) {
        return true;
      }
    }
    if (startPoint == null || endPoint == null) {
      return false;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the pointer is near either endpoint
    // Use a slightly larger margin for the endpoints to make them easier to hit
    final double startDistance = (offset - startOffset).distance;
    final double endDistance = (offset - endOffset).distance;

    if (startDistance <= hitTestMargin || endDistance <= hitTestMargin) {
      return true;
    }

    // Calculate line length
    final double lineLength = (endOffset - startOffset).distance;

    // If line length is too small, treat it as a point
    if (lineLength < 1) {
      return (offset - startOffset).distance <= hitTestMargin;
    }

    // Calculate perpendicular distance from point to line
    // Formula: |((y2-y1)x - (x2-x1)y + x2y1 - y2x1)| / sqrt((y2-y1)² + (x2-x1)²)
    final double distance =
        ((endOffset.dy - startOffset.dy) * offset.dx -
                (endOffset.dx - startOffset.dx) * offset.dy +
                endOffset.dx * startOffset.dy -
                endOffset.dy * startOffset.dx)
            .abs() /
        lineLength;

    // Check if point is within the line segment (not just the infinite line)
    final double dotProduct =
        (offset.dx - startOffset.dx) * (endOffset.dx - startOffset.dx) +
        (offset.dy - startOffset.dy) * (endOffset.dy - startOffset.dy);

    final bool isWithinRange =
        dotProduct >= 0 && dotProduct <= lineLength * lineLength;

    final result = isWithinRange && distance <= hitTestMargin;
    return result;
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
    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Draw neon glow effect first if selected but not dragging individual points or long pressing individual points
      if (drawingState.contains(DrawingToolState.selected) &&
          !(drawingState.contains(DrawingToolState.dragging) &&
              isDraggingStartPoint != null) &&
          !(drawingState.contains(DrawingToolState.longPressed) &&
              isLongPressingStartPoint != null)) {
        final neonPaint = Paint()
          ..color = config.lineStyle.color.withValues(alpha: 0.4)
          ..strokeWidth = 8 * animationInfo.stateChangePercent
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawLine(startOffset, endOffset, neonPaint);
      }

      // Draw the main line on top to keep it crisp
      final Paint paint = paintStyle.linePaintStyle(
        lineStyle.color,
        lineStyle.thickness,
      );
      canvas.drawLine(startOffset, endOffset, paint);

      // Only draw points when there's an active interaction (selected, hovered, or dragging)
      if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.hovered) ||
          drawingState.contains(DrawingToolState.dragging)) {
        // Draw both points as normal circles first
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

        // Then add glowy effect on top based on state
        if (drawingState.contains(DrawingToolState.dragging) &&
            isDraggingStartPoint != null) {
          // When dragging individual point, only show glow on the point being dragged
          final Offset draggedPointOffset = isDraggingStartPoint!
              ? startOffset
              : endOffset;
          drawFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            draggedPointOffset,
            10 * animationInfo.stateChangePercent,
            3 * animationInfo.stateChangePercent,
          );
        } else if (drawingState.contains(DrawingToolState.longPressed) &&
            isLongPressingStartPoint != null) {
          // When long pressing a specific point, show glow only on that point
          final Offset longPressedPointOffset = isLongPressingStartPoint!
              ? startOffset
              : endOffset;
          drawFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            longPressedPointOffset,
            10 *
                animationInfo
                    .stateChangePercent, // Same glow size as other states
            3 * animationInfo.stateChangePercent,
          );
        } else if ((drawingState.contains(DrawingToolState.selected) ||
                drawingState.contains(DrawingToolState.hovered)) &&
            !drawingState.contains(DrawingToolState.dragging) &&
            !drawingState.contains(DrawingToolState.longPressed)) {
          // When not dragging and not long pressing, show glow on both points
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
        // Note: When dragging the whole line (isDraggingStartPoint == null),
        // no glow effect is shown on endpoints as per requirements
      }

      if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.hovered)) {
        _paintLineInfoLabel(
          canvas,
          startOffset,
          endOffset,
          chartConfig,
          chartTheme,
          animationInfo,
        );
      }

      // Draw alignment guides when dragging or long pressing
      if (drawingState.contains(DrawingToolState.dragging) &&
          isDraggingStartPoint != null) {
        if (isDraggingStartPoint!) {
          drawPointAlignmentGuides(
            canvas,
            size,
            startOffset,
            lineColor: config.lineStyle.color,
          );
        } else {
          drawPointAlignmentGuides(
            canvas,
            size,
            endOffset,
            lineColor: config.lineStyle.color,
          );
        }
      } else if (drawingState.contains(DrawingToolState.longPressed) &&
          isLongPressingStartPoint != null) {
        // When long pressing a specific point, show alignment guides only for that point
        final Offset longPressedPointOffset = isLongPressingStartPoint!
            ? startOffset
            : endOffset;
        drawPointAlignmentGuides(
          canvas,
          size,
          longPressedPointOffset,
          lineColor: config.lineStyle.color,
        );
      } else if ((drawingState.contains(DrawingToolState.dragging) &&
              isDraggingStartPoint == null) ||
          (drawingState.contains(DrawingToolState.longPressed) &&
              isLongPressingStartPoint == null)) {
        // When dragging whole line or long pressing whole line, show alignment guides for both points
        drawPointAlignmentGuides(
          canvas,
          size,
          startOffset,
          lineColor: config.lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          endOffset,
          lineColor: config.lineStyle.color,
        );
      }
    }
  }

  @override
  void paintOverYAxis(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    epochFromX,
    quoteFromY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    if (getDrawingState(this).contains(DrawingToolState.selected)) {
      // Draw value label for start point
      if (startPoint != null) {
        drawValueLabel(
          canvas: canvas,
          quoteToY: quoteToY,
          value: startPoint!.quote,
          pipSize: chartConfig.pipSize,
          animationProgress: animationInfo.stateChangePercent,
          size: size,
          textStyle: config.labelStyle,
          color: config.lineStyle.color,
          backgroundColor: chartTheme.backgroundColor,
        );
      }

      // Draw value label for end point (offset slightly to avoid overlap)
      if (endPoint != null &&
          startPoint != null &&
          endPoint!.quote != startPoint!.quote) {
        drawValueLabel(
          canvas: canvas,
          quoteToY: quoteToY,
          value: endPoint!.quote,
          pipSize: chartConfig.pipSize,
          animationProgress: animationInfo.stateChangePercent,
          size: size,
          textStyle: config.labelStyle,
          color: config.lineStyle.color,
          backgroundColor: chartTheme.backgroundColor,
        );
      }
    }
  }

  String _buildLineInfoText(
    EdgePoint start,
    EdgePoint end,
    int granularity,
    int pipSize,
  ) {
    final double priceDiff = end.quote - start.quote;
    final double percent = start.quote == 0 ? 0 : priceDiff / start.quote * 100;
    final int barCount = granularity <= 0
        ? 0
        : (end.epoch - start.epoch).abs() ~/ granularity;

    return '${priceDiff.toStringAsFixed(pipSize)} '
        '(${percent.toStringAsFixed(2)}%) $barCount Bars';
  }

  /// Paints the price/percent/bar-count readout as a small pill centered on
  /// the line's midpoint, styled to match the existing axis value/epoch
  /// labels (rounded background + border, same [LineStyle]/[ChartTheme]
  /// colors).
  void _paintLineInfoLabel(
    Canvas canvas,
    Offset startOffset,
    Offset endOffset,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    AnimationInfo animationInfo,
  ) {
    final String text = _buildLineInfoText(
      startPoint!,
      endPoint!,
      chartConfig.granularity,
      chartConfig.pipSize,
    );
    final Color color = config.lineStyle.color;
    final double animationProgress = animationInfo.stateChangePercent;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: config.labelStyle.copyWith(
          color: config.labelStyle.color?.withValues(alpha: animationProgress),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset midpoint = Offset(
      (startOffset.dx + endOffset.dx) / 2,
      (startOffset.dy + endOffset.dy) / 2,
    );

    final Offset lineVector = endOffset - startOffset;
    final double lineLength = lineVector.distance;
    Offset perpendicularUnit = lineLength > 0
        ? Offset(-lineVector.dy, lineVector.dx) / lineLength
        : const Offset(0, -1);
    if (perpendicularUnit.dy > 0) {
      // Keep the label consistently above the line rather than flipping
      // sides depending on which way the line happens to slope.
      perpendicularUnit = -perpendicularUnit;
    }

    final double rectWidth = textPainter.width + 16;
    const double rectHeight = 24;
    const double gapFromLine = 14;
    final Offset labelCenter =
        midpoint + perpendicularUnit * (rectHeight / 2 + gapFromLine);
    final Rect rect = Rect.fromCenter(
      center: labelCenter,
      width: rectWidth,
      height: rectHeight,
    );
    final RRect roundedRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(4),
    );

    canvas
      ..drawRRect(
        roundedRect,
        Paint()
          ..color = chartTheme.backgroundColor.withValues(
            alpha: animationProgress,
          )
          ..style = PaintingStyle.fill,
      )
      ..drawRRect(
        roundedRect,
        Paint()
          ..color = color.withValues(alpha: animationProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rectWidth - textPainter.width) / 2,
        rect.top + (rectHeight - textPainter.height) / 2,
      ),
    );
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

    // Get the drag delta in screen coordinates
    final Offset delta = details.delta;

    // If we're dragging a specific point (start or end point)
    if (isDraggingStartPoint != null) {
      // Get the current point being dragged
      final EdgePoint pointBeingDragged = isDraggingStartPoint!
          ? startPoint!
          : endPoint!;

      // Get the current screen position of the point
      final Offset currentOffset = Offset(
        epochToX(pointBeingDragged.epoch),
        quoteToY(pointBeingDragged.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = currentOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Create updated point
      final EdgePoint updatedPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );

      // Update the appropriate point
      if (isDraggingStartPoint!) {
        startPoint = updatedPoint;
      } else {
        endPoint = updatedPoint;
      }
    } else {
      // We're dragging the whole line
      // Convert start and end points to screen coordinates
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Apply the delta to get new screen coordinates
      final Offset newStartOffset = startOffset + delta;
      final Offset newEndOffset = endOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newStartEpoch = epochFromX(newStartOffset.dx);
      final double newStartQuote = quoteFromY(newStartOffset.dy);
      final int newEndEpoch = epochFromX(newEndOffset.dx);
      final double newEndQuote = quoteFromY(newEndOffset.dy);

      // Update the start and end points
      startPoint = EdgePoint(epoch: newStartEpoch, quote: newStartQuote);
      endPoint = EdgePoint(epoch: newEndEpoch, quote: newEndQuote);
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
    // Reset the dragging flag when drag is complete
    isDraggingStartPoint = null;
  }

  @override
  TrendDrawingToolConfig getUpdatedConfig() =>
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
  DrawingAddingPreview getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => TrendLineAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => TrendLineAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
    children: <Widget>[
      _buildLineThicknessIcon(onUpdate),
      const SizedBox(width: 4),
      _buildColorPickerIcon(onUpdate),
    ],
  );

  Widget _buildColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
    width: 32,
    height: 32,
    child: ColorPickerDropdownButton(
      currentColor: config.lineStyle.color,
      onColorChanged: (newColor) => onUpdate(
        config.copyWith(
          lineStyle: config.lineStyle.copyWith(color: newColor),
          labelStyle: config.labelStyle.copyWith(color: newColor),
        ),
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
