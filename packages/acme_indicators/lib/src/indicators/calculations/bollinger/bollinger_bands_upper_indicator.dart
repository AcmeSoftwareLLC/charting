import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// Bollinger bands upper indicator
class BollingerBandsUpperIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  ///
  ///  [bbm]       the middle band Indicator. Typically an SMAIndicator is
  ///                  used.
  ///  [deviation] the deviation above and below the middle, factored by k.
  ///                  Typically a StandardDeviationIndicator is used.
  ///  [k]         the scaling factor to multiply the deviation by. Typically 2
  ///  [bandOffset] optionally overrides the bulk math used by
  ///                  [calculateValues]; defaults to
  ///                  [IndicatorMathRegistry.bandOffset].
  BollingerBandsUpperIndicator(
    this.bbm,
    this.deviation, {
    this.k = 2,
    BandOffsetFn? bandOffset,
  }) : _bandOffset = bandOffset ?? IndicatorMathRegistry.bandOffset,
       super.fromIndicator(deviation);

  /// Deviation indicator
  final CachedIndicator<T> deviation;

  /// The middle indicator of the BollingerBand
  final CachedIndicator<T> bbm;

  /// Default is 2.
  final double k;

  final BandOffsetFn _bandOffset;

  @override
  T calculate(int index) => createResult(
    index: index,
    quote: bbm.getValue(index).quote + (deviation.getValue(index).quote * k),
  );

  @override
  List<T> calculateValues() {
    bbm.calculateValues();
    deviation.calculateValues();

    final List<double> middle = <double>[
      for (int i = 0; i < entries.length; i++) bbm.getValue(i).quote,
    ];
    final List<double> deviationValues = <double>[
      for (int i = 0; i < entries.length; i++) deviation.getValue(i).quote,
    ];
    final List<double> result = _bandOffset(middle, deviationValues, k, 1);

    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: result[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }

  @override
  void copyValuesFrom(covariant BollingerBandsUpperIndicator<T> other) {
    super.copyValuesFrom(other);
    deviation.copyValuesFrom(other.deviation);
    bbm.copyValuesFrom(other.bbm);
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);

    deviation.invalidate(index);
    bbm.invalidate(index);
  }
}
