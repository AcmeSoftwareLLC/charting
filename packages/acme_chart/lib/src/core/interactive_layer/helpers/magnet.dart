import 'package:material_ui/material_ui.dart';

import '../../../models/candle.dart';
import '../../../models/tick.dart';
import '../../chart/data_visualization/chart_data.dart';
import '../crosshair/find.dart';

/// Snaps [position] onto the nearest OHLC point of the candle under it,
/// mirroring ChartIQ's `magnetize()`.
///
/// The x moves to the candle's own x, the y to whichever of its open / high /
/// low / close is nearest *in pixels* — nearest on screen, not in price, so it
/// matches what the user is aiming at on a scaled axis. There is no distance
/// threshold: with the magnet on, every point lands on an OHLC value. For a
/// line series the tick's single quote is the only candidate.
///
/// Returns `null` when no candle is under [position] — before the first entry
/// or past the last, including the empty space right of the latest candle — so
/// the caller can keep the pointer position *and* paint no magnet dot.
Offset? magnetizedPosition(
  Offset position, {
  required List<Tick> entries,
  required EpochFromX epochFromX,
  required EpochToX epochToX,
  required QuoteToY quoteToY,
}) {
  if (entries.isEmpty) {
    return null;
  }

  final double index = findEpochIndex(epochFromX(position.dx), entries);
  if (index < 0 || index > entries.length - 1) {
    return null;
  }

  final Tick tick = entries[index.round()];

  final List<double> quotes = tick is Candle
      ? <double>[tick.open, tick.high, tick.low, tick.close]
      : <double>[tick.quote];

  double snappedQuote = quotes.first;
  double snappedDistance = double.infinity;

  for (final double quote in quotes) {
    final double distance = (quoteToY(quote) - position.dy).abs();
    if (distance < snappedDistance) {
      snappedDistance = distance;
      snappedQuote = quote;
    }
  }

  return Offset(epochToX(tick.epoch), quoteToY(snappedQuote));
}
