import 'package:acme_indicators/src/indicators/indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

/// A helper indicator to get the [(O+ H + L+ C) / 4] value of a list of [IndicatorOHLC]
class OHLC4Indicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  OHLC4Indicator(super.input);

  @override
  T getValue(int index) {
    final IndicatorOHLC entry = entries[index];
    return createResult(
      index: index,
      quote: (entry.open + entry.high + entry.low + entry.close) / 4,
    );
  }
}
