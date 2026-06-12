import 'package:acme_indicators/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/high_value_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:acme_indicators/src/models/data_input.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import '../highest_value_indicator.dart';
import '../lowest_value_indicator.dart';

/// %K also known as the Fast Stochastic Indicator.
/// A stochastic oscillator is a popular technical indicator for generating overbought and oversold signals.
class FastStochasticIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes a Fast Stochastic Indicator from the given [IndicatorDataInput].
  FastStochasticIndicator(
    super.input, {
    int period = 14,
  })  : _indicator = CloseValueIndicator<T>(input),
        _highestValueIndicator =
            HighestValueIndicator<T>(HighValueIndicator<T>(input), period),
        _lowestValueIndicator =
            LowestValueIndicator<T>(LowValueIndicator<T>(input), period);

  /// Initializes a Fast Stochastic Indicator from the given [Indicator].
  FastStochasticIndicator.fromIndicator(
    super.indicator, {
    int period = 14,
  })  : _indicator = indicator,
        _highestValueIndicator = HighestValueIndicator<T>(
            HighValueIndicator<T>(indicator.input), period),
        _lowestValueIndicator = LowestValueIndicator<T>(
            LowValueIndicator<T>(indicator.input), period),
        super.fromIndicator();

  final HighestValueIndicator<T> _highestValueIndicator;
  final LowestValueIndicator<T> _lowestValueIndicator;
  final Indicator<T> _indicator;

  @override
  T calculate(int index) {
    final double highestHighQuote =
        _highestValueIndicator.getValue(index).quote;
    final double lowestLowQuote = _lowestValueIndicator.getValue(index).quote;

    final double kPercent =
        ((_indicator.getValue(index).quote - lowestLowQuote) /
                (highestHighQuote - lowestLowQuote)) *
            100;

    return createResult(index: index, quote: kPercent);
  }

  @override
  void copyValuesFrom(covariant FastStochasticIndicator<T> other) {
    super.copyValuesFrom(other);
    _highestValueIndicator.copyValuesFrom(other._highestValueIndicator);
    _lowestValueIndicator.copyValuesFrom(other._lowestValueIndicator);
  }

  @override
  void invalidate(int index) {
    _highestValueIndicator.invalidate(index);
    _lowestValueIndicator.invalidate(index);
    super.invalidate(index);
  }
}
