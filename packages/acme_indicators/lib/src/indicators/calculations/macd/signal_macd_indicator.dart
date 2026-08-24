import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../../models/models.dart';
import '../../cached_indicator.dart';
import 'macd_indicator.dart';

///Signal of Moving Average Convergence Divergence Indicator.
///Normally a 9-day period EMA of MACD.
///
///The signal EMA is taken over the MACD line's own valid range only (from
///index `slowPeriod - 1` onward), not over its zero-padded prefix, so its
///warm-up isn't biased by leading zeros.
class SignalMACDIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  ///Initializes a signal of MACD indicator from the given [MACDIndicator].
  ///
  ///[macd] optionally overrides the bulk math used by [calculateValues];
  ///otherwise [IndicatorMathRegistry.macd] is used if it has been globally
  ///set. When neither is set, [calculateValues] isn't overridden and values
  ///are computed one at a time via [calculate].
  SignalMACDIndicator.fromIndicator(
    MACDIndicator<T> super.indicator, {
    int period = 9,
    MacdFn? macd,
  }) : _macdIndicator = indicator,
       _period = period,
       _multiplier = 2.0 / (period + 1),
       _macd = macd ?? IndicatorMathRegistry.macd,
       super.fromIndicator();

  final MACDIndicator<T> _macdIndicator;
  final int _period;
  final double _multiplier;
  final MacdFn? _macd;

  /// First index at which the signal line has a valid (non-zero) value.
  int get _signalStartIdx => _macdIndicator.slowPeriod - 1 + _period - 1;

  @override
  T calculate(int index) {
    final int signalStartIdx = _signalStartIdx;
    if (index < signalStartIdx) {
      return createResult(index: index, quote: 0);
    }

    if (index == signalStartIdx) {
      final int validFrom = _macdIndicator.slowPeriod - 1;
      double sum = 0;
      for (int i = validFrom; i <= signalStartIdx; i++) {
        sum += _macdIndicator.getValue(i).quote;
      }
      return createResult(index: index, quote: sum / _period);
    }

    final double prevValue = getValue(index - 1).quote;
    return createResult(
      index: index,
      quote: ((_macdIndicator.getValue(index).quote - prevValue) * _multiplier) + prevValue,
    );
  }

  @override
  List<T> calculateValues() => calculateValuesWith(
    _macd,
    (macd) => macd(
      seriesFrom(_macdIndicator.sourceIndicator),
      _macdIndicator.fastPeriod,
      _macdIndicator.slowPeriod,
      _period,
    ).signalVals,
  );

  @override
  void copyValuesFrom(covariant SignalMACDIndicator<T> other) {
    super.copyValuesFrom(other);
    _macdIndicator.copyValuesFrom(other._macdIndicator);
  }

  @override
  void invalidate(int index) {
    _macdIndicator.invalidate(index);
    super.invalidate(index);
  }
}
