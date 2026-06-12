import '../../../../../core/chart/data_visualization/chart_series/data_painters/bar_painter.dart';
import '../../../../../core/chart/data_visualization/chart_series/indicators_series/abstract_single_indicator_series.dart';
import '../../../../../core/chart/data_visualization/chart_series/series.dart';
import '../../../../../core/chart/data_visualization/chart_series/series_painter.dart';
import '../../../../../models/indicator_input.dart';
import '../../../../../models/tick.dart';
import '../../../../../theme/painting_styles/bar_style.dart';
import 'package:acme_indicators/acme_indicators.dart';

/// A series which shows Awesome Oscillator Series data calculated
/// from `entries`.
class AwesomeOscillatorSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  AwesomeOscillatorSeries(
    this._indicatorInput, {
    BarStyle barStyle = const BarStyle(),
    String? id,
  }) : super(
          HL2Indicator<Tick>(_indicatorInput),
          id ?? 'AwesomeOscillatorSeries',
          style: barStyle,
        );

  final IndicatorInput _indicatorInput;

  @override
  SeriesPainter<Series> createPainter() => BarPainter(
        this,
        checkColorCallback: (
                {required double previousQuote,
                required double currentQuote}) =>
            currentQuote >= previousQuote,
      );

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      AwesomeOscillatorIndicator<Tick>(_indicatorInput);
}
