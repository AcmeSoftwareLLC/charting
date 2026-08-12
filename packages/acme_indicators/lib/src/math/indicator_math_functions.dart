/// Typedefs mirroring gc-core's `pkg/indicators` function shapes
/// (whole-series in, whole-series out), so a future FFI/WASM binding built
/// from that Go package is close to a drop-in implementation. These back
/// `calculateValues()`'s bulk computation, not the per-bar `calculate()`
/// path — gc-core (and go-talib before it) only ever exposes batch,
/// whole-series functions, so `calculate()`'s formulas stay inline and
/// permanently pure Dart.
library;

/// Windowed average shape, used by SMA. Matches gc-core's `Sma` (a
/// pass-through to `talib.Sma`): the first `period - 1` entries of the
/// returned list are `0` (an invalid/lookback region), not a partial-window
/// average.
typedef WindowedAverageFn = List<double> Function(List<double> values, int period);

/// Exponential-smoothing shape, shared by EMA and MMA. Matches gc-core's
/// `Ema` (a pass-through to `talib.Ema`) when [multiplier] is `2 / (period +
/// 1)`; the same recursive shape backs Wilder/MMA smoothing when
/// [multiplier] is `1 / period`. The first `period - 1` entries are `0`; the
/// seed at index `period - 1` is the plain average of the first [period]
/// values, then the recursion continues from there.
typedef ExponentialSmoothingFn =
    List<double> Function(List<double> values, int period, double multiplier);

/// RSI shape. Matches gc-core's custom `Rsi` exactly: Wilder-smoothed
/// gain/loss averages, but ties resolve `avgLoss == 0 -> 100` before
/// `avgGain == 0 -> 0` (the opposite tie order from plain talib), and each
/// value is rounded to 2 decimal places. The first `period` entries are `0`.
typedef RelativeStrengthFn = List<double> Function(List<double> values, int period);

/// Population variance shape, used internally by Bollinger Bands' deviation
/// band (mirrors go-talib's internal `Var`, which gc-core's `BBands`
/// transitively depends on but does not re-expose separately). The first
/// `period - 1` entries are `0`.
typedef VarianceFn = List<double> Function(List<double> values, int period);

/// Standard-deviation shape: `sqrt(variance) * nbDev`, with a near-zero
/// variance clamped to `0` (mirrors go-talib's internal `StdDev`, which
/// gc-core's `BBands` transitively depends on but does not re-expose
/// separately).
typedef SqrtFn = List<double> Function(List<double> values, int period, double nbDev);

/// True-range shape (mirrors go-talib's internal `TRange`, which gc-core's
/// `Atr` transitively depends on but does not re-expose separately). Index
/// `0` is `0` (no previous close to compare against).
typedef TrueRangeFn =
    List<double> Function(List<double> high, List<double> low, List<double> close);

/// Average-true-range shape. Matches gc-core's `Atr` (a pass-through to
/// `talib.Atr`): Wilder-smoothed true range, seeded from the SMA of the true
/// range values immediately after the first (invalid) entry. The first
/// `period` entries are `0`.
typedef AverageTrueRangeFn =
    List<double> Function(List<double> high, List<double> low, List<double> close, int period);

/// Bollinger's band-offset shape, applied elementwise across already-computed
/// middle/deviation arrays: `middle[i] + (sign * deviation[i] * k)`. [sign]
/// is `1` for the upper band and `-1` for the lower band. Purely elementwise
/// — no lookback/window of its own.
typedef BandOffsetFn =
    List<double> Function(List<double> middle, List<double> deviation, double k, double sign);
