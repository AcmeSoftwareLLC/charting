import 'package:acme_indicators/acme_indicators.dart';

/// A [CachedIndicator] that computes its values by calling an externally
/// supplied bulk math function, instead of an acme_indicators calculation.
class FunctionIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Initializes.
  ///
  /// [indicator] the source indicator this is computed from.
  /// [compute] receives this indicator's raw OHLC bars and [indicator]'s
  /// per-bar quote series, and returns the full computed series.
  FunctionIndicator(this._source, this._compute) : super.fromIndicator(_source);

  final Indicator<T> _source;

  final List<double> Function(List<IndicatorOHLC> bars, List<double> values)
  _compute;

  @override
  T calculate(int index) => throw UnimplementedError(
    'FunctionIndicator only supports bulk calculateValues(); '
    'it has no per-bar implementation.',
  );

  @override
  List<T> calculateValues() =>
      applyBulkValues(_compute(entries, seriesFrom(_source)));
}
