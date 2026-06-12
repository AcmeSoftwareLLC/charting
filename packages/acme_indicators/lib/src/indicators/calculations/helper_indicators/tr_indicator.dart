import 'dart:math';

import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

/// True range indicator.
class TRIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes a true range indicator.
  TRIndicator(super.input);

  @override
  T calculate(int index) {
    final double tickSize = entries[index].high - entries[index].low;

    final double highMinusClose =
        index == 0 ? 0 : entries[index].high - entries[index - 1].close;
    final double closeMinusLow =
        index == 0 ? 0 : entries[index - 1].close - entries[index].low;

    return createResult(
      index: index,
      quote: max(
        tickSize.abs(),
        max(
          highMinusClose.abs(),
          closeMinusLow.abs(),
        ),
      ),
    );
  }
}
