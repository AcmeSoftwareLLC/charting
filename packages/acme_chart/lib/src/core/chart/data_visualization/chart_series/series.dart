import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/chart_series/series_painter.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/chart/data_visualization/models/chart_scale_model.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/material.dart';

/// Base class of all chart series.
abstract class Series implements ChartData {
  /// Initializes a base class of all chart series.
  Series(this.id, {this.style, this.axisGroup}) {
    seriesPainter = createPainter();
    id = '$runtimeType${seriesPainter.runtimeType}$id';
  }

  @override
  String id;

  /// Responsible for painting a frame of this series on the canvas.
  @protected
  SeriesPainter<Series>? seriesPainter;

  /// The painting style of this [Series].
  final ChartPaintingStyle? style;

  /// Which axis this series scales against.
  ///
  /// Only meaningful for overlay series (drawn on the main chart alongside
  /// the candles): `null` (the default) shares the main price axis, same as
  /// before. A non-null value scales this series on its own value range
  /// instead — still painted layered over the candles, but excluded from the
  /// shared candle/overlay min/max, so a small- or large-scale indicator
  /// (e.g. a MACD-derived signal) doesn't distort the price axis. Overlay
  /// series with the same non-null [axisGroup] share one combined scale
  /// (e.g. a thick/thin pair of the same indicator family); different groups
  /// are scaled and painted separately, so one indicator's range never
  /// distorts another's (e.g. a 0-10-bounded indicator and a MACD-scale
  /// indicator must use different groups). Ignored for non-overlay
  /// (bottom-panel) series, which already have their own axis.
  final String? axisGroup;

  /// Minimum value of this series in a visible range of the chart.
  @protected
  double? minValueInFrame;

  /// Maximum value of this series in a visible range of the chart.
  @protected
  double? maxValueInFrame;

  /// Min quote in a frame.
  @override
  double get minValue => minValueInFrame ?? double.nan;

  /// Max quote in a frame.
  @override
  double get maxValue => maxValueInFrame ?? double.nan;

  /// Updates visible entries for this Series.
  @override
  void update(int leftEpoch, int rightEpoch) {
    onUpdate(leftEpoch, rightEpoch);

    final List<double> minMaxValues = recalculateMinMax();

    minValueInFrame = minMaxValues[0];
    maxValueInFrame = minMaxValues[1];
  }

  @override
  bool shouldRepaint(ChartData? previous) => true;

  /// Calculate min/max values in updated data
  List<double> recalculateMinMax();

  /// Updates series visible data.
  void onUpdate(int leftEpoch, int rightEpoch);

  /// Is called whenever series is created to create its [seriesPainter]
  /// as well.
  SeriesPainter<Series>? createPainter();

  /// Paints [seriesPainter]'s data on the [canvas].
  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
    ChartScaleModel chartScaleModel,
  ) => seriesPainter?.paint(
    canvas: canvas,
    size: size,
    epochToX: epochToX,
    quoteToY: quoteToY,
    animationInfo: animationInfo,
    chartConfig: chartConfig,
    theme: theme,
    chartScaleModel: chartScaleModel,
  );
}
