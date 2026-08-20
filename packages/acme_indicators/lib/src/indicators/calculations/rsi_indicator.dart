import 'package:acme_indicators/src/indicators/calculations/helper_indicators/gain_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/loss_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/mma_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../../math/indicator_math.dart';
import '../../math/indicator_math_functions.dart';
import '../cached_indicator.dart';
import '../indicator.dart';

/// Relative strength index indicator.
class RSIIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an [RSIIndicator] from the given [indicator] and [period].
  ///
  /// [relativeStrength] optionally overrides the bulk math used by
  /// [calculateValues]; otherwise [IndicatorMathRegistry.relativeStrength] is
  /// used if it has been globally set. When neither is set, [calculateValues]
  /// isn't overridden and values are computed one at a time via [calculate].
  RSIIndicator.fromIndicator(
    super.indicator,
    int period, {
    RelativeStrengthFn? relativeStrength,
  }) : _sourceIndicator = indicator,
       _period = period,
       _averageGainIndicator = MMAIndicator<T>(
         GainIndicator<T>.fromIndicator(indicator),
         period,
       ),
       _averageLossIndicator = MMAIndicator<T>(
         LossIndicator<T>.fromIndicator(indicator),
         period,
       ),
       _relativeStrength =
           relativeStrength ?? IndicatorMathRegistry.relativeStrength,
       super.fromIndicator();

  final Indicator<T> _sourceIndicator;
  final int _period;
  final MMAIndicator<T> _averageGainIndicator;
  final MMAIndicator<T> _averageLossIndicator;
  final RelativeStrengthFn? _relativeStrength;

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
  List<T> calculateValues() {
    final RelativeStrengthFn? relativeStrength = _relativeStrength;
    if (relativeStrength == null) {
      return super.calculateValues();
    }

    if (_sourceIndicator is CachedIndicator) {
      (_sourceIndicator as CachedIndicator).calculateValues();
    }

    final List<double> series = <double>[
      for (int i = 0; i < entries.length; i++) _sourceIndicator.getValue(i).quote,
    ];
    final List<double> result = relativeStrength(series, _period);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
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
