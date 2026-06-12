import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

/// FractalChaosBand High Indicator
class FCBHighIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  FCBHighIndicator(super.input);

  @override
  T calculate(int index) {
    if (index < 4) {
      return createResult(index: index, quote: double.nan);
    }
    if (entries[index - 2].high > entries[index - 1].high &&
        entries[index - 2].high > entries[index].high &&
        entries[index - 2].high > entries[index - 3].high &&
        entries[index - 2].high > entries[index - 4].high) {
      return createResult(index: index, quote: entries[index - 2].high);
    } else {
      return createResult(index: index, quote: getValue(index - 1).quote);
    }
  }
}
