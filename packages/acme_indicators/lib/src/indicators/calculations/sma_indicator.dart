import 'package:acme_indicators/src/models/models.dart';

import '../../math/indicator_math.dart';
import '../../math/indicator_math_functions.dart';
import '../cached_indicator.dart';
import '../indicator.dart';

/// Simple Moving Average Indicator
class SMAIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [sma] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.sma] is
  /// used if it has been globally set. When neither is set, [calculateValues]
  /// isn't overridden and values are computed one at a time via [calculate].
  SMAIndicator(this.indicator, this.period, {SmaFn? sma})
    : _sma = sma ?? IndicatorMathRegistry.sma,
      super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator<T> indicator;

  /// Bar count
  final int period;

  final SmaFn? _sma;

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
    final SmaFn? sma = _sma;
    if (sma == null) {
      return super.calculateValues();
    }

    return applyBulkValues(sma(seriesFrom(indicator), period));
  }
}
