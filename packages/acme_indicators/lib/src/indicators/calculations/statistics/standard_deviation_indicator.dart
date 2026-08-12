import 'dart:math';

import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';
import '../../indicator.dart';
import 'variance_indicator.dart';

/// Standard deviation indicator.
class StandardDeviationIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] the indicator to calculates SD on.
  /// [period]  the time frame
  /// [sqrtOf] optionally overrides the bulk math used by
  /// [calculateValues]; defaults to [IndicatorMathRegistry.sqrtOf].
  StandardDeviationIndicator(
    super.indicator,
    int period, {
    SqrtFn? sqrtOf,
  }) : _sourceIndicator = indicator,
       _period = period,
       _variance = VarianceIndicator<T>(indicator, period),
       _sqrtOf = sqrtOf ?? IndicatorMathRegistry.sqrtOf,
       super.fromIndicator();

  final Indicator<T> _sourceIndicator;
  final int _period;
  final VarianceIndicator<T> _variance;
  final SqrtFn _sqrtOf;

  @override
  T calculate(int index) =>
      createResult(index: index, quote: sqrt(_variance.getValue(index).quote));

  @override
  List<T> calculateValues() {
    if (_sourceIndicator is CachedIndicator) {
      (_sourceIndicator as CachedIndicator).calculateValues();
    }

    final List<double> series = <double>[
      for (int i = 0; i < entries.length; i++) _sourceIndicator.getValue(i).quote,
    ];
    final List<double> result = _sqrtOf(series, _period, 1.0);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }

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
