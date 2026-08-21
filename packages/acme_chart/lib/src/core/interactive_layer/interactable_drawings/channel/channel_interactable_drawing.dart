import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/channel/channel_drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
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
import 'channel_adding_preview_desktop.dart';
import 'channel_adding_preview_mobile.dart';

/// A resolved screen-space geometry for a channel: two parallel lines (start
/// -> middle, and end -> secondLineStart) forming a parallelogram.
typedef _ChannelGeometry = ({
  Offset start,
  Offset middle,
  Offset end,
  Offset secondLineStart,
});

/// Interactable drawing implementation for channel drawing tool.
///
/// A channel is two parallel lines defined by 3 points: [startPoint] and
/// [middlePoint] define the base line, and [endPoint] (only its quote is
/// used) defines the vertical screen-space offset of the parallel line.
class ChannelInteractableDrawing
    extends InteractableDrawing<ChannelDrawingToolConfig> {
  /// Initializes [ChannelInteractableDrawing].
  ChannelInteractableDrawing({
    required ChannelDrawingToolConfig config,
    required this.startPoint,
    required this.middlePoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// Start point of the base line.
  EdgePoint? startPoint;

  /// End point of the base line.
  EdgePoint? middlePoint;

  /// Defines the vertical (screen-space) offset of the parallel line.
  ///
  /// Only its `quote` is meaningful; its `epoch` is always kept in sync with
  /// [middlePoint]'s epoch.
  EdgePoint? endPoint;

  /// Tracks which point is being dragged, if any.
  ///
  /// [null]: dragging the whole channel.
  ///
  /// `0`: dragging [startPoint]. `1`: dragging [middlePoint]. `2`: dragging
  /// [endPoint].
  int? draggedPointIndex;

  /// Computes the screen-space geometry of the channel.
  ///
  /// Must only be called when [startPoint], [middlePoint] and [endPoint] are
  /// all non-null.
  _ChannelGeometry _computeGeometry(EpochToX epochToX, QuoteToY quoteToY) {
    final Offset start = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset middle = Offset(
      epochToX(middlePoint!.epoch),
      quoteToY(middlePoint!.quote),
    );
    final Offset end = Offset(middle.dx, quoteToY(endPoint!.quote));
    final double height = middle.dy - end.dy;
    final Offset secondLineStart = Offset(start.dx, start.dy - height);

    return (
      start: start,
      middle: middle,
      end: end,
      secondLineStart: secondLineStart,
    );
  }

  /// Builds the parallelogram path from the resolved [geometry].
  ///
  /// Walks the perimeter as bottom-left -> bottom-right -> top-right ->
  /// top-left so the shape stays a proper (non-self-intersecting)
  /// parallelogram regardless of whether [_ChannelGeometry.start] or
  /// [_ChannelGeometry.middle] is further to the left on screen.
  Path _parallelogramPath(_ChannelGeometry geometry) {
    final bool startIsLeft = geometry.start.dx <= geometry.middle.dx;
    final Offset bottomLeft = startIsLeft ? geometry.start : geometry.middle;
    final Offset bottomRight = startIsLeft ? geometry.middle : geometry.start;
    final Offset topLeft = startIsLeft
        ? geometry.secondLineStart
        : geometry.end;
    final Offset topRight = startIsLeft
        ? geometry.end
        : geometry.secondLineStart;

    return Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..close();
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || middlePoint == null || endPoint == null) {
      return;
    }

    final _ChannelGeometry geometry = _computeGeometry(epochToX, quoteToY);

    if ((details.localPosition - geometry.start).distance <= hitTestMargin) {
      draggedPointIndex = 0;
    } else if ((details.localPosition - geometry.middle).distance <=
        hitTestMargin) {
      draggedPointIndex = 1;
    } else if ((details.localPosition - geometry.end).distance <=
        hitTestMargin) {
      draggedPointIndex = 2;
    } else {
      // The drag is on the channel body, not on a specific marker.
      draggedPointIndex = null;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || middlePoint == null || endPoint == null) {
      return false;
    }

    final _ChannelGeometry geometry = _computeGeometry(epochToX, quoteToY);

    if ((offset - geometry.start).distance <= hitTestMargin ||
        (offset - geometry.middle).distance <= hitTestMargin ||
        (offset - geometry.end).distance <= hitTestMargin) {
      return true;
    }

    return _parallelogramPath(geometry).contains(offset);
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
    if (startPoint == null || middlePoint == null || endPoint == null) {
      return;
    }

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);
    final _ChannelGeometry geometry = _computeGeometry(epochToX, quoteToY);

    if (config.pattern == DrawingPatterns.solid) {
      canvas
        ..drawPath(
          _parallelogramPath(geometry),
          paintStyle.fillPaintStyle(fillStyle.color, lineStyle.thickness),
        )
        ..drawLine(
          geometry.start,
          geometry.middle,
          paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness),
        )
        ..drawLine(
          geometry.end,
          geometry.secondLineStart,
          paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness),
        );

      if (drawingState.contains(DrawingToolState.selected)) {
        final Paint neonPaint = Paint()
          ..color = lineStyle.color.withValues(alpha: 0.4)
          ..strokeWidth = 8 * animationInfo.stateChangePercent
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas
          ..drawLine(geometry.start, geometry.middle, neonPaint)
          ..drawLine(geometry.end, geometry.secondLineStart, neonPaint);
      }
    }

    // Only draw corner markers when there's an active interaction.
    if (drawingState.contains(DrawingToolState.selected) ||
        drawingState.contains(DrawingToolState.hovered) ||
        drawingState.contains(DrawingToolState.dragging)) {
      drawPointOffset(
        geometry.start,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      drawPointOffset(
        geometry.middle,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      drawPointOffset(
        geometry.end,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );

      if (drawingState.contains(DrawingToolState.dragging) &&
          draggedPointIndex != null) {
        final Offset draggedOffset = switch (draggedPointIndex) {
          0 => geometry.start,
          1 => geometry.middle,
          _ => geometry.end,
        };
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
        final double outerRadius =
            drawingState.contains(DrawingToolState.selected)
            ? 10 * animationInfo.stateChangePercent
            : 10;
        final double innerRadius =
            drawingState.contains(DrawingToolState.selected)
            ? 3 * animationInfo.stateChangePercent
            : 3;

        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          geometry.start,
          outerRadius,
          innerRadius,
        );
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          geometry.middle,
          outerRadius,
          innerRadius,
        );
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          geometry.end,
          outerRadius,
          innerRadius,
        );
      }
    }

    // Draw alignment guides while dragging.
    if (drawingState.contains(DrawingToolState.dragging)) {
      final Offset? guideOffset = switch (draggedPointIndex) {
        0 => geometry.start,
        1 => geometry.middle,
        2 => geometry.end,
        _ => null,
      };

      if (guideOffset != null) {
        drawPointAlignmentGuides(
          canvas,
          size,
          guideOffset,
          lineColor: lineStyle.color,
        );
      } else {
        drawPointAlignmentGuides(
          canvas,
          size,
          geometry.start,
          lineColor: lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          geometry.middle,
          lineColor: lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          geometry.end,
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
    if (startPoint == null || middlePoint == null || endPoint == null) {
      return;
    }

    final Offset delta = details.delta;

    switch (draggedPointIndex) {
      case 0:
        final Offset newOffset =
            Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote)) +
            delta;
        startPoint = EdgePoint(
          epoch: epochFromX(newOffset.dx),
          quote: quoteFromY(newOffset.dy),
        );
      case 1:
        final Offset newOffset =
            Offset(epochToX(middlePoint!.epoch), quoteToY(middlePoint!.quote)) +
            delta;
        middlePoint = EdgePoint(
          epoch: epochFromX(newOffset.dx),
          quote: quoteFromY(newOffset.dy),
        );
        // Keep endPoint's epoch in sync with middlePoint's, per the
        // invariant documented on [endPoint].
        endPoint = EdgePoint(epoch: middlePoint!.epoch, quote: endPoint!.quote);
      case 2:
        final double newY = quoteToY(endPoint!.quote) + delta.dy;
        endPoint = EdgePoint(
          epoch: middlePoint!.epoch,
          quote: quoteFromY(newY),
        );
      default:
        // Translate the whole channel.
        final Offset newStartOffset =
            Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote)) +
            delta;
        final Offset newMiddleOffset =
            Offset(epochToX(middlePoint!.epoch), quoteToY(middlePoint!.quote)) +
            delta;
        final double newEndY = quoteToY(endPoint!.quote) + delta.dy;

        final EdgePoint newStart = EdgePoint(
          epoch: epochFromX(newStartOffset.dx),
          quote: quoteFromY(newStartOffset.dy),
        );
        final EdgePoint newMiddle = EdgePoint(
          epoch: epochFromX(newMiddleOffset.dx),
          quote: quoteFromY(newMiddleOffset.dy),
        );

        startPoint = newStart;
        middlePoint = newMiddle;
        endPoint = EdgePoint(
          epoch: newMiddle.epoch,
          quote: quoteFromY(newEndY),
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
    draggedPointIndex = null;

    // Fold the dragged points into `config` immediately. Nothing else ever
    // refreshes this instance's `config` from what gets persisted, so
    // without this, the next toolbar color/thickness change would build its
    // `config.copyWith(...)` off the pre-drag `config` (whose `edgePoints`
    // are stale) and silently revert this move/resize on next reload.
    config = getUpdatedConfig();
  }

  @override
  ChannelDrawingToolConfig getUpdatedConfig() => config.copyWith(
    edgePoints: <EdgePoint>[?startPoint, ?middlePoint, ?endPoint],
  );

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      (startPoint?.isInEpochRange(
            epochRange.leftEpoch,
            epochRange.rightEpoch,
          ) ??
          true) ||
      (middlePoint?.isInEpochRange(
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
  ) => ChannelAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => ChannelAddingPreviewMobile(
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
