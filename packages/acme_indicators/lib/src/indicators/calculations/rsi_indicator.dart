import 'package:acme_indicators/src/indicators/calculations/helper_indicators/gain_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/loss_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/mma_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../cached_indicator.dart';

/// Relative strength index indicator.
class RSIIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an [RSIIndicator] from the given [indicator] and [period].
  RSIIndicator.fromIndicator(super.indicator, int period)
    : _averageGainIndicator = MMAIndicator<T>(
        GainIndicator<T>.fromIndicator(indicator),
        period,
      ),
      _averageLossIndicator = MMAIndicator<T>(
        LossIndicator<T>.fromIndicator(indicator),
        period,
      ),
      super.fromIndicator();

  final MMAIndicator<T> _averageGainIndicator;
  final MMAIndicator<T> _averageLossIndicator;

  @override
  T calculate(int index) {
    final T averageGain = _averageGainIndicator.getValue(index);
    final T averageLoss = _averageLossIndicator.getValue(index);
    if (averageLoss.quote == 0) {
      return averageGain.quote == 0
          ? createResult(index: index, quote: 0)
          : createResult(index: index, quote: 100);
    }

    final double relativeStrength = averageGain.quote / averageLoss.quote;

    return createResult(
      index: index,
      quote: 100 - (100 / (1 + relativeStrength)),
    );
  }

  @override
  void copyValuesFrom(covariant RSIIndicator<T> other) {
    super.copyValuesFrom(other);
    _averageGainIndicator.copyValuesFrom(other._averageGainIndicator);
    _averageLossIndicator.copyValuesFrom(other._averageLossIndicator);
  }

  @override
  void invalidate(int index) {
    _averageLossIndicator.invalidate(index);
    _averageGainIndicator.invalidate(index);
    super.invalidate(index);
  }
}
