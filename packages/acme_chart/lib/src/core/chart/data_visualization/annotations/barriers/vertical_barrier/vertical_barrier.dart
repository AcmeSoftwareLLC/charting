import '../../../../../../core/chart/data_visualization/chart_series/series.dart';
import '../../../../../../core/chart/data_visualization/chart_series/series_painter.dart';
import '../../../../../../core/chart/data_visualization/models/barrier_objects.dart';
import '../../../../../../models/tick.dart';
import '../../../../../../theme/painting_styles/barrier_style.dart';

import '../barrier.dart';
import 'vertical_barrier_painter.dart';

/// Vertical barrier class.
class VerticalBarrier extends Barrier {
  /// Initializes a vertical barrier class.
  VerticalBarrier(
    int epoch, {
    super.quote,
    super.id,
    super.title,
    super.style,
    super.longLine,
  }) : super(
          epoch: epoch,
        );

  /// A vertical barrier on [Tick]'s epoch.
  factory VerticalBarrier.onTick(
    Tick tick, {
    String? id,
    String? title,
    BarrierStyle? style,
    bool longLine = true,
  }) =>
      VerticalBarrier(
        tick.epoch,
        quote: tick.quote,
        id: id,
        title: title,
        style: style,
        longLine: longLine,
      );

  @override
  SeriesPainter<Series> createPainter() => VerticalBarrierPainter(this);

  @override
  BarrierObject createObject() => VerticalBarrierObject(epoch!, quote: quote);

  // Force repaint to ensure vertical barrier gets cleared when out of range.
  // Safe since onPaint() in [VerticalBarrierPainter] checks
  // series.isOnRange before drawing.
  @override
  bool shouldRepaint(covariant Barrier previous) {
    return true;
  }

  @override
  List<double> recalculateMinMax() =>
      isOnRange ? super.recalculateMinMax() : <double>[double.nan, double.nan];
}
