import 'package:acme_indicators/src/models/models.dart';

import '../../math/indicator_math.dart';
import '../../math/indicator_math_functions.dart';
import '../cached_indicator.dart';
import '../indicator.dart';

/// Simple Moving Average Indicator
class SMAIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [windowedAverage] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.windowedAverage] is
  /// used if it has been globally set. When neither is set, [calculateValues]
  /// isn't overridden and values are computed one at a time via [calculate].
  SMAIndicator(this.indicator, this.period, {WindowedAverageFn? windowedAverage})
    : _windowedAverage = windowedAverage ?? IndicatorMathRegistry.windowedAverage,
      super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  final WindowedAverageFn? _windowedAverage;

  @override
  T calculate(int index) {
    final int start = index - period + 1 < 0 ? 0 : index - period + 1;
    double sum = 0;
    for (int i = start; i <= index; i++) {
      sum += indicator.getValue(i).quote;
    }

    final int realBarCount = index - start + 1;
    return createResult(index: index, quote: sum / realBarCount);
  }

  @override
  List<T> calculateValues() {
    final WindowedAverageFn? windowedAverage = _windowedAverage;
    if (windowedAverage == null) {
      return super.calculateValues();
    }

    if (indicator is CachedIndicator) {
      (indicator as CachedIndicator).calculateValues();
    }

    final List<double> series = <double>[
      for (int i = 0; i < entries.length; i++) indicator.getValue(i).quote,
    ];
    final List<double> result = windowedAverage(series, period);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }
}
