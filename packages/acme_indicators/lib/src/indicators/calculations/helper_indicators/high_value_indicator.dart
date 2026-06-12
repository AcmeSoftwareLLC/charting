import 'package:acme_indicators/src/models/models.dart';

import '../../indicator.dart';

/// A helper indicator to get the high value of a list of [IndicatorOHLC]
class HighValueIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  HighValueIndicator(super.input);

  @override
  T getValue(int index) => createResult(
        index: index,
        quote: entries[index].high,
      );
}
