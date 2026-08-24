import '../models/models.dart';
import 'indicator.dart';

/// Calculates and keeps the result of indicator calculation values in [results].
/// And decides when to calculate indicator's value for an index.
// TODO(Ramin): Later if we require a level of caching can be added here. Right now it calculates indicator for the entire list.
abstract class CachedIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  CachedIndicator(super.input)
    : results = List<T>.empty(growable: true),
      lastResultIndex = 0 {
    _growResultsForIndex(entries.length - 1);
  }

  /// Initializes from another [Indicator]
  CachedIndicator.fromIndicator(Indicator<T> indicator) : this(indicator.input);

  /// Index of the last result that is calculated.
  int lastResultIndex;

  // TODO(NA): Can be overridden on those indicators that can calculate
  //  results for their entire list at once in a more optimal way.
  /// Calculates indicator's result for all [entries] and caches them.
  List<T> calculateValues() => _calculateValuesPerBar();

  List<T> _calculateValuesPerBar() {
    for (int i = 0; i < entries.length; i++) {
      getValue(i);
    }
    return results;
  }

  /// Copies the result of [other] as its own.
  void copyValuesFrom(covariant CachedIndicator<T> other) {
    if (!identical(this, other)) {
      results
        ..clear()
        ..addAll(other.results);
      lastResultIndex = other.lastResultIndex;
    }
  }

  /// List of cached result.
  final List<T> results;

  @override
  T getValue(int index) {
    _growResultsForIndex(index);

    if (results[index].quote.isInfinite) {
      final T result = calculate(index);
      if (!result.quote.isInfinite) {
        results[index] = result;
      } else {
        // Avoid falling into a loop, if by any chance an indicator calculates a value as `double.infinity`.
        results[index] = createResult(quote: double.nan, index: index);
      }
    }

    if (index > lastResultIndex) {
      lastResultIndex = index;
    }

    return results[index];
  }

  /// Grows the results list with null elements to cover the given [index].
  ///
  /// Returns number of elements that have been added to the results list.
  int _growResultsForIndex(int index) {
    final int oldResultsCount = results.length;

    if (index > oldResultsCount - 1) {
      results.addAll(
        List<T>.filled(
          index - oldResultsCount + 1,
          createResult(quote: double.infinity, index: index),
        ),
      );
    }

    return results.length - oldResultsCount;
  }

  /// Calculates the value of this indicator for the given [index] without caching it.
  ///
  /// Returns the result as a [T].
  T calculate(int index);

  /// Invalidates a calculated indicator value for [index]
  void invalidate(int index) {
    _growResultsForIndex(index);
    results[index] = createResult(quote: double.infinity, index: index);
  }

  /// Recalculates indicator's value for the give [index] and caches it.
  ///
  /// Returns the result as a [T].
  T refreshValueFor(int index) {
    invalidate(index);
    return getValue(index);
  }

  /// Primes [indicator] (if it bulk-caches its own values) and returns its
  /// per-bar quote series across [entries].
  ///
  /// Intended for use by bulk-math [calculateValues] overrides that need a
  /// child indicator's values as a plain `List<double>`.
  List<double> seriesFrom(Indicator<T> indicator) {
    if (indicator is CachedIndicator<T>) {
      indicator.calculateValues();
    }
    return <double>[
      for (int i = 0; i < entries.length; i++) indicator.getValue(i).quote,
    ];
  }

  /// Writes a bulk-computed [values] list into [results] and marks every
  /// entry calculated. Returns [results], matching [calculateValues]'s contract.
  ///
  /// Intended as the common tail of bulk-math [calculateValues] overrides.
  List<T> applyBulkValues(List<double> values) {
    for (int i = 0; i < entries.length; i++) {
      results[i] = createResult(index: i, quote: values[i]);
    }
    lastResultIndex = entries.length - 1;
    return results;
  }

  /// Runs [compute] with [fn] and applies the result via [applyBulkValues]
  /// when [fn] is non-null; otherwise falls back to the default per-bar
  /// [calculateValues].
  ///
  /// Intended as the common body of bulk-math [calculateValues] overrides:
  /// `calculateValues() => calculateValuesWith(_sma, (sma) => sma(seriesFrom(indicator), period));`
  List<T> calculateValuesWith<F>(F? fn, List<double> Function(F fn) compute) {
    if (fn == null) {
      return _calculateValuesPerBar();
    }
    return applyBulkValues(compute(fn));
  }
}
