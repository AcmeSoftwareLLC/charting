import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../cached_indicator.dart';

/// Classic pivot point, computed from the previous period's high, low and
/// close: `(high + low + close) / 3`.
///
/// [pivotPoints] optionally overrides the bulk math used by
/// [calculateValues]; otherwise [IndicatorMathRegistry.pivotPoints] is used
/// if it has been globally set. When neither is set, there is no per-bar
/// Dart implementation to fall back on and [calculate] throws
/// [UnimplementedError].
class PivotPointIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes.
  PivotPointIndicator(super.input, {PivotPointsFn? pivotPoints})
    : _pivotPoints = pivotPoints ?? IndicatorMathRegistry.pivotPoints;

  final PivotPointsFn? _pivotPoints;

  @override
  T calculate(int index) => throw UnimplementedError(
    'PivotPointIndicator has no per-bar Dart implementation. Supply a '
    'pivotPoints function via the constructor or '
    'IndicatorMathRegistry.pivotPoints.',
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _pivotPoints,
    (pivotPoints) => pivotPoints(entries.highs, entries.lows, entries.closes).pivot,
  );
}
