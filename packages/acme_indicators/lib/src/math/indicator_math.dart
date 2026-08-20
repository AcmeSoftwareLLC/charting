import 'indicator_math_functions.dart';

/// Global registry of an optional *secondary* override for each indicator "shape"'s bulk math, used when a specific instance does not supply its own override via constructor injection.
///
/// ```dart
/// IndicatorMathRegistry.windowedAverage = myFastWindowedAverage;
/// ```
///
/// Each indicator resolves `myOverride ?? IndicatorMathRegistry.xxx` once, at construction time. When neither is set, the indicator doesn't override `calculateValues()` and values are computed one at a time via `calculate()` instead.
abstract final class IndicatorMathRegistry {
  /// Secondary override for [WindowedAverageFn]-shaped bulk computation (e.g. SMA's `calculateValues()`).
  static WindowedAverageFn? windowedAverage;

  /// Secondary override for [EmaFn]-shaped bulk computation (e.g. EMA/MMA's `calculateValues()`).
  static EmaFn? ema;

  /// Secondary override for [RelativeStrengthFn]-shaped bulk computation (e.g. RSI's `calculateValues()`).
  static RelativeStrengthFn? relativeStrength;

  /// Secondary override for [VarianceFn]-shaped bulk computation.
  static VarianceFn? variance;

  /// Secondary override for [SqrtFn]-shaped bulk computation (e.g. Standard Deviation's `calculateValues()`).
  static SqrtFn? sqrtOf;

  /// Secondary override for [TrueRangeFn]-shaped bulk computation.
  static TrueRangeFn? trueRange;

  /// Secondary override for [AverageTrueRangeFn]-shaped bulk computation (e.g. ATR's `calculateValues()`).
  static AverageTrueRangeFn? averageTrueRange;

  /// Secondary override for [BandOffsetFn]-shaped bulk computation (e.g. Bollinger Bands' `calculateValues()`).
  static BandOffsetFn? bandOffset;

  /// Secondary override for [MacdFn]-shaped bulk computation (e.g. MACD's signal line).
  static MacdFn? macd;

  /// Clears every field back to unset; call in `tearDown` when tests mutate the registry.
  static void resetToDefaults() {
    windowedAverage = null;
    ema = null;
    relativeStrength = null;
    variance = null;
    sqrtOf = null;
    trueRange = null;
    averageTrueRange = null;
    bandOffset = null;
    macd = null;
  }
}
