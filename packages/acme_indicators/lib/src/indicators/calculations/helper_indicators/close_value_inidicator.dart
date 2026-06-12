import 'package:acme_indicators/src/indicators/indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

/// A helper indicator which gets the close values of List of [IndicatorOHLC]
class CloseValueIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  CloseValueIndicator(super.input);

  @override
  T getValue(int index) => createResult(
        index: index,
        quote: entries[index].close,
      );
}
