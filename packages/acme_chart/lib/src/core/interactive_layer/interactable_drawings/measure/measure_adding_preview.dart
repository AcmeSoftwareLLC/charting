import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/interactive_layer/interactive_layer_states/interactive_adding_tool_state.dart';
import '../../../../theme/painting_styles/line_style.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../drawing_adding_preview.dart';
import 'measure_interactable_drawing.dart';

/// Base class for measure adding preview implementations.
///
/// Provides shared functionality for desktop and mobile implementations,
/// including coordinate transformations, styling, and common drawing logic.
abstract class MeasureAddingPreview
    extends DrawingAddingPreview<MeasureInteractableDrawing> {
  /// Initializes the base measure adding preview.
  MeasureAddingPreview({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  });

  /// Retrieves the line style configured for the measurement being created.
  LineStyle getLineStyle() => interactableDrawing.config.lineStyle;

  /// Converts a chart coordinate point to screen coordinates.
  Offset edgePointToOffset(
    EdgePoint point,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) => Offset(epochToX(point.epoch), quoteToY(point.quote));

  /// Draws a dashed preview line between [startPosition] and [endPosition].
  void drawPreviewLine(
    Canvas canvas,
    Offset startPosition,
    Offset endPosition,
    LineStyle lineStyle,
  ) {
    final Path linePath = Path()
      ..moveTo(startPosition.dx, startPosition.dy)
      ..lineTo(endPosition.dx, endPosition.dy);

    canvas.drawPath(
      dashPath(
        linePath,
        dashArray: CircularIntervalList<double>(<double>[2, 2]),
      ),
      Paint()
        ..color = lineStyle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineStyle.thickness,
    );
  }

  /// Handles the creation of measurement points during the drawing process.
  ///
  /// The first tap sets the start point, the second tap sets the end point
  /// and completes the measurement.
  void createPoint(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
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
