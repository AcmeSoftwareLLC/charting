import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/dx_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/mma_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

import 'negative_di_indicator.dart';
import 'positive_di_indicator.dart';

/// Average Directional Movement. Part of the Directional Movement System.
class ADXIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes an Average Directional Movement from the given [input]s. Part of the Directional Movement System.
  ADXIndicator(super.input, {int diPeriod = 14, int adxPeriod = 14})
    : _averageDXIndicator = MMAIndicator<T>(
        DXIndicator<T>(input, period: diPeriod),
        adxPeriod,
      );

  /// Initializes an Average Directional Movement from the given [Indicator]s. Part of the Directional Movement System.
  ADXIndicator.fromIndicator(
    PositiveDIIndicator<T> super.positiveDIIndicator,
    NegativeDIIndicator<T> negativeDIIndicator, {
    int adxPeriod = 14,
  }) : _averageDXIndicator = MMAIndicator<T>(
         DXIndicator<T>.fromIndicator(positiveDIIndicator, negativeDIIndicator),
         adxPeriod,
       ),
       super.fromIndicator();

  final MMAIndicator<T> _averageDXIndicator;

  @override
  T calculate(int index) => _averageDXIndicator.getValue(index);

  @override
  void copyValuesFrom(covariant ADXIndicator<T> other) {
    super.copyValuesFrom(other);
    _averageDXIndicator.copyValuesFrom(other._averageDXIndicator);
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);
    _averageDXIndicator.invalidate(index);
  }
}
