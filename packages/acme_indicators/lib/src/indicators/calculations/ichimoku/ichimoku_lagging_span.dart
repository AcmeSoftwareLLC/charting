import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../helper_indicators/close_value_inidicator.dart';

/// An `indicator` to calculate the `close` value the given number of offsets ago.
class IchimokuLaggingSpanIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes an [IchimokuLaggingSpanIndicator].
  IchimokuLaggingSpanIndicator(
    super.input,
  )   : _closeValueIndicator = CloseValueIndicator<T>(input);

  final CloseValueIndicator<T> _closeValueIndicator;

  @override
  T calculate(int index) => _closeValueIndicator.getValue(index);
}
