import 'package:acme_indicators/src/indicators/indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

/// A helper indicator to get the [(H + L+ 2* C) / 4] value of a list of [IndicatorOHLC]
class HLCC4Indicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  HLCC4Indicator(super.input);

  @override
  T getValue(int index) {
    final IndicatorOHLC entry = entries[index];
    return createResult(
      index: index,
      quote: (entry.high + entry.low + 2 * entry.close) / 4,
    );
  }
}
