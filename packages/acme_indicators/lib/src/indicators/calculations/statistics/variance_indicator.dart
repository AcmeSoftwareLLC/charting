import 'dart:math' as math;

import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';
import '../../indicator.dart';
import '../sma_indicator.dart';

/// Variance indicator.
class VarianceIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  ///
  /// [indicator] the indicator
  /// [period]  the time frame
  /// [variance] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.variance] is used if
  /// it has been globally set. When neither is set, [calculateValues] isn't
  /// overridden and values are computed one at a time via [calculate].
  VarianceIndicator(
    this.indicator,
    this.period, {
    VarianceFn? variance,
  }) : _sma = SMAIndicator<T>(indicator, period),
       _variance = variance ?? IndicatorMathRegistry.variance,
       super.fromIndicator(indicator);

  /// Indicator
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  final SMAIndicator<T> _sma;
  final VarianceFn? _variance;

  @override
  T calculate(int index) {
    final int startIndex = math.max(0, index - period + 1);
    final int numberOfObservations = index - startIndex + 1;
    double variance = 0;
    final double average = _sma.getValue(index).quote;

    for (int i = startIndex; i <= index; i++) {
      final double pow =
          math.pow(indicator.getValue(i).quote - average, 2) as double;
      variance = variance + pow;
    }

    variance = variance / numberOfObservations;

    return createResult(index: index, quote: variance);
  }

  @override
  List<T> calculateValues() {
    final VarianceFn? variance = _variance;
    if (variance == null) {
      return super.calculateValues();
    }

    return applyBulkValues(variance(seriesFrom(indicator), period));
  }

  @override
  void copyValuesFrom(covariant VarianceIndicator<T> other) {
    super.copyValuesFrom(other);
    _sma.copyValuesFrom(other._sma);
  }

  @override
  void invalidate(int index) {
    _sma.invalidate(index);
    super.invalidate(index);
  }
}
