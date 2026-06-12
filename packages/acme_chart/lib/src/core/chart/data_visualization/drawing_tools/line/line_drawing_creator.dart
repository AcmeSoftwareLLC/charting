import '../../../../../core/chart/data_visualization/drawing_tools/drawing.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/drawing_creator.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:flutter/material.dart';

/// Creates a Line drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a line drawing tool and
/// until drawing is finished
class LineDrawingCreator extends DrawingCreator<Drawing> {
  /// Initializes the line drawing creator.
  const LineDrawingCreator({
    required super.onAddDrawing,
    required super.quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeUnfinishedDrawing,
    required this.createLineDrawing,
    super.key,
  });

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove unfinished drawing from the list of drawings.
  final VoidCallback removeUnfinishedDrawing;

  /// Callback which creates a [LineDrawing] or [LineDrawingMobile]
  /// with the specified parameters.
  final Drawing Function({
    required DrawingParts drawingPart,
    EdgePoint startEdgePoint,
    EdgePoint endEdgePoint,
    bool exceedStart,
    bool exceedEnd,
  })
  createLineDrawing;

  @override
  DrawingCreatorState<Drawing, LineDrawingCreator> createState() =>
      _LineDrawingCreatorState();
}

class _LineDrawingCreatorState
    extends DrawingCreatorState<Drawing, LineDrawingCreator> {
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
      tapCount++;

      if (!_isPenDown) {
        /// Draw the initial point of the line.
        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );
        _isPenDown = true;

        drawingParts.add(
          (widget).createLineDrawing(
            drawingPart: DrawingParts.marker,
            startEdgePoint: edgePoints.first,
          ),
        );
      } else if (!isDrawingFinished) {
        /// Draw final point and the whole line.
        _isPenDown = false;
        isDrawingFinished = true;
        final int currentTap = tapCount - 1;
        final int previousTap = tapCount - 2;

        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );

        /// Checks if the initial point and the final point are the same.
        if (edgePoints[1] == edgePoints.first) {
          /// If the initial point and the 2nd point are the same,
          /// remove the drawing and clean the drawing tool selection.
          widget.removeUnfinishedDrawing();
          widget.clearDrawingToolSelection();
          return;
        } else {
          /// If the initial point and the final point are not the same,
          /// draw the final point and the whole line.
          drawingParts.addAll(<Drawing>[
            (widget).createLineDrawing(
              drawingPart: DrawingParts.marker,
              endEdgePoint: edgePoints[currentTap],
            ),
            (widget).createLineDrawing(
              drawingPart: DrawingParts.line,
              startEdgePoint: edgePoints[previousTap],
              endEdgePoint: edgePoints[currentTap],
              exceedStart: true,
              exceedEnd: true,
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
