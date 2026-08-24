import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// Third resistance pivot level: `previousHigh + 2 * (pivot - previousLow)`.
///
/// [pivotPoints] optionally overrides the bulk math used by
/// [calculateValues]; otherwise [IndicatorMathRegistry.pivotPoints] is used
/// if it has been globally set. When neither is set, there is no per-bar
/// Dart implementation to fall back on and [calculate] throws
/// [UnimplementedError].
class PivotR3Indicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes.
  PivotR3Indicator(super.input, {PivotPointsFn? pivotPoints})
    : _pivotPoints = pivotPoints ?? IndicatorMathRegistry.pivotPoints;

  final PivotPointsFn? _pivotPoints;

  @override
  T calculate(int index) => throw UnimplementedError(
    'PivotR3Indicator has no per-bar Dart implementation. Supply a '
    'pivotPoints function via the constructor or '
    'IndicatorMathRegistry.pivotPoints.',
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _pivotPoints,
    (pivotPoints) => pivotPoints(entries.highs, entries.lows, entries.closes).r3,
  );
}
