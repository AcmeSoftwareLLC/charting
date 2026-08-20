/// Typedefs for each pluggable bulk math shape used by `calculateValues()`; the per-bar `calculate()` path stays pure Dart and is not customizable.
library;

/// Windowed average shape, used by SMA: the first `period - 1` entries are `0` (lookback region), not a partial-window average.
typedef WindowedAverageFn = List<double> Function(List<double> values, int period);

/// Exponential-smoothing shape, shared by EMA and MMA: first `period - 1` entries are `0`; seeded at `period - 1` with the plain average of the first [period] values, then recurses with [multiplier].
typedef ExponentialSmoothingFn =
    List<double> Function(List<double> values, int period, double multiplier);

/// Wilder-smoothed RSI shape: ties resolve `avgLoss == 0 -> 100` before `avgGain == 0 -> 0`, rounded to 2 decimals; first `period` entries are `0`.
typedef RelativeStrengthFn = List<double> Function(List<double> values, int period);

/// Population variance shape, used internally by Bollinger Bands' deviation band; first `period - 1` entries are `0`.
typedef VarianceFn = List<double> Function(List<double> values, int period);

/// Standard-deviation shape: `sqrt(variance) * nbDev`, with a near-zero variance clamped to `0`.
typedef SqrtFn = List<double> Function(List<double> values, int period, double nbDev);

/// True-range shape: index `0` is `0` (no previous close to compare against).
typedef TrueRangeFn =
    List<double> Function(List<double> high, List<double> low, List<double> close);

/// Average-true-range shape: Wilder-smoothed true range, seeded from the SMA of the true range values immediately after the first (invalid) entry; first `period` entries are `0`.
typedef AverageTrueRangeFn =
    List<double> Function(List<double> high, List<double> low, List<double> close, int period);

/// Bollinger's band-offset shape, applied elementwise: `middle[i] + (sign * deviation[i] * k)`, where [sign] is `1` for the upper band and `-1` for the lower band.
typedef BandOffsetFn =
    List<double> Function(List<double> middle, List<double> deviation, double k, double sign);
