import 'package:acme_indicators/src/models/models.dart';

import '../../indicator.dart';

/// A helper indicator to get the low value of a list of [IndicatorOHLC]
class LowValueIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  LowValueIndicator(super.input);

  @override
  T getValue(int index) => createResult(
        index: index,
        quote: entries[index].low,
      );
}
