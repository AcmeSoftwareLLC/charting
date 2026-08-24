import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// The most recent confirmed peak value carried forward until a newer peak
/// is found.
///
/// [peakValley] optionally overrides the bulk math used by
/// [calculateValues]; otherwise [IndicatorMathRegistry.peakValley] is used
/// if it has been globally set. When neither is set, there is no per-bar
/// Dart implementation to fall back on and [calculate] throws
/// [UnimplementedError].
class PreviousPeakIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  PreviousPeakIndicator(super.input, {this.strength = 2, PeakValleyFn? peakValley})
    : _peakValley = peakValley ?? IndicatorMathRegistry.peakValley;

  /// Number of neighboring entries on each side that must be lower for an
  /// entry to be considered a peak.
  final int strength;

  final PeakValleyFn? _peakValley;

  @override
  T calculate(int index) => throw UnimplementedError(
    'PreviousPeakIndicator has no per-bar Dart implementation. Supply a '
    'peakValley function via the constructor or '
    'IndicatorMathRegistry.peakValley.',
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _peakValley,
    (peakValley) => peakValley(entries.highs, entries.lows, strength).previousPeak,
  );
}
