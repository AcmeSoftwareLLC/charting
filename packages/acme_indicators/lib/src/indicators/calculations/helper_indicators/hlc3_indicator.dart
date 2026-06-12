import 'package:acme_indicators/src/indicators/indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

/// A helper indicator to get the [(H + L+ C) / 3] value of a list of [IndicatorOHLC]
class HLC3Indicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  HLC3Indicator(super.input);

  @override
  T getValue(int index) {
    final IndicatorOHLC entry = entries[index];
    return createResult(
      index: index,
      quote: (entry.high + entry.low + entry.close) / 3,
    );
  }
}
