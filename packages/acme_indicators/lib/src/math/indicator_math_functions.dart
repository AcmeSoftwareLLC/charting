/// Typedefs for each pluggable bulk math shape used by `calculateValues()`; the per-bar `calculate()` path stays pure Dart and is not customizable.
library;

import '../models/models.dart';

/// Convenience accessors for pulling raw OHLC series out of a bar list, for
/// bulk math shapes (like [AtrFn] and [TrueRangeFn]) that take them directly.
extension IndicatorOHLCSeriesX on List<IndicatorOHLC> {
  /// The `high` field of every bar, in order.
  List<double> get highs => <double>[for (final IndicatorOHLC e in this) e.high];

  /// The `low` field of every bar, in order.
  List<double> get lows => <double>[for (final IndicatorOHLC e in this) e.low];

  /// The `close` field of every bar, in order.
  List<double> get closes => <double>[for (final IndicatorOHLC e in this) e.close];
}

/// Windowed average shape, used by SMA: the first `period - 1` entries are `0` (lookback region), not a partial-window average.
typedef SmaFn = List<double> Function(List<double> values, int period);

/// Exponential-smoothing shape, shared by EMA and MMA: first `period - 1` entries are `0`; seeded at `period - 1` with the plain average of the first [period] values, then recurses with [multiplier].
typedef EmaFn = List<double> Function(List<double> values, int period, double multiplier);

/// Wilder-smoothed RSI shape: ties resolve `avgLoss == 0 -> 100` before `avgGain == 0 -> 0`, rounded to 2 decimals; first `period` entries are `0`.
typedef RsiFn = List<double> Function(List<double> values, int period);

/// Population variance shape, used internally by Bollinger Bands' deviation band; first `period - 1` entries are `0`.
typedef VarianceFn = List<double> Function(List<double> values, int period);

/// Standard-deviation shape: `sqrt(variance) * nbDev`, with a near-zero variance clamped to `0`.
typedef SqrtFn = List<double> Function(List<double> values, int period, double nbDev);

/// True-range shape: index `0` is `0` (no previous close to compare against).
typedef TrueRangeFn =
    List<double> Function(List<double> high, List<double> low, List<double> close);

/// Average-true-range shape: Wilder-smoothed true range, seeded from the SMA of the true range values immediately after the first (invalid) entry; first `period` entries are `0`.
typedef AtrFn =
    List<double> Function(List<double> high, List<double> low, List<double> close, int period);

/// Bollinger's band-offset shape, applied elementwise: `middle[i] + (sign * deviation[i] * k)`, where [sign] is `1` for the upper band and `-1` for the lower band.
typedef BandOffsetFn =
    List<double> Function(List<double> middle, List<double> deviation, double k, double sign);

/// Result of a [MacdFn] computation: both lines are full-length, zero-filled
/// before their own warm-up, matching the convention every other bulk math
/// shape in this file uses.
class MacdResult {
  /// Creates a [MacdResult].
  const MacdResult({required this.macdVals, required this.signalVals});

  /// The MACD line: `fastEma - slowEma`. Entries before `slowPeriod - 1` are `0`.
  final List<double> macdVals;

  /// The signal line: an EMA of [macdVals] taken over its valid (non-zero)
  /// range only, not the zero-padded prefix. Entries before the signal EMA
  /// has warmed up are `0`.
  final List<double> signalVals;
}

/// MACD shape: fast/slow EMA diff plus its signal line, computed together so
/// the signal line's own warm-up starts from the MACD line's valid range
/// rather than being biased by its zero-padded prefix.
typedef MacdFn =
    MacdResult Function(List<double> values, int fastPeriod, int slowPeriod, int signalPeriod);

/// Result of a [PivotPointsFn] computation: every level is full-length,
/// computed together in one pass over the same high/low/close series.
class PivotPointsResult {
  /// Creates a [PivotPointsResult].
  const PivotPointsResult({
    required this.pivot,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.s1,
    required this.s2,
    required this.s3,
  });

  /// The classic pivot line: `(high + low + close) / 3`.
  final List<double> pivot;

  /// First resistance level: `(2 * pivot) - low`.
  final List<double> r1;

  /// Second resistance level: `pivot + (high - low)`.
  final List<double> r2;

  /// Third resistance level: `high + 2 * (pivot - low)`.
  final List<double> r3;

  /// First support level: `(2 * pivot) - high`.
  final List<double> s1;

  /// Second support level: `pivot - (high - low)`.
  final List<double> s2;

  /// Third support level: `low - 2 * (high - pivot)`.
  final List<double> s3;
}

/// Pivot-points shape: the classic pivot line plus all six R1–R3/S1–S3
/// support/resistance levels, computed together from the same (typically
/// previous-period) high/low/close series.
typedef PivotPointsFn =
    PivotPointsResult Function(List<double> highs, List<double> lows, List<double> closes);

/// Result of a [PeakValleyFn] computation: every series is full-length,
/// computed together in one pass.
class PeakValleyResult {
  /// Creates a [PeakValleyResult].
  const PeakValleyResult({
    required this.isPeak,
    required this.isValley,
    required this.previousPeak,
    required this.previousValley,
  });

  /// `1` where the bar is a confirmed fractal swing high, `0` otherwise.
  final List<double> isPeak;

  /// `1` where the bar is a confirmed fractal swing low, `0` otherwise.
  final List<double> isValley;

  /// The most recent confirmed peak value, carried forward until a newer
  /// one is found.
  final List<double> previousPeak;

  /// The most recent confirmed valley value, carried forward until a newer
  /// one is found.
  final List<double> previousValley;
}

/// Fractal swing-point shape: peak/valley flags on highs/lows plus their
/// carried-forward previous values, computed together.
typedef PeakValleyFn =
    PeakValleyResult Function(List<double> highs, List<double> lows, int strength);
