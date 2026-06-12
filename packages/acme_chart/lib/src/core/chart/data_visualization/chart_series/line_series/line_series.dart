import '../../../../../core/interactive_layer/crosshair/crosshair_dot_painter.dart';
import '../../../../../core/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import '../../../../../core/interactive_layer/crosshair/crosshair_line_highlight_painter.dart';
import '../../../../../core/interactive_layer/crosshair/crosshair_variant.dart';
import '../../../../../models/tick.dart';
import '../../../../../theme/chart_theme.dart';
import '../../../../../theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../series_painter.dart';
import 'line_painter.dart';

/// Line series.
class LineSeries extends DataSeries<Tick> {
  /// Initializes a line series.
  LineSeries(
    super.entries, {
    String? id,
    LineStyle? super.style,
    super.lastTickIndicatorStyle,
  }) : super(
          id: id ?? 'LineSeries',
        );

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => LinePainter(this);

  @override
  Widget getCrossHairInfo(
    Tick crossHairTick,
    int pipSize,
    ChartTheme theme,
    CrosshairVariant crosshairVariant,
  ) =>
      Text(
        crossHairTick.quote.toStringAsFixed(pipSize),
        style: theme.crosshairInformationBoxQuoteStyle.copyWith(
          color: theme.crosshairInformationBoxTextDefault,
        ),
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;

  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
    Tick crosshairTick,
    double Function(double p1) quoteToY,
    double xCenter,
    int granularity,
    double Function(int p1) xFromEpoch,
    ChartTheme theme,
  ) {
    // Return a CrosshairLineHighlightPainter with transparent colors
    // This effectively creates a "no-op" painter that doesn't paint anything visible
    return CrosshairLineHighlightPainter(
      tick: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      pointColor: Colors.transparent,
      pointSize: 0,
    );
  }

  @override
  CrosshairDotPainter getCrosshairDotPainter(ChartTheme theme) {
    // Line series supports dots, so return a CrosshairDotPainter
    // with colors from the theme
    return CrosshairDotPainter(
      dotColor: theme.currentSpotDotColor,
      dotBorderColor: theme.currentSpotDotEffect,
    );
  }

  @override
  double getCrosshairDetailsBoxHeight() {
    return 50;
  }

  @override
  Tick createVirtualTick(int epoch, double quote) {
    return Tick(epoch: epoch, quote: quote);
  }
}
