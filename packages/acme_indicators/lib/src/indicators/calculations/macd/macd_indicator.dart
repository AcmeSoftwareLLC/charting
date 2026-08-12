import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/data_input.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../indicator.dart';
import '../ema_indicator.dart';
import '../helper_indicators/close_value_inidicator.dart';

/// Moving Average Convergence Divergence Indicator.
class MACDIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Creates a  Moving average convergence divergence indicator from the given [input]],
  /// with short term ema set to `12` periods([fastMAPeriod]) and long term ema set to `26` periods([slowMAPeriod]) as default.
  ///
  /// [exponentialSmoothing] optionally overrides the EMA math used
  /// by [calculateValues]; defaults to
  /// [IndicatorMathRegistry.exponentialSmoothing].
  MACDIndicator(
    IndicatorDataInput input, {
    int fastMAPeriod = 12,
    int slowMAPeriod = 26,
    ExponentialSmoothingFn? exponentialSmoothing,
  }) : this.fromIndicator(
         CloseValueIndicator<T>(input),
         fastMAPeriod: fastMAPeriod,
         slowMAPeriod: slowMAPeriod,
         exponentialSmoothing: exponentialSmoothing,
       );

  /// Creates a  Moving average convergence divergence indicator from a given [indicator],
  /// with short term ema set to `12` periods([fastMAPeriod]) and long term ema set to `26` periods([slowMAPeriod]) as default.
  ///
  /// [exponentialSmoothing] optionally overrides the EMA math used
  /// by [calculateValues]; defaults to
  /// [IndicatorMathRegistry.exponentialSmoothing].
  MACDIndicator.fromIndicator(
    super.indicator, {
    int fastMAPeriod = 12,
    int slowMAPeriod = 26,
    ExponentialSmoothingFn? exponentialSmoothing,
  }) : _sourceIndicator = indicator,
       _fastPeriod = fastMAPeriod,
       _slowPeriod = slowMAPeriod,
       _shortTermEma = EMAIndicator<T>(indicator, fastMAPeriod),
       _longTermEma = EMAIndicator<T>(indicator, slowMAPeriod),
       _exponentialSmoothing =
           exponentialSmoothing ?? IndicatorMathRegistry.exponentialSmoothing,
       super.fromIndicator();

  final Indicator<T> _sourceIndicator;
  final int _fastPeriod;
  final int _slowPeriod;
  final EMAIndicator<T> _shortTermEma;
  final EMAIndicator<T> _longTermEma;
  final ExponentialSmoothingFn _exponentialSmoothing;

  @override
  T calculate(int index) => createResult(
    index: index,
    quote:
        _shortTermEma.getValue(index).quote -
        _longTermEma.getValue(index).quote,
  );

  @override
  List<T> calculateValues() {
    if (_sourceIndicator is CachedIndicator) {
      (_sourceIndicator as CachedIndicator).calculateValues();
    }

    final List<double> series = <double>[
      for (int i = 0; i < entries.length; i++) _sourceIndicator.getValue(i).quote,
    ];
    final List<double> fastEma = _exponentialSmoothing(
      series,
      _fastPeriod,
      2.0 / (_fastPeriod + 1),
    );
    final List<double> slowEma = _exponentialSmoothing(
      series,
      _slowPeriod,
      2.0 / (_slowPeriod + 1),
    );

    // Both EMAs are only valid from index (_slowPeriod - 1) onward; before
    // that, the slow EMA's own array is still zero-filled, so a naive
    // elementwise subtraction would produce meaningless values rather than
    // the lookback-region zero every other bulk-computed indicator uses.
    final int validFrom = _slowPeriod - 1;
    for (int i = 0; i < entries.length; i++) {
      final double quote = i < validFrom ? 0 : fastEma[i] - slowEma[i];
      results[i] = createResult(index: i, quote: quote);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }

  @override
  void copyValuesFrom(covariant MACDIndicator<T> other) {
    super.copyValuesFrom(other);
    _shortTermEma.copyValuesFrom(other._shortTermEma);
    _longTermEma.copyValuesFrom(other._longTermEma);
  }

  @override
  void invalidate(int index) {
    _shortTermEma.invalidate(index);
    _longTermEma.invalidate(index);
    super.invalidate(index);
  }
}
