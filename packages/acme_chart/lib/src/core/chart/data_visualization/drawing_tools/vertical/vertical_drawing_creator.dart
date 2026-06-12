import '../../../../../core/chart/data_visualization/drawing_tools/drawing_creator.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../../models/chart_config.dart';
import 'package:flutter/material.dart';
import 'vertical_drawing.dart';

/// Creates a Vertical line drawing
class VerticalDrawingCreator extends DrawingCreator<VerticalDrawing> {
  /// Initializes the vertical drawing creator.
  const VerticalDrawingCreator({
    required super.onAddDrawing,
    required super.quoteFromCanvasY,
    required ChartConfig super.chartConfig,
    super.key,
  });

  @override
  DrawingCreatorState<VerticalDrawing, VerticalDrawingCreator> createState() =>
      _VerticalDrawingCreatorState();
}

class _VerticalDrawingCreatorState
    extends DrawingCreatorState<VerticalDrawing, VerticalDrawingCreator> {
  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;

      edgePoints.add(
        EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ),
      );

      isDrawingFinished = true;

      drawingParts.add(
        VerticalDrawing(
          drawingPart: DrawingParts.line,
          edgePoint: edgePoints.first,
          chartConfig: widget.chartConfig,
        ),
      );

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        edgePoints: <EdgePoint>[...edgePoints],
      );
    });
  }
}
