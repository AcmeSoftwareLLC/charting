/// Returns the epoch aligned to the start of its granularity interval.
///
/// - If [granularity] is 1000 or less (i.e. tick data), the original [epoch] is returned unchanged.
/// - If [granularity] is greater than 1000 (i.e. candles),
/// the [epoch] is snapped to the start of its granularity bucket by
/// rounding down to the nearest multiple of [granularity].
int snapEpochToGranularity(int epoch, int granularity) {
  if (granularity <= 1000) {
    return epoch;
  }
  return (epoch ~/ granularity) * granularity;
}

/// Returns the epoch aligned to the *nearest* granularity interval.
///
/// Use this instead of [snapEpochToGranularity] for an epoch that came back
/// from a pixel: `epoch -> x -> epoch` is only accurate to a millisecond
/// (`shiftEpochByPx` rounds), and a candle's epoch sits exactly on a bucket
/// boundary — so flooring a round-tripped candle epoch drops it a whole
/// bucket to the left whenever the round-trip lands low. Rounding absorbs it.
int snapEpochToNearestGranularity(int epoch, int granularity) {
  if (granularity <= 1000) {
    return epoch;
  }
  return ((epoch + granularity ~/ 2) ~/ granularity) * granularity;
}
