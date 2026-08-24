import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/doodle/doodle_drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
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
import 'doodle_adding_preview_desktop.dart';
import 'doodle_adding_preview_mobile.dart';

/// Interactable drawing implementation for the doodle (freehand) drawing
/// tool.
///
/// Unlike the other tools, a doodle isn't defined by a small, fixed number of
/// points — [points] holds every point sampled while the user dragged across
/// the chart. It only supports moving the whole stroke; individual points
/// aren't draggable.
class DoodleInteractableDrawing
    extends InteractableDrawing<DoodleDrawingToolConfig> {
  /// Initializes [DoodleInteractableDrawing].
  DoodleInteractableDrawing({
    required DoodleDrawingToolConfig config,
    required this.points,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// The points sampled along the freehand stroke, in drawing order.
  List<EdgePoint> points;

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {}

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (points.length < 2) {
      return points.isNotEmpty &&
          (offset -
                  Offset(epochToX(points.first.epoch), quoteToY(points.first.quote)))
              .distance <=
              hitTestMargin;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final Offset start = Offset(
        epochToX(points[i].epoch),
        quoteToY(points[i].quote),
      );
      final Offset end = Offset(
        epochToX(points[i + 1].epoch),
        quoteToY(points[i + 1].quote),
      );

      if (_isNearSegment(offset, start, end)) {
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
    if (points.isEmpty) {
      return;
    }

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    final Path path = _buildPath(epochToX, quoteToY);

    if (drawingState.contains(DrawingToolState.selected)) {
      final Paint neonPaint = Paint()
        ..color = lineStyle.color.withValues(alpha: 0.4)
        ..strokeWidth = 8 * animationInfo.stateChangePercent
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, neonPaint);
    }

    canvas.drawPath(
      path,
      paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final Offset firstOffset = Offset(
      epochToX(points.first.epoch),
      quoteToY(points.first.quote),
    );
    final Offset lastOffset = Offset(
      epochToX(points.last.epoch),
      quoteToY(points.last.quote),
    );

    // Only draw bookend markers when there's an active interaction. There's
    // no per-point dragging for a freehand stroke, so unlike the other
    // tools these are visual bookends only, not draggable handles.
    if (drawingState.contains(DrawingToolState.selected) ||
        drawingState.contains(DrawingToolState.hovered) ||
        drawingState.contains(DrawingToolState.dragging)) {
      drawPointOffset(
        firstOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      drawPointOffset(
        lastOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
    }

    // Draw alignment guides for the whole stroke while dragging.
    if (drawingState.contains(DrawingToolState.dragging)) {
      drawPointAlignmentGuides(
        canvas,
        size,
        firstOffset,
        lineColor: lineStyle.color,
      );
      drawPointAlignmentGuides(
        canvas,
        size,
        lastOffset,
        lineColor: lineStyle.color,
      );
    }
  }

  Path _buildPath(EpochToX epochToX, QuoteToY quoteToY) {
    final Path path = Path()
      ..moveTo(epochToX(points.first.epoch), quoteToY(points.first.quote));

    for (final EdgePoint point in points.skip(1)) {
      path.lineTo(epochToX(point.epoch), quoteToY(point.quote));
    }

    return path;
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (points.isEmpty) {
      return;
    }

    final Offset delta = details.delta;

    points = points.map((EdgePoint point) {
      final Offset newOffset =
          Offset(epochToX(point.epoch), quoteToY(point.quote)) + delta;
      return EdgePoint(
        epoch: epochFromX(newOffset.dx),
        quote: quoteFromY(newOffset.dy),
      );
    }).toList();
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    config = getUpdatedConfig();
  }

  @override
  DoodleDrawingToolConfig getUpdatedConfig() =>
      config.copyWith(edgePoints: List<EdgePoint>.of(points));

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) => points
      .any(
        (EdgePoint point) =>
            point.isInEpochRange(epochRange.leftEpoch, epochRange.rightEpoch),
      );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => DoodleAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => DoodleAddingPreviewMobile(
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
        config.copyWith(lineStyle: config.lineStyle.copyWith(color: newColor)),
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
