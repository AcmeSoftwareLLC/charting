import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../atr_indicator.dart';
import '../helper_indicators/positive_dm_indicator.dart';
import '../mma_indicator.dart';

/// Positive Directional indicator. Part of the Directional Movement System.
class PositiveDIIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes Positive Directional indicator.
  PositiveDIIndicator(super.input, {int period = 14})
    : _avgPositiveDMIndicator = MMAIndicator<T>(
        PositiveDMIndicator<T>(input),
        period,
      ),
      _atrIndicator = ATRIndicator<T>(input, period: period);

  final MMAIndicator<T> _avgPositiveDMIndicator;
  final ATRIndicator<T> _atrIndicator;

  @override
  T calculate(int index) => createResult(
    index: index,
    quote:
        (_avgPositiveDMIndicator.getValue(index).quote /
            _atrIndicator.getValue(index).quote) *
        100,
  );

  @override
  void copyValuesFrom(covariant PositiveDIIndicator<T> other) {
    super.copyValuesFrom(other);
    _avgPositiveDMIndicator.copyValuesFrom(other._avgPositiveDMIndicator);
    _atrIndicator.copyValuesFrom(other._atrIndicator);
  }

  @override
  void invalidate(int index) {
    _avgPositiveDMIndicator.invalidate(index);
    _atrIndicator.invalidate(index);
    super.invalidate(index);
  }
}
