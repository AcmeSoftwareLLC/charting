import 'package:acme_indicators/src/indicators/cached_indicator.dart';
import 'package:acme_indicators/src/models/data_input.dart';
import 'package:acme_indicators/src/models/models.dart';

import '../../../math/indicator_math.dart';
import '../../../math/indicator_math_functions.dart';
import '../../indicator.dart';
import '../ema_indicator.dart';
import '../helper_indicators/close_value_inidicator.dart';

/// Moving Average Convergence Divergence Indicator.
class MACDIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Creates a  Moving average convergence divergence indicator from the given [input]],
  /// with short term ema set to `12` periods([fastMAPeriod]) and long term ema set to `26` periods([slowMAPeriod]) as default.
  ///
  /// [macd] optionally overrides the bulk math used by [calculateValues];
  /// otherwise [IndicatorMathRegistry.macd] is used if it has been globally
  /// set. When neither is set, [calculateValues] isn't overridden and values
  /// are computed one at a time via [calculate].
  ///
  /// [ema] is forwarded to the two internal [EMAIndicator]s that back
  /// [calculate]'s per-bar path; it has no effect on the bulk [macd] path.
  MACDIndicator(
    IndicatorDataInput input, {
    int fastMAPeriod = 12,
    int slowMAPeriod = 26,
    MacdFn? macd,
    EmaFn? ema,
  }) : this.fromIndicator(
         CloseValueIndicator<T>(input),
         fastMAPeriod: fastMAPeriod,
         slowMAPeriod: slowMAPeriod,
         macd: macd,
         ema: ema,
       );

  /// Creates a  Moving average convergence divergence indicator from a given [indicator],
  /// with short term ema set to `12` periods([fastMAPeriod]) and long term ema set to `26` periods([slowMAPeriod]) as default.
  ///
  /// [macd] optionally overrides the bulk math used by [calculateValues];
  /// otherwise [IndicatorMathRegistry.macd] is used if it has been globally
  /// set. When neither is set, [calculateValues] isn't overridden and values
  /// are computed one at a time via [calculate].
  ///
  /// [ema] is forwarded to the two internal [EMAIndicator]s that back
  /// [calculate]'s per-bar path; it has no effect on the bulk [macd] path.
  MACDIndicator.fromIndicator(
    super.indicator, {
    int fastMAPeriod = 12,
    int slowMAPeriod = 26,
    MacdFn? macd,
    EmaFn? ema,
  }) : _sourceIndicator = indicator,
       _fastPeriod = fastMAPeriod,
       _slowPeriod = slowMAPeriod,
       _shortTermEma = EMAIndicator<T>(indicator, fastMAPeriod, ema: ema),
       _longTermEma = EMAIndicator<T>(indicator, slowMAPeriod, ema: ema),
       _macd = macd ?? IndicatorMathRegistry.macd,
       super.fromIndicator();

  final Indicator<T> _sourceIndicator;
  final int _fastPeriod;
  final int _slowPeriod;
  final EMAIndicator<T> _shortTermEma;
  final EMAIndicator<T> _longTermEma;
  final MacdFn? _macd;

  /// `signalPeriod` doesn't affect [MacdResult.macdVals]; any positive value
  /// works when calling [_macd] for the line-only computation below.
  static const int _unusedSignalPeriod = 1;

  /// The underlying indicator this MACD line is computed from (e.g. a close-price indicator).
  Indicator<T> get sourceIndicator => _sourceIndicator;

  /// The fast (short-term) EMA period.
  int get fastPeriod => _fastPeriod;

  /// The slow (long-term) EMA period; the MACD line is valid from index `slowPeriod - 1` onward.
  int get slowPeriod => _slowPeriod;

  @override
  T calculate(int index) => createResult(
    index: index,
    quote:
        _shortTermEma.getValue(index).quote -
        _longTermEma.getValue(index).quote,
  );

  @override
  List<T> calculateValues() => calculateValuesWith(
    _macd,
    (macd) => macd(
      seriesFrom(_sourceIndicator),
      _fastPeriod,
      _slowPeriod,
      _unusedSignalPeriod,
    ).macdVals,
  );

  @override
  void copyValuesFrom(covariant MACDIndicator<T> other) {
    super.copyValuesFrom(other);
    _shortTermEma.copyValuesFrom(other._shortTermEma);
    _longTermEma.copyValuesFrom(other._longTermEma);
  }

  @override
  void invalidate(int index) {
    _shortTermEma.invalidate(index);
    _longTermEma.invalidate(index);
    super.invalidate(index);
  }
}
