import 'indicator_math_functions.dart';

/// Global registry of an optional *secondary* override for each indicator "shape"'s bulk math, used when a specific instance does not supply its own override via constructor injection.
///
/// ```dart
/// IndicatorMathRegistry.sma = myFastSma;
/// ```
///
/// Each indicator resolves `myOverride ?? IndicatorMathRegistry.xxx` once, at construction time. When neither is set, the indicator doesn't override `calculateValues()` and values are computed one at a time via `calculate()` instead.
abstract final class IndicatorMathRegistry {
  /// Secondary override for [SmaFn]-shaped bulk computation (e.g. SMA's `calculateValues()`).
  static SmaFn? sma;

  /// Secondary override for [EmaFn]-shaped bulk computation (e.g. EMA/MMA's `calculateValues()`).
  static EmaFn? ema;

  /// Secondary override for [RsiFn]-shaped bulk computation (e.g. RSI's `calculateValues()`).
  static RsiFn? rsi;

  /// Secondary override for [VarianceFn]-shaped bulk computation.
  static VarianceFn? variance;

  /// Secondary override for [SqrtFn]-shaped bulk computation (e.g. Standard Deviation's `calculateValues()`).
  static SqrtFn? sqrtOf;

  /// Secondary override for [TrueRangeFn]-shaped bulk computation.
  static TrueRangeFn? trueRange;

  /// Secondary override for [AtrFn]-shaped bulk computation (e.g. ATR's `calculateValues()`).
  static AtrFn? atr;

  /// Secondary override for [BandOffsetFn]-shaped bulk computation (e.g. Bollinger Bands' `calculateValues()`).
  static BandOffsetFn? bandOffset;

  /// Secondary override for [MacdFn]-shaped bulk computation (e.g. MACD's signal line).
  static MacdFn? macd;

  /// Secondary override for [PivotPointsFn]-shaped bulk computation, shared
  /// by `PivotPointIndicator` and the six R1–R3/S1–S3 level indicators —
  /// each just extracts its own field from the one computed [PivotPointsResult].
  static PivotPointsFn? pivotPoints;

  /// Secondary override for [PeakValleyFn]-shaped bulk computation, shared
  /// by `PeakIndicator`, `ValleyIndicator`, `PreviousPeakIndicator` and
  /// `PreviousValleyIndicator` — each just extracts its own field from the
  /// one computed [PeakValleyResult].
  static PeakValleyFn? peakValley;

  /// Clears every field back to unset; call in `tearDown` when tests mutate the registry.
  static void resetToDefaults() {
    sma = null;
    ema = null;
    rsi = null;
    variance = null;
    sqrtOf = null;
    trueRange = null;
    atr = null;
    bandOffset = null;
    macd = null;
    pivotPoints = null;
    peakValley = null;
  }
}
