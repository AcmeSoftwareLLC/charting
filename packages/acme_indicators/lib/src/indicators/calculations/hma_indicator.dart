import 'dart:math';

import 'package:acme_indicators/src/models/models.dart';

import '../cached_indicator.dart';
import 'helper_indicators/difference_indicator.dart';
import 'helper_indicators/multiplier_indicator.dart';
import 'wma_indicator.dart';

/// Hull Moving Average indicator
class HMAIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes
  HMAIndicator(super.indicator, this.period)
      : _sqrtWma = WMAIndicator<T>(
          DifferenceIndicator<T>(
            MultiplierIndicator<T>(WMAIndicator<T>(indicator, period ~/ 2), 2),
            WMAIndicator<T>(indicator, period),
          ),
          sqrt(period).toInt(),
        ),
        super.fromIndicator();

  /// Moving average bar count
  final int period;

  final WMAIndicator<T> _sqrtWma;

  @override
  T calculate(int index) => _sqrtWma.getValue(index);

  @override
  void copyValuesFrom(covariant HMAIndicator<T> other) {
    super.copyValuesFrom(other);
    _sqrtWma.copyValuesFrom(other._sqrtWma);
  }

  @override
  void invalidate(int index) {
    super.invalidate(index);
    _sqrtWma.invalidate(index);
  }
}
