import 'dart:math';

import 'package:acme_indicators/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';
import '../sma_indicator.dart';

/// Mean Deviation Indicator.
class MeanDeviationIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes a [MeanDeviationIndicator].
  MeanDeviationIndicator(this.indicator, this.period)
      : _smaIndicator = SMAIndicator<T>(indicator, period),
        super.fromIndicator(indicator);

  /// Indicator to calculate Mean Deviation on.
  final Indicator<T> indicator;

  /// Period.
  final int period;

  final SMAIndicator<T> _smaIndicator;

  @override
  T calculate(int index) {
    double absoluteDeviations = 0;

    final double average = _smaIndicator.getValue(index).quote;
    final int startIndex = max(0, index - period + 1);
    final int numOfValues = index - startIndex + 1;

    for (int i = startIndex; i <= index; i++) {
      absoluteDeviations =
          absoluteDeviations + ((indicator.getValue(i).quote - average).abs());
    }
    return createResult(index: index, quote: absoluteDeviations / numOfValues);
  }

  @override
  void invalidate(int index) {
    _smaIndicator.invalidate(index);
    super.invalidate(index);
  }

  @override
  void copyValuesFrom(covariant MeanDeviationIndicator<T> other) {
    _smaIndicator.copyValuesFrom(other._smaIndicator);
    super.copyValuesFrom(other);
  }
}
