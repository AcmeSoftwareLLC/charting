import '../../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/drawing_creator.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/rectangle/rectangle_drawing.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Rectangle drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a rectangle drawing tool and
/// until drawing is finished
class RectangleDrawingCreator extends DrawingCreator<RectangleDrawing> {
  /// Initializes the rectangle drawing creator.
  const RectangleDrawingCreator({
    required super.onAddDrawing,
    required super.quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeUnfinishedDrawing,
    super.key,
  });

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final VoidCallback removeUnfinishedDrawing;

  @override
  DrawingCreatorState<RectangleDrawing, RectangleDrawingCreator>
  createState() => _RectangleDrawingCreatorState();
}

class _RectangleDrawingCreatorState
    extends DrawingCreatorState<RectangleDrawing, RectangleDrawingCreator> {
  /// If drawing has been started.
  bool _isPenDown = false;

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);

    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        /// Draw the initial point.
        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );

        _isPenDown = true;

        drawingParts.add(
          RectangleDrawing(
            drawingPart: DrawingParts.marker,
            startEdgePoint: edgePoints.first,
          ),
        );
      } else if (!isDrawingFinished) {
        /// Draw second point and the rectangle.
        _isPenDown = false;
        isDrawingFinished = true;

        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );

        final EdgePoint startEdgePoint = edgePoints.first;
        final EdgePoint endEdgePoint = edgePoints[1];

        if (endEdgePoint == startEdgePoint) {
          widget.removeUnfinishedDrawing();
          widget.clearDrawingToolSelection();
          return;
        } else {
          drawingParts.addAll(<RectangleDrawing>[
            RectangleDrawing(
              drawingPart: DrawingParts.marker,
              endEdgePoint: endEdgePoint,
            ),
            RectangleDrawing(
              drawingPart: DrawingParts.rectangle,
              startEdgePoint: startEdgePoint,
              endEdgePoint: endEdgePoint,
            ),
          ]);
        }
      }

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        edgePoints: <EdgePoint>[...edgePoints],
      );
    });
  }
}
