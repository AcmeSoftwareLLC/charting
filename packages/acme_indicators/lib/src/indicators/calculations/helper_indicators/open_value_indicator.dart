import 'package:acme_indicators/src/indicators/indicator.dart';
import 'package:acme_indicators/src/models/data_input.dart';
import 'package:acme_indicators/src/models/models.dart';

/// A helper indicator to get the open value of a list of [IndicatorDataInput]
class OpenValueIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  OpenValueIndicator(super.input);

  @override
  T getValue(int index) =>
      createResult(index: index, quote: entries[index].open);
}
