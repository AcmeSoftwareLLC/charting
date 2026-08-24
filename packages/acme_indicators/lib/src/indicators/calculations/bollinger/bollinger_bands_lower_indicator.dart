import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// Bollinger bands lower indicator
class BollingerBandsLowerIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [k]         Defaults value to 2.
  ///
  /// [bbm]       the middle band Indicator. Typically an SMAIndicator is used.
  ///
  /// [indicator] the deviation above and below the middle, factored by k.
  ///             Typically a StandardDeviationIndicator is used.
  ///
  /// [bandOffset] optionally overrides the bulk math used by
  ///             [calculateValues]; otherwise [IndicatorMathRegistry.bandOffset]
  ///             is used if it has been globally set. When neither is set,
  ///             [calculateValues] isn't overridden and values are computed
  ///             one at a time via [calculate].
  BollingerBandsLowerIndicator(
    this.bbm,
    this.indicator, {
    this.k = 2,
    BandOffsetFn? bandOffset,
  }) : _bandOffset = bandOffset ?? IndicatorMathRegistry.bandOffset,
       super.fromIndicator(bbm);

  /// Indicator
  final CachedIndicator<T> indicator;

  /// The middle indicator of the BollingerBand
  final CachedIndicator<T> bbm;

  /// Default is 2.
  final double k;

  final BandOffsetFn? _bandOffset;

  @override
  T calculate(int index) => createResult(
    index: index,
    quote: bbm.getValue(index).quote - (indicator.getValue(index).quote * k),
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _bandOffset,
    (bandOffset) => bandOffset(seriesFrom(bbm), seriesFrom(indicator), k, -1),
  );

  @override
  void copyValuesFrom(covariant BollingerBandsLowerIndicator<T> other) {
    super.copyValuesFrom(other);
    indicator.copyValuesFrom(other.indicator);
    bbm.copyValuesFrom(other.bbm);
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);

    indicator.invalidate(index);
    bbm.invalidate(index);
  }
}
