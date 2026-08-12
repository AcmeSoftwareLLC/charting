import 'dart:math' as math;

import 'indicator_math_functions.dart';

/// Built-in, pure-Dart default implementations of each bulk math shape,
/// ported faithfully from gc-core's `pkg/indicators` Go package (and, for
/// the pieces gc-core doesn't re-expose separately — variance, standard
/// deviation, true range — from the go-talib functions gc-core's `BBands`
/// and `Atr` transitively depend on). These are the functions used when
/// neither a per-instance override nor a registry override is present.
abstract final class DefaultIndicatorMath {
  /// Default [WindowedAverageFn]. Matches gc-core's `Sma`.
  static List<double> windowedAverage(List<double> values, int period) {
    final int length = values.length;
    final List<double> result = List<double>.filled(length, 0);
    final int startIdx = period - 1;
    if (startIdx < 0 || startIdx >= length) {
      return result;
    }

    double periodTotal = 0;
    const int trailingIdx = 0;
    int i = trailingIdx;
    if (period > 1) {
      while (i < startIdx) {
        periodTotal += values[i];
        i++;
      }
    }

    int trailing = trailingIdx;
    int outIdx = startIdx;
    bool ok = true;
    while (ok) {
      periodTotal += values[i];
      final double tempReal = periodTotal;
      periodTotal -= values[trailing];
      result[outIdx] = tempReal / period;
      trailing++;
      i++;
      outIdx++;
      ok = i < length;
    }
    return result;
  }

  /// Default [ExponentialSmoothingFn]. Matches gc-core's `Ema` (a
  /// pass-through to `talib.Ema`) when `multiplier` is `2 / (period + 1)`;
  /// the same shape backs Wilder/MMA smoothing when `multiplier` is
  /// `1 / period`.
  static List<double> exponentialSmoothing(
    List<double> values,
    int period,
    double multiplier,
  ) {
    final int length = values.length;
    final List<double> result = List<double>.filled(length, 0);
    final int startIdx = period - 1;
    if (startIdx < 0 || startIdx >= length) {
      return result;
    }

    int today = 0;
    int i = period;
    double tempReal = 0;
    while (i > 0) {
      tempReal += values[today];
      today++;
      i--;
    }

    double prevMA = tempReal / period;
    while (today <= startIdx) {
      prevMA = ((values[today] - prevMA) * multiplier) + prevMA;
      today++;
    }

    result[startIdx] = prevMA;
    int outIdx = startIdx + 1;
    while (today < length) {
      prevMA = ((values[today] - prevMA) * multiplier) + prevMA;
      result[outIdx] = prevMA;
      today++;
      outIdx++;
    }
    return result;
  }

  /// Default [RelativeStrengthFn]. Matches gc-core's custom `Rsi`
  /// exactly: ties resolve `avgLoss == 0 -> 100` before `avgGain == 0 -> 0`,
  /// and every value is rounded to 2 decimal places.
  static List<double> relativeStrength(List<double> values, int period) {
    final int length = values.length;
    final List<double> result = List<double>.filled(length, 0);
    if (period < 1 || length <= period) {
      return result;
    }

    double gainSum = 0;
    double lossSum = 0;
    for (int i = 1; i <= period; i++) {
      final double diff = values[i] - values[i - 1];
      if (diff > 0) {
        gainSum += diff;
      } else {
        lossSum -= diff;
      }
    }

    double avgGain = gainSum / period;
    double avgLoss = lossSum / period;
    result[period] = _rsiValue(avgGain, avgLoss);

    for (int i = period + 1; i < length; i++) {
      final double diff = values[i] - values[i - 1];
      final double gain = diff > 0 ? diff : 0;
      final double loss = diff > 0 ? 0 : -diff;
      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;
      result[i] = _rsiValue(avgGain, avgLoss);
    }
    return result;
  }

