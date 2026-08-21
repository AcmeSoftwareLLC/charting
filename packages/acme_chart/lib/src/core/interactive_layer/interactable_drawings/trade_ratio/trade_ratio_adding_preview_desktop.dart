import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'trade_ratio_interactable_drawing.dart';

/// A class to show a preview and handle adding a
/// [TradeRatioInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour].
class TradeRatioAddingPreviewDesktop
    extends DrawingAddingPreview<TradeRatioInteractableDrawing> {
  /// Initializes [TradeRatioAddingPreviewDesktop].
  TradeRatioAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 2));
  }

  Offset? _hoverPosition;

  @override
  String get id => 'trade-ratio-adding-preview-desktop';

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
    final lineStyle = interactableDrawing.config.lineStyle;
    final Offset startOffset = Offset(
      epochToX(startPoint.epoch),
      quoteToY(startPoint.quote),
    );

    drawPointOffset(
      startOffset,
      epochToX,
      quoteToY,
      canvas,
      paintStyle,
      lineStyle,
    );

    if (_hoverPosition != null) {
      canvas.drawPath(
        dashPath(
          Path()
            ..moveTo(startOffset.dx, startOffset.dy)
            ..lineTo(_hoverPosition!.dx, _hoverPosition!.dy),
          dashArray: CircularIntervalList<double>(<double>[2, 2]),
        ),
        Paint()
          ..color = lineStyle.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineStyle.thickness,
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
    if (interactableDrawing.startPoint == null) {
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onAddingStateChange(AddingStateInfo(1, 2));
    } else {
      interactableDrawing.endPoint ??= EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onAddingStateChange(AddingStateInfo(2, 2));
    }
  }
}
