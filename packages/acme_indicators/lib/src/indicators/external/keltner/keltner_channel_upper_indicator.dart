import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// Keltner channel upper band (middle band + [multiplier] * ATR).
///
/// [bandOffset] optionally overrides the bulk math used by
/// [calculateValues]; otherwise [IndicatorMathRegistry.bandOffset] is used
/// if it has been globally set. When neither is set, there is no per-bar
/// Dart implementation to fall back on and [calculate] throws
/// [UnimplementedError].
class KeltnerChannelUpperIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [middleIndicator] the middle band indicator. Typically an EMA
  ///   indicator is used.
  /// [atrIndicator] the average true range indicator used to offset the
  ///   middle band.
  KeltnerChannelUpperIndicator(
    this.middleIndicator,
    this.atrIndicator, {
    this.multiplier = 2,
    BandOffsetFn? bandOffset,
  }) : _bandOffset = bandOffset ?? IndicatorMathRegistry.bandOffset,
       super.fromIndicator(middleIndicator);

  /// The middle band indicator of the Keltner channel.
  final CachedIndicator<T> middleIndicator;

  /// The average true range indicator used to offset the middle band.
  final CachedIndicator<T> atrIndicator;

  /// The scaling factor to multiply the ATR by. Defaults to 2.
  final double multiplier;

  final BandOffsetFn? _bandOffset;

  @override
  T calculate(int index) => throw UnimplementedError(
    'KeltnerChannelUpperIndicator has no per-bar Dart implementation. '
    'Supply a bandOffset function via the constructor or '
    'IndicatorMathRegistry.bandOffset.',
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _bandOffset,
    (bandOffset) => bandOffset(
      seriesFrom(middleIndicator),
      seriesFrom(atrIndicator),
      multiplier,
      1,
    ),
  );

  @override
  void copyValuesFrom(covariant KeltnerChannelUpperIndicator<T> other) {
    super.copyValuesFrom(other);
    middleIndicator.copyValuesFrom(other.middleIndicator);
    atrIndicator.copyValuesFrom(other.atrIndicator);
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);
    middleIndicator.invalidate(index);
    atrIndicator.invalidate(index);
  }
}
