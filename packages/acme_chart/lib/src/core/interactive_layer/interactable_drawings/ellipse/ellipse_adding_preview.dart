import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/interactive_layer/interactive_layer_states/interactive_adding_tool_state.dart';
import '../../../../theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../drawing_adding_preview.dart';
import 'ellipse_interactable_drawing.dart';

/// Base class for ellipse adding preview implementations.
///
/// Provides shared functionality for desktop and mobile implementations,
/// including coordinate transformations, styling, and common drawing logic.
abstract class EllipseAddingPreview
    extends DrawingAddingPreview<EllipseInteractableDrawing> {
  /// Initializes the base ellipse adding preview.
  EllipseAddingPreview({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  });

  /// Retrieves the line style configured for the ellipse being created.
  LineStyle getLineStyle() => interactableDrawing.config.lineStyle;

  /// Converts a chart coordinate point to screen coordinates.
  Offset edgePointToOffset(
    EdgePoint point,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) => Offset(epochToX(point.epoch), quoteToY(point.quote));

  /// Draws a dashed ellipse outline inscribed in the box between
  /// [startPosition] and [endPosition].
  void drawPreviewOval(
    Canvas canvas,
    Offset startPosition,
    Offset endPosition,
    LineStyle lineStyle,
  ) {
    final Path ovalPath = Path()
      ..addOval(Rect.fromPoints(startPosition, endPosition));

    canvas.drawPath(
      dashPath(
        ovalPath,
        dashArray: CircularIntervalList<double>(<double>[2, 2]),
      ),
      Paint()
        ..color = lineStyle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineStyle.thickness,
    );
  }

  /// Handles the creation of the ellipse's bounding-box corner points during
  /// the drawing process.
  ///
  /// The first tap sets the start corner, the second tap sets the opposite
  /// corner and completes the ellipse.
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
