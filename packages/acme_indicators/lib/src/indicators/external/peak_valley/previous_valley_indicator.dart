import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// The most recent confirmed valley value carried forward until a newer
/// valley is found.
///
/// [peakValley] optionally overrides the bulk math used by
/// [calculateValues]; otherwise [IndicatorMathRegistry.peakValley] is used
/// if it has been globally set. When neither is set, there is no per-bar
/// Dart implementation to fall back on and [calculate] throws
/// [UnimplementedError].
class PreviousValleyIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  PreviousValleyIndicator(super.input, {this.strength = 2, PeakValleyFn? peakValley})
    : _peakValley = peakValley ?? IndicatorMathRegistry.peakValley;

  /// Number of neighboring entries on each side that must be higher for an
  /// entry to be considered a valley.
  final int strength;

  final PeakValleyFn? _peakValley;

  @override
  T calculate(int index) => throw UnimplementedError(
    'PreviousValleyIndicator has no per-bar Dart implementation. Supply a '
    'peakValley function via the constructor or '
    'IndicatorMathRegistry.peakValley.',
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _peakValley,
    (peakValley) => peakValley(entries.highs, entries.lows, strength).previousValley,
  );
}