  static double _rsiValue(double avgGain, double avgLoss) {
    double rsi;
    if (avgLoss == 0) {
      rsi = 100;
    } else if (avgGain == 0) {
      rsi = 0;
    } else {
      final double relativeStrengthRatio = avgGain / avgLoss;
      rsi = 100 - (100 / (1 + relativeStrengthRatio));
    }
    return (rsi * 100).round() / 100;
  }

  /// Default [VarianceFn]. Mirrors go-talib's internal `Var`, which
  /// gc-core's `BBands` transitively depends on.
  static List<double> variance(List<double> values, int period) {
    final int length = values.length;
    final List<double> result = List<double>.filled(length, 0);
    final int startIdx = period - 1;
    if (startIdx < 0 || startIdx >= length) {
      return result;
    }

    double periodTotal1 = 0;
    double periodTotal2 = 0;
    const int trailingIdx = 0;
    int i = trailingIdx;
    if (period > 1) {
      while (i < startIdx) {
        final double value = values[i];
        periodTotal1 += value;
        periodTotal2 += value * value;
        i++;
      }
    }

    int trailing = trailingIdx;
    int outIdx = startIdx;
    bool ok = true;
    while (ok) {
      final double value = values[i];
      periodTotal1 += value;
      periodTotal2 += value * value;
      final double mean1 = periodTotal1 / period;
      final double mean2 = periodTotal2 / period;
      final double trailingValue = values[trailing];
      periodTotal1 -= trailingValue;
      periodTotal2 -= trailingValue * trailingValue;
      result[outIdx] = mean2 - (mean1 * mean1);
      i++;
      trailing++;
      outIdx++;
      ok = i < length;
    }
    return result;
  }

  static const double _epsilon = 0.00000000000001;

  /// Default [SqrtFn]. Mirrors go-talib's internal `StdDev`, which
  /// gc-core's `BBands` transitively depends on.
  static List<double> sqrtOf(List<double> values, int period, double nbDev) {
    final List<double> varianceValues = variance(values, period);
    final List<double> result = List<double>.filled(values.length, 0);
    for (int i = 0; i < values.length; i++) {
      final double value = varianceValues[i];
      if (!(value < _epsilon)) {
        result[i] = nbDev != 1.0 ? math.sqrt(value) * nbDev : math.sqrt(value);
      } else {
        result[i] = 0;
      }
    }
    return result;
  }

  /// Default [TrueRangeFn]. Mirrors go-talib's internal `TRange`, which
  /// gc-core's `Atr` transitively depends on.
  static List<double> trueRange(List<double> high, List<double> low, List<double> close) {
    final int length = close.length;
    final List<double> result = List<double>.filled(length, 0);
    for (int today = 1; today < length; today++) {
      final double todayLow = low[today];
      final double todayHigh = high[today];
      final double previousClose = close[today - 1];

      double greatest = todayHigh - todayLow;
      final double highMinusClose = (previousClose - todayHigh).abs();
      if (highMinusClose > greatest) {
        greatest = highMinusClose;
      }
      final double closeMinusLow = (previousClose - todayLow).abs();
      if (closeMinusLow > greatest) {
        greatest = closeMinusLow;
      }
      result[today] = greatest;
    }
    return result;
  }

  /// Default [AverageTrueRangeFn]. Matches gc-core's `Atr` (a
  /// pass-through to `talib.Atr`).
  static List<double> averageTrueRange(
    List<double> high,
    List<double> low,
    List<double> close,
    int period,
  ) {
    final int length = close.length;
    final List<double> result = List<double>.filled(length, 0);
    if (period < 1) {
      return result;
    }
    if (period <= 1) {
      return trueRange(high, low, close);
    }
    if (length <= period) {
      return result;
    }

    final List<double> tr = trueRange(high, low, close);
    final List<double> seed = windowedAverage(tr, period);
    double prevAtr = seed[period];
    result[period] = prevAtr;

    int today = period + 1;
    for (int outIdx = period + 1; outIdx < length; outIdx++) {
      prevAtr = ((prevAtr * (period - 1)) + tr[today]) / period;
      result[outIdx] = prevAtr;
      today++;
    }
    return result;
  }

