import '../../../../../core/interactive_layer/crosshair/crosshair_variant.dart';
import '../../../../../theme/chart_theme.dart';
import '../../../../../models/candle.dart';
import '../../../../../theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';

/// Super-class of series with OHLC data (CandleStick, OHLC, Hollow).
abstract class OHLCTypeSeries extends DataSeries<Candle> {
  /// Initializes
  OHLCTypeSeries(
    super.entries,
    String id, {
    CandleStyle? super.style,
    super.lastTickIndicatorStyle,
  }) : super(
          id: id,
        );

  @override
  Widget getCrossHairInfo(
    Candle crossHairTick,
    int pipSize,
    ChartTheme theme,
    CrosshairVariant crosshairVariant,
  ) {
    if (crosshairVariant == CrosshairVariant.smallScreen) {
      return getCrossHairInfoSmallScreen(
        crossHairTick: crossHairTick,
        pipSize: pipSize,
        theme: theme,
      );
    }
    return getCrossHairInfoLargeScreen(
      crossHairTick: crossHairTick,
      pipSize: pipSize,
      theme: theme,
    );
  }

  Widget _buildLabelValue(
    String label,
    double value,
    int pipSize,
    ChartTheme theme,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: theme.crosshairInformationBoxQuoteStyle.copyWith(
                color: theme.crosshairInformationBoxTextDefault,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 4),
            Text(
              value.toStringAsFixed(pipSize),
              style: theme.crosshairInformationBoxQuoteStyle.copyWith(
                color: theme.crosshairInformationBoxTextDefault,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  /// Creates a widget to display crosshair information for small screens.
  ///
  /// This method builds a compact layout with OHLC (Open, High, Low, Close) values
  /// arranged in two columns to fit smaller screen sizes.
  ///
  /// [crossHairTick] The candle data to display.
  /// [pipSize] The number of decimal places to show in price values.
  /// [theme] The chart theme to use for styling.
  Widget getCrossHairInfoSmallScreen({
    required Candle crossHairTick,
    required int pipSize,
    required ChartTheme theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildLabelValue('O', crossHairTick.open, pipSize, theme),
              _buildLabelValue('L', crossHairTick.low, pipSize, theme),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildLabelValue('H', crossHairTick.high, pipSize, theme),
              _buildLabelValue('C', crossHairTick.close, pipSize, theme),
            ],
          ),
        ),
      ],
    );
  }

  /// Creates a widget to display crosshair information for large screens.
  ///
  /// This method builds a full layout with OHLC (Open, High, Low, Close) values
  /// arranged in a single column with full labels for better readability on larger screens.
  ///
  /// [crossHairTick] The candle data to display.
  /// [pipSize] The number of decimal places to show in price values.
  /// [theme] The chart theme to use for styling.
  Widget getCrossHairInfoLargeScreen({
    required Candle crossHairTick,
    required int pipSize,
    required ChartTheme theme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildLabelValue('Open', crossHairTick.open, pipSize, theme),
        _buildLabelValue('High', crossHairTick.high, pipSize, theme),
        _buildLabelValue('Low', crossHairTick.low, pipSize, theme),
        _buildLabelValue('Close', crossHairTick.close, pipSize, theme),
      ],
    );
  }

  @override
  double maxValueOf(Candle t) => t.high;

  @override
  double minValueOf(Candle t) => t.low;
}
