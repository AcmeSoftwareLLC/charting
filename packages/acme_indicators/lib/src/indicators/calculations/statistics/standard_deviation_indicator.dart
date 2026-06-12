import 'dart:math';

import 'package:acme_indicators/src/models/models.dart';

import '../../cached_indicator.dart';
import 'variance_indicator.dart';

/// Standard deviation indicator.
class StandardDeviationIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] the indicator to calculates SD on.
  /// [period]  the time frame
  StandardDeviationIndicator(super.indicator, int period)
      : _variance = VarianceIndicator<T>(indicator, period),
        super.fromIndicator();

  final VarianceIndicator<T> _variance;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: sqrt(_variance.getValue(index).quote),
      );

  @override
  void copyValuesFrom(covariant StandardDeviationIndicator<T> other) {
    super.copyValuesFrom(other);
    _variance.copyValuesFrom(other._variance);
  }

  @override
  void invalidate(int index) {
    _variance.invalidate(index);
    super.invalidate(index);
  }
}
