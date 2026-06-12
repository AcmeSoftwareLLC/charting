import '../../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/drawing_creator.dart';
import '../../../../../models/chart_config.dart';
import 'package:flutter/material.dart';
import 'horizontal_drawing.dart';

/// Creates a Horizontal line drawing
class HorizontalDrawingCreator extends DrawingCreator<HorizontalDrawing> {
  /// Initializes the horizontal drawing creator.
  const HorizontalDrawingCreator({
    required super.onAddDrawing,
    required super.quoteFromCanvasY,
    required ChartConfig super.chartConfig,
    super.key,
  });

  @override
  DrawingCreatorState<HorizontalDrawing, HorizontalDrawingCreator>
  createState() => _HorizontalDrawingCreatorState();
}

class _HorizontalDrawingCreatorState
    extends DrawingCreatorState<HorizontalDrawing, HorizontalDrawingCreator> {
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
        HorizontalDrawing(
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
