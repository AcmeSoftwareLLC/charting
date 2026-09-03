import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../theme/painting_styles/line_style.dart';
import 'package:material_ui/material_ui.dart';

import '../drawing_adding_preview.dart';
import 'doodle_interactable_drawing.dart';

/// Base class for doodle (freehand) adding preview implementations.
///
/// A doodle is drawn by dragging across the chart rather than by tapping
/// fixed points, so — unlike the other tools' adding previews — this shares
/// stroke sampling logic (start/extend/finish) instead of point-count
/// bookkeeping.
abstract class DoodleAddingPreview
    extends DrawingAddingPreview<DoodleInteractableDrawing> {
  /// Initializes the base doodle adding preview.
  DoodleAddingPreview({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  });

  /// A doodle is drawn by dragging from an empty canvas — there's nothing to
  /// hit yet when the stroke starts.
  @override
  bool get canStartDragFromEmpty => true;

  /// The minimum on-screen distance, in pixels, between two consecutive
  /// sampled points. Keeps the point list from growing unreasonably large
  /// while the pointer barely moves.
  static const double minSampleDistance = 3;

  // The true, continuously-updated pointer position, advanced by every
  // drag delta regardless of whether it was far enough to be sampled.
  // Kept separate from the last *sampled* point (points.last) so that a
  // run of below-threshold deltas still accumulates instead of being
  // discarded — reconstructing the position from points.last + the latest
  // delta alone would drop every skipped delta and could freeze the
  // stroke during a slow drag.
  Offset? _currentOffset;
  Offset? _lastSampledOffset;

  /// Retrieves the line style configured for the doodle being created.
  LineStyle getLineStyle() => interactableDrawing.config.lineStyle;

  /// Starts a new stroke at [offset], discarding any previous points.
  void startStroke(
    Offset offset,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
  ) {
    interactableDrawing.points = <EdgePoint>[
      EdgePoint(epoch: epochFromX(offset.dx), quote: quoteFromY(offset.dy)),
    ];
    _currentOffset = offset;
    _lastSampledOffset = offset;
  }

  /// Advances the stroke by [delta] (as reported by the drag gesture),
  /// sampling a new point only once the accumulated movement since the
  /// last sampled point reaches [minSampleDistance].
  void extendStrokeByDelta(
    Offset delta,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
  ) {
    final Offset offset = (_currentOffset ?? Offset.zero) + delta;
    _currentOffset = offset;

    final Offset lastOffset = _lastSampledOffset ?? offset;
    if ((offset - lastOffset).distance < minSampleDistance) {
      return;
    }

    interactableDrawing.points.add(
      EdgePoint(epoch: epochFromX(offset.dx), quote: quoteFromY(offset.dy)),
    );
    _lastSampledOffset = offset;
  }

  /// Finishes the stroke, ensuring it has at least two points so it always
  /// renders as a visible mark even from a single tap-like drag.
  void finishStroke() {
    final List<EdgePoint> points = interactableDrawing.points;
    if (points.length == 1) {
      points.add(points.first);
    }
  }
}
