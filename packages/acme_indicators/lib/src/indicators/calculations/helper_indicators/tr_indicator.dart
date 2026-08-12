import 'dart:math';

import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';

/// True range indicator.
class TRIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a true range indicator.
  ///
  /// [trueRange] optionally overrides the bulk math used by
  /// [calculateValues]; defaults to [IndicatorMathRegistry.trueRange].
  TRIndicator(super.input, {TrueRangeFn? trueRange})
    : _trueRange = trueRange ?? IndicatorMathRegistry.trueRange;

  final TrueRangeFn _trueRange;

  @override
  T calculate(int index) {
    final double tickSize = entries[index].high - entries[index].low;

    final double highMinusClose = index == 0
        ? 0
        : entries[index].high - entries[index - 1].close;
    final double closeMinusLow = index == 0
        ? 0
        : entries[index - 1].close - entries[index].low;

    return createResult(
      index: index,
      quote: max(
        tickSize.abs(),
        max(highMinusClose.abs(), closeMinusLow.abs()),
      ),
    );
  }

  @override
  List<T> calculateValues() {
    final List<double> high = <double>[for (final IndicatorOHLC e in entries) e.high];
    final List<double> low = <double>[for (final IndicatorOHLC e in entries) e.low];
    final List<double> close = <double>[for (final IndicatorOHLC e in entries) e.close];
    final List<double> result = _trueRange(high, low, close);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }
}
