import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import 'measure_adding_preview.dart';

/// The text style used for the live measurement label. It's not
/// user-configurable — it's a fixed, transient overlay rather than a
/// styleable part of the drawing.
const TextStyle _measurementLabelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: 'Inter',
);

/// Adding preview for [MeasureInteractableDrawing] on
/// [InteractiveLayerDesktopBehaviour].
///
/// While hovering after the first point is placed, shows a live measurement
/// label (price difference, percentage change, bar count) for the segment
/// that would be created on click. Shown only during placement; the
/// finished drawing (a plain segment) never carries it.
class MeasureAddingPreviewDesktop extends MeasureAddingPreview {
  /// Initializes [MeasureAddingPreviewDesktop].
  MeasureAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 2));
  }

  Offset? _hoverPosition;
  EdgePoint? _hoverPoint;

  @override
  String get id => 'measure-adding-preview-desktop';

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

    drawFocusedCircle(paintStyle, lineStyle, canvas, startOffset, 10, 3);

    if (_hoverPosition != null && _hoverPoint != null) {
      drawPreviewLine(canvas, startOffset, _hoverPosition!, lineStyle);
      drawPointAlignmentGuides(
        canvas,
        size,
        _hoverPosition!,
        lineColor: lineStyle.color,
      );

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: _buildLiveMeasurementText(
            startPoint,
            _hoverPoint!,
            chartConfig.granularity,
          ),
          style: _measurementLabelStyle.copyWith(color: lineStyle.color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(
          _hoverPosition!.dx - labelPainter.width / 2,
          _hoverPosition!.dy - labelPainter.height - 12,
        ),
      );
    }
  }

  /// Builds the "`Measure: <price diff> (<percent>%) <bar count>`" text.
  ///
  /// [granularity] is the chart's bar duration in milliseconds (same units
  /// as [EdgePoint.epoch]); the bar count is estimated as the elapsed time
  /// between the two points divided by it.
  String _buildLiveMeasurementText(
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
