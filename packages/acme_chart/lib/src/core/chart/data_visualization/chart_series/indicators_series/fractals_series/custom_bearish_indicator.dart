import '../../../../../../models/tick.dart';
import 'package:acme_indicators/acme_indicators.dart';

/// A version of Bearish indicator specifically to be suitable for
/// `AbstractSingleIndicatorSeries`.
///
/// In `AbstractSingleIndicatorSeries` for better performance, when a new tick
/// is added or the last tick gets updated, we don't recalculate indicator's
/// result for all indices and just for the last tick.
/// But in BearishIndicator we need to recalculate the previous two values
/// after we receive a new tick.
class CustomBearishIndicator extends BearishIndicator<Tick> {
  /// Initializes Bearish indicator.
  CustomBearishIndicator(super.input);

  @override
  void copyValuesFrom(covariant CustomBearishIndicator other) {
    super.copyValuesFrom(other);
    if (entries.length > other.entries.length) {
      final int index = entries.length - 3;
      results[index] = super.calculate(index);
    }
  }
}
