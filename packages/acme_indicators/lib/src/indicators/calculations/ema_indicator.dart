import 'package:acme_indicators/src/models/models.dart';

import '../../math/indicator_math.dart';
import '../../math/indicator_math_functions.dart';
import '../cached_indicator.dart';
import '../indicator.dart';

/// Base class for Exponential Moving Average implementations.
abstract class AbstractEMAIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [ema] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.ema]
  /// is used if it has been globally set. When neither is set,
  /// [calculateValues] isn't overridden and values are computed one at a time
  /// via [calculate].
  AbstractEMAIndicator(
    this.indicator,
    this.period,
    this.multiplier, {
    EmaFn? ema,
  }) : _ema = ema ?? IndicatorMathRegistry.ema,
       super.fromIndicator(indicator);

  /// Indicator to calculate EMA on.
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  /// Multiplier
  final double multiplier;

  final EmaFn? _ema;

  @override
  T calculate(int index) {
    if (index == 0) {
      return indicator.getValue(0);
    }

    final double prevValue = getValue(index - 1).quote;
    return createResult(
      index: index,
      quote: ((indicator.getValue(index).quote - prevValue) * multiplier) + prevValue,
    );
  }

  @override
  List<T> calculateValues() {
    final EmaFn? ema = _ema;
    if (ema == null) {
      return super.calculateValues();
    }

    if (indicator is CachedIndicator) {
      (indicator as CachedIndicator).calculateValues();
    }

    final List<double> series = <double>[
      for (int i = 0; i < entries.length; i++) indicator.getValue(i).quote,
    ];
    final List<double> result = ema(series, period, multiplier);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }

  @override
  void copyValuesFrom(covariant AbstractEMAIndicator<T> other) {
    super.copyValuesFrom(other);
    if (indicator is CachedIndicator) {
      (indicator as CachedIndicator<T>).copyValuesFrom(
        other.indicator as CachedIndicator<T>,
      );
    }
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);

    if (indicator is CachedIndicator) {
      (indicator as CachedIndicator<T>).invalidate(index);
    }
  }
}

/// EMA indicator
class EMAIndicator<T extends IndicatorResult> extends AbstractEMAIndicator<T> {
  /// Initializes
  EMAIndicator(
    Indicator<T> indicator,
    int period, {
    EmaFn? ema,
  }) : super(indicator, period, 2.0 / (period + 1), ema: ema);
}
