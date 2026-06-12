import 'package:acme_indicators/src/models/models.dart';

import 'ichimoku_line_indicator.dart';

/// An `indicator` to calculate average of `Highest High` and `Lowest Low` in the last given number of `period`s which is set to `52` by default.
class IchimokuSpanBIndicator<T extends IndicatorResult>
    extends IchimokuLineIndicator<T> {
  /// Initializes an [IchimokuSpanBIndicator].
  IchimokuSpanBIndicator(
    super.input, {
    super.period = 52,
  });
}
