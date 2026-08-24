import '../../math/indicator_math.dart';
import '../../math/indicator_math_functions.dart';
import '../../models/models.dart';
import '../cached_indicator.dart';
import 'helper_indicators/tr_indicator.dart';
import 'mma_indicator.dart';

/// Average true range indicator.
class ATRIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an average true range indicator.
  ///
  /// [atr] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.atr] is
  /// used if it has been globally set. When neither is set,
  /// [calculateValues] isn't overridden and values are computed one at a time
  /// via [calculate].
  ATRIndicator(
    super.input, {
    int period = 14,
    AtrFn? atr,
  }) : _period = period,
       _atr = atr ?? IndicatorMathRegistry.atr,
       _averageTrueRangeIndicator = MMAIndicator<T>(TRIndicator<T>(input), period);

  final int _period;
  final AtrFn? _atr;
  final MMAIndicator<T> _averageTrueRangeIndicator;

  @override
  T calculate(int index) => _averageTrueRangeIndicator.getValue(index);

  @override
  List<T> calculateValues() {
    final AtrFn? atr = _atr;
    if (atr == null) {
      return super.calculateValues();
    }

    return applyBulkValues(atr(entries.highs, entries.lows, entries.closes, _period));
  }

  @override
  void copyValuesFrom(covariant ATRIndicator<T> other) {
    super.copyValuesFrom(other);
    _averageTrueRangeIndicator.copyValuesFrom(other._averageTrueRangeIndicator);
  }

  @override
  void invalidate(int index) {
    _averageTrueRangeIndicator.invalidate(index);
    super.invalidate(index);
  }
}
