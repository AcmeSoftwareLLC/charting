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
  /// [averageTrueRange] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.averageTrueRange] is
  /// used if it has been globally set. When neither is set,
  /// [calculateValues] isn't overridden and values are computed one at a time
  /// via [calculate].
  ATRIndicator(
    super.input, {
    int period = 14,
    AverageTrueRangeFn? averageTrueRange,
  }) : _period = period,
       _averageTrueRange =
           averageTrueRange ?? IndicatorMathRegistry.averageTrueRange,
       _averageTrueRangeIndicator = MMAIndicator<T>(TRIndicator<T>(input), period);

  final int _period;
  final AverageTrueRangeFn? _averageTrueRange;
  final MMAIndicator<T> _averageTrueRangeIndicator;

  @override
  T calculate(int index) => _averageTrueRangeIndicator.getValue(index);

  @override
  List<T> calculateValues() {
    final AverageTrueRangeFn? averageTrueRange = _averageTrueRange;
    if (averageTrueRange == null) {
      return super.calculateValues();
    }

    final List<double> high = <double>[for (final IndicatorOHLC e in entries) e.high];
    final List<double> low = <double>[for (final IndicatorOHLC e in entries) e.low];
    final List<double> close = <double>[for (final IndicatorOHLC e in entries) e.close];
    final List<double> result = averageTrueRange(high, low, close, _period);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
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
