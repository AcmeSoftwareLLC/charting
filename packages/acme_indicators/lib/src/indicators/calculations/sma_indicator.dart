import 'package:acme_indicators/src/models/models.dart';

import '../cached_indicator.dart';
import '../indicator.dart';

/// Simple Moving Average Indicator
class SMAIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes.
  SMAIndicator(this.indicator, this.period) : super.fromIndicator(indicator);

  /// Indicator to calculate SMA on
  final Indicator<T> indicator;

  /// Bar count
  final int period;

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
}
