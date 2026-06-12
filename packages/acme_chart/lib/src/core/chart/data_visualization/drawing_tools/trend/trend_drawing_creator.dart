// ignore_for_file: use_setters_to_change_properties

import '../../../../../core/interactive_layer/crosshair/find.dart';
import '../../../../../core/chart/data_visualization/chart_series/data_series.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/drawing_creator.dart';
import '../../../../../core/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import '../../../../../models/tick.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Trend drawing right after selecting the trend drawing tool
/// and until drawing is finished
class TrendDrawingCreator extends DrawingCreator<TrendDrawing> {
  /// Initializes the trend drawing creator.
  const TrendDrawingCreator({
    required super.onAddDrawing,
    required super.quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeUnfinishedDrawing,
    required this.series,
    super.key,
  });

  /// Series of tick
  final DataSeries<Tick> series;

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final VoidCallback removeUnfinishedDrawing;

  @override
  DrawingCreatorState<TrendDrawing, TrendDrawingCreator> createState() =>
      _TrendDrawingCreatorState();
}

class _TrendDrawingCreatorState
    extends DrawingCreatorState<TrendDrawing, TrendDrawingCreator> {
  /// If drawing has been started.
  bool _isPenDown = false;

  /// Stores coordinate of first point on the graph
  int? _startingPointEpoch;

  static const int touchDistanceThreshold = 200;

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);

    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        // index of the start point in the series
        final int startPointIndex = findClosestIndexBinarySearch(
          epochFromX!(position!.dx),
          widget.series.entries,
        );

        // starting point on graph
        final Tick startingPoint = widget.series.entries![startPointIndex];

        _startingPointEpoch = startingPoint.epoch;

        /// Draw the initial point of the line.
        edgePoints.add(
          EdgePoint(epoch: startingPoint.epoch, quote: startingPoint.quote),
        );

        _isPenDown = true;

        drawingParts.add(
          TrendDrawing(
            drawingPart: DrawingParts.marker,
            startEdgePoint: edgePoints.first,
          ),
        );
      } else if (!isDrawingFinished) {
        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );

        /// Draw final drawing
        _isPenDown = false;
        isDrawingFinished = true;
        final EdgePoint startingEdgePoint = edgePoints.first;
        final EdgePoint endingEdgePoint = edgePoints.last;

        // When the second point is on the same y
        // coordinate as the first point
        if ((_startingPointEpoch! - endingEdgePoint.epoch).abs() <=
            touchDistanceThreshold) {
          /// remove the drawing and clean the drawing tool selection.
          widget.removeUnfinishedDrawing();
          widget.clearDrawingToolSelection();
          return;
        }

        drawingParts
          ..removeAt(0)
          ..addAll(<TrendDrawing>[
            TrendDrawing(
              drawingPart: DrawingParts.rectangle,
              startEdgePoint: startingEdgePoint,
              endEdgePoint: endingEdgePoint,
            ),
            TrendDrawing(
              drawingPart: DrawingParts.line,
              startEdgePoint: startingEdgePoint,
              endEdgePoint: endingEdgePoint,
            ),
            TrendDrawing(
              drawingPart: DrawingParts.marker,
              startEdgePoint: startingEdgePoint,
              endEdgePoint: endingEdgePoint,
            ),
          ]);
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
