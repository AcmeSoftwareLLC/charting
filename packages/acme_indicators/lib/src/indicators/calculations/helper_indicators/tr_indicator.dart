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
  /// [calculateValues]; otherwise [IndicatorMathRegistry.trueRange] is used
  /// if it has been globally set. When neither is set, [calculateValues]
  /// isn't overridden and values are computed one at a time via [calculate].
  TRIndicator(super.input, {TrueRangeFn? trueRange})
    : _trueRange = trueRange ?? IndicatorMathRegistry.trueRange;

  final TrueRangeFn? _trueRange;

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
  List<T> calculateValues() => calculateValuesWith(
    _trueRange,
    (trueRange) => trueRange(entries.highs, entries.lows, entries.closes),
  );
}
