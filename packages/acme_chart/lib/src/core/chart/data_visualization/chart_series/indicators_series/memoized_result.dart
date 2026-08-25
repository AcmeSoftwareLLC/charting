import 'package:acme_indicators/acme_indicators.dart';

/// Runs a multi-output bulk computation at most once, caching the result so
/// multiple [FunctionIndicator]s that each need one field of the same
/// underlying call (e.g. Bollinger's upper/middle/lower, or MACD's
/// macd/signal lines) share a single computation instead of repeating it.
///
/// Create one instance per indicator *group* (i.e. per `Series` built from
/// `IndicatorConfig.getSeries()`/`createPainter()`), not per line, and
/// capture it in each line's [FunctionIndicator] closure.
class MemoizedResult<R> {
  /// Initializes.
  MemoizedResult(this._compute);

  final R Function(List<IndicatorOHLC> bars, List<double> values) _compute;

  R? _cached;

  /// Returns the cached result, computing it via [_compute] on first call.
  R call(List<IndicatorOHLC> bars, List<double> values) =>
      _cached ??= _compute(bars, values);
}
