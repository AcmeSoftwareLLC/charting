import 'package:acme_indicators/src/models/data_input.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../cached_indicator.dart';
import 'helper_indicators/close_value_inidicator.dart';
import 'helper_indicators/high_value_indicator.dart';
import 'helper_indicators/low_value_indicator.dart';
import 'highest_value_indicator.dart';
import 'lowest_value_indicator.dart';

/// WilliamsRIndicator
class WilliamsRIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes WilliamsR indicator
  WilliamsRIndicator(
    IndicatorDataInput input,
    int period, {
    double multiplier = -100,
  }) : this._(
         CloseValueIndicator<T>(input),
         period,
         HighValueIndicator<T>(input),
         LowValueIndicator<T>(input),
         multiplier,
       );

  WilliamsRIndicator._(
    this._closeValueIndicator,
    this.period,
    HighValueIndicator<T> highValueIndicator,
    LowValueIndicator<T> lowValueIndicator,
    this.multiplier,
  ) : _highestHigh = HighestValueIndicator<T>(highValueIndicator, period),
      _lowestLow = LowestValueIndicator<T>(lowValueIndicator, period),
      super.fromIndicator(_closeValueIndicator);

  /// Period.
  final int period;

  /// Multiplier, usually is -100.
  final double multiplier;

  final CloseValueIndicator<T> _closeValueIndicator;
  final HighestValueIndicator<T> _highestHigh;
  final LowestValueIndicator<T> _lowestLow;

  @override
  T calculate(int index) {
    final double highestValue = _highestHigh.getValue(index).quote;
    final double lowestLowValue = _lowestLow.getValue(index).quote;

    return createResult(
      index: index,
      quote:
          ((highestValue - _closeValueIndicator.getValue(index).quote) /
              (highestValue - lowestLowValue)) *
          multiplier,
    );
  }

  @override
  void copyValuesFrom(covariant WilliamsRIndicator<T> other) {
    super.copyValuesFrom(other);
    _highestHigh.copyValuesFrom(other._highestHigh);
    _lowestLow.copyValuesFrom(other._lowestLow);
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);
    _highestHigh.invalidate(index);
    _lowestLow.invalidate(index);
  }
}