  /// Default [BandOffsetFn]: purely elementwise, no lookback of its own.
  static List<double> bandOffset(
    List<double> middle,
    List<double> deviation,
    double k,
    double sign,
  ) => List<double>.generate(middle.length, (int i) => middle[i] + (sign * deviation[i] * k));
}

/// Global registry of the *default* bulk math function used by each
/// indicator "shape" when a specific instance does not supply its own
/// override via constructor injection.
///
/// There is deliberately no registry for per-bar scalar math: gc-core (and
/// go-talib before it) only ever exposes batch, whole-series functions, so a
/// native/wasm binding can only ever back the bulk path. The scalar per-bar
/// formulas used by each indicator's `calculate()` are permanently pure
/// Dart.
///
/// This is the single place a consumer (e.g. an app wiring in a go-wasm
/// binary) flips to change bulk math package-wide without touching every
/// indicator construction call site:
/// ```dart
/// IndicatorMathRegistry.windowedAverage = wasmWindowedAverage;
/// ```
///
/// Each indicator resolves `myOverride ?? IndicatorMathRegistry.xxx` once, at
/// construction time. Changing a registry field only affects indicators
/// constructed afterwards — instances already built keep using whatever was
/// the default when they were constructed.
abstract final class IndicatorMathRegistry {
  /// Default math for [WindowedAverageFn]-shaped bulk computation (e.g.
  /// SMA's `calculateValues()`).
  static WindowedAverageFn windowedAverage = DefaultIndicatorMath.windowedAverage;

  /// Default math for [ExponentialSmoothingFn]-shaped bulk computation
  /// (e.g. EMA/MMA's `calculateValues()`).
  static ExponentialSmoothingFn exponentialSmoothing =
      DefaultIndicatorMath.exponentialSmoothing;

  /// Default math for [RelativeStrengthFn]-shaped bulk computation (e.g.
  /// RSI's `calculateValues()`).
  static RelativeStrengthFn relativeStrength = DefaultIndicatorMath.relativeStrength;

  /// Default math for [VarianceFn]-shaped bulk computation.
  static VarianceFn variance = DefaultIndicatorMath.variance;

  /// Default math for [SqrtFn]-shaped bulk computation (e.g. Standard
  /// Deviation's `calculateValues()`).
  static SqrtFn sqrtOf = DefaultIndicatorMath.sqrtOf;

  /// Default math for [TrueRangeFn]-shaped bulk computation.
  static TrueRangeFn trueRange = DefaultIndicatorMath.trueRange;

  /// Default math for [AverageTrueRangeFn]-shaped bulk computation (e.g.
  /// ATR's `calculateValues()`).
  static AverageTrueRangeFn averageTrueRange = DefaultIndicatorMath.averageTrueRange;

  /// Default math for [BandOffsetFn]-shaped bulk computation (e.g.
  /// Bollinger Bands' `calculateValues()`).
  static BandOffsetFn bandOffset = DefaultIndicatorMath.bandOffset;

  /// Resets every field to its pure-Dart default. Call in `tearDown` when
  /// tests mutate the registry, to avoid leaking state across tests.
  static void resetToDefaults() {
    windowedAverage = DefaultIndicatorMath.windowedAverage;
    exponentialSmoothing = DefaultIndicatorMath.exponentialSmoothing;
    relativeStrength = DefaultIndicatorMath.relativeStrength;
    variance = DefaultIndicatorMath.variance;
    sqrtOf = DefaultIndicatorMath.sqrtOf;
    trueRange = DefaultIndicatorMath.trueRange;
    averageTrueRange = DefaultIndicatorMath.averageTrueRange;
    bandOffset = DefaultIndicatorMath.bandOffset;
  }
}
