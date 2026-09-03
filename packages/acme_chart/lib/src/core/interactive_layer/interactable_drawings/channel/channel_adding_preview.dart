import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/interactive_layer/interactive_layer_states/interactive_adding_tool_state.dart';
import '../../../../theme/painting_styles/line_style.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../drawing_adding_preview.dart';
import 'channel_interactable_drawing.dart';

/// Base class for channel adding preview implementations.
///
/// Provides shared functionality for desktop and mobile implementations,
/// including coordinate transformations, styling, and common drawing logic.
abstract class ChannelAddingPreview
    extends DrawingAddingPreview<ChannelInteractableDrawing> {
  /// Initializes the base channel adding preview.
  ChannelAddingPreview({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  });

  /// Retrieves the line style configured for the channel being created.
  LineStyle getLineStyle() => interactableDrawing.config.lineStyle;

  /// Converts a chart coordinate point to screen coordinates.
  Offset edgePointToOffset(
    EdgePoint point,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) => Offset(epochToX(point.epoch), quoteToY(point.quote));

  /// Draws a dashed line between [startPosition] and [endPosition].
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

  /// Draws a dashed parallelogram outline through [corners], in order.
  void drawPreviewParallelogram(
    Canvas canvas,
    List<Offset> corners,
    LineStyle lineStyle,
  ) {
    final Path path = Path()
      ..moveTo(corners[0].dx, corners[0].dy)
      ..lineTo(corners[1].dx, corners[1].dy)
      ..lineTo(corners[2].dx, corners[2].dy)
      ..lineTo(corners[3].dx, corners[3].dy)
      ..close();

    canvas.drawPath(
      dashPath(path, dashArray: CircularIntervalList<double>(<double>[2, 2])),
      Paint()
        ..color = lineStyle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineStyle.thickness,
    );
  }

  /// Handles the creation of channel points during the drawing process.
  ///
  /// The first tap sets [ChannelInteractableDrawing.startPoint], the second
  /// sets [ChannelInteractableDrawing.middlePoint], and the third sets
  /// [ChannelInteractableDrawing.endPoint] (its epoch is locked to
  /// [ChannelInteractableDrawing.middlePoint]'s epoch, only its quote is
  /// used).
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
      onAddingStateChange(AddingStateInfo(1, 3));
    } else if (interactableDrawing.middlePoint == null) {
      interactableDrawing.middlePoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onAddingStateChange(AddingStateInfo(2, 3));
    } else {
      interactableDrawing.endPoint ??= EdgePoint(
        epoch: interactableDrawing.middlePoint!.epoch,
        quote: quoteFromY(details.localPosition.dy),
      );
      onAddingStateChange(AddingStateInfo(3, 3));
    }
  }
}
