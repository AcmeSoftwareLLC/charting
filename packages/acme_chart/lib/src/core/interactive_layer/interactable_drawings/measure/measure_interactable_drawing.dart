import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/enums/drawing_tool_state.dart';
import '../../../../core/interactive_layer/interactive_layer_states/interactive_adding_tool_state.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import '../drawing_adding_preview.dart';
import '../interactable_drawing.dart';
import '../segment/segment_adding_preview_mobile.dart';
import '../segment/segment_interactable_drawing.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'measure_adding_preview_desktop.dart';

/// The text style used for the measurement label — matches
/// [MeasureAddingPreviewDesktop]'s live placement-time label, since this is
/// the same readout shown again post-placement, just on hover/selection
/// instead of during drawing.
const TextStyle _measurementLabelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: 'Inter',
);

/// Interactable drawing implementation for the measure drawing tool.
///
/// It's a [SegmentInteractableDrawing] through and through — same geometry,
/// hit-test, drag, toolbar — so it's rendered and edited exactly like a
/// Segment. Unlike an earlier version of this tool, it does *not* become a
/// plain segment once placed: [MeasureDrawingToolConfig] extends
/// [SegmentDrawingToolConfig] rather than discarding its identity, so
/// [getUpdatedConfig] (inherited from [SegmentInteractableDrawing]
/// unmodified) still persists a genuine [MeasureDrawingToolConfig] across
/// reloads.
///
/// "measure" changes two things, both specific to this tool (not shared
/// with Segment/Line/Trend, by design — only "Measure" shows a measure
/// readout): what's shown *while it's being placed*
/// ([getAddingPreviewForDesktopBehaviour] swaps in
/// [MeasureAddingPreviewDesktop], which overlays a live price
/// difference / percentage change / bar count label next to the preview
/// line; [getAddingPreviewForMobileBehaviour] reuses
/// [SegmentAddingPreviewMobile] unchanged, since mobile completes placement
/// immediately with no equivalent "measuring" window), and what's shown
/// *on hover or selection* once placed — [paint] overlays that same label
/// again, matching ChartIQ's own `BaseTwoPoint.prototype.measure()`, which
/// re-triggers the measurement HUD on hover/reposition, not just during
/// initial placement. Selection is included alongside hover because mouse
/// hover (`PointerHoverEvent`) never fires from touch input, so it's the
/// one trigger guaranteed to work identically on every platform.
class MeasureInteractableDrawing extends SegmentInteractableDrawing {
  /// Initializes [MeasureInteractableDrawing].
  MeasureInteractableDrawing({
    required super.config,
    required super.startPoint,
    required super.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  });

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => MeasureAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => SegmentAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

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

    final Set<DrawingToolState> drawingState = getDrawingState(this);
    if (!drawingState.contains(DrawingToolState.hovered) &&
        !drawingState.contains(DrawingToolState.selected)) {
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

    _paintMeasurementLabel(
      canvas,
      startOffset,
      endOffset,
      chartConfig.granularity,
      chartTheme,
    );
  }

  /// Builds the "`Measure: <price diff> (<percent>%) <bar count>`" text,
  /// matching ChartIQ's `setMeasure` HUD exactly (including its
  /// "Measure: " label prefix) — the same formula
  /// [MeasureAddingPreviewDesktop] uses for its placement-time label.
  String _buildMeasurementText(
    EdgePoint start,
    EdgePoint end,
    int granularity,
  ) {
    final double priceDiff = end.quote - start.quote;
    final double percent = start.quote == 0 ? 0 : priceDiff / start.quote * 100;
    final int barCount = granularity <= 0
        ? 0
        : (end.epoch - start.epoch).abs() ~/ granularity;

    return 'Measure: ${priceDiff.toStringAsFixed(5)} (${percent.toStringAsFixed(2)}%) $barCount';
  }

  /// Paints the measurement label as a small pill offset perpendicular to
  /// the line's own direction, so it clears the line regardless of slope
  /// (a fixed vertical offset only clears a near-horizontal line).
  void _paintMeasurementLabel(
    Canvas canvas,
    Offset startOffset,
    Offset endOffset,
    int granularity,
    ChartTheme chartTheme,
  ) {
    final Color color = config.lineStyle.color;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _buildMeasurementText(startPoint!, endPoint!, granularity),
        style: _measurementLabelStyle.copyWith(color: color),
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
          ..color = chartTheme.backgroundColor
          ..style = PaintingStyle.fill,
      )
      ..drawRRect(
        roundedRect,
        Paint()
          ..color = color
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
}
