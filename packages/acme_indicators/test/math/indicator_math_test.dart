import 'package:acme_indicators/src/math/indicator_math.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultIndicatorMath.windowedAverage', () {
    test('zero-fills the lookback region and averages the window after it', () {
      final List<double> result = DefaultIndicatorMath.windowedAverage(
        <double>[1, 2, 3, 4, 5],
        3,
      );

      expect(result, <double>[0, 0, 2, 3, 4]);
    });
  });

  group('DefaultIndicatorMath.exponentialSmoothing', () {
    test('seeds via the SMA of the first `period` values, then recurses', () {
      final List<double> result = DefaultIndicatorMath.exponentialSmoothing(
        <double>[1, 2, 3, 4, 5],
        3,
        0.5,
      );

      expect(result, <double>[0, 0, 2, 3, 4]);
    });
  });

  group('DefaultIndicatorMath.relativeStrength', () {
    test('matches gc-core Rsi exactly, including the tie-break order', () {
      final List<double> result = DefaultIndicatorMath.relativeStrength(
        <double>[1, 2, 1, 2, 3],
        2,
      );

      expect(result, <double>[0, 0, 50, 75, 87.5]);
    });

    test('a fully flat window resolves to 100, not 0', () {
      final List<double> result = DefaultIndicatorMath.relativeStrength(
        <double>[5, 5, 5, 5],
        2,
      );

      expect(result[2], 100);
    });
  });

  group('DefaultIndicatorMath.variance', () {
    test('population variance of consecutive integers over a window of 3 is 2/3', () {
      final List<double> result = DefaultIndicatorMath.variance(
        <double>[1, 2, 3, 4, 5],
        3,
      );

      expect(result[0], 0);
      expect(result[1], 0);
      expect(result[2], closeTo(2 / 3, 1e-9));
      expect(result[3], closeTo(2 / 3, 1e-9));
      expect(result[4], closeTo(2 / 3, 1e-9));
    });
  });

  group('DefaultIndicatorMath.sqrtOf', () {
    test('is the square root of variance, scaled by nbDev', () {
      final List<double> result = DefaultIndicatorMath.sqrtOf(
        <double>[1, 2, 3, 4, 5],
        3,
        1.0,
      );

      expect(result[2], closeTo(0.8164965809, 1e-9));
    });
  });

  group('DefaultIndicatorMath.trueRange', () {
    test('index 0 is 0; later indices match the high/low/prevClose formula', () {
      final List<double> result = DefaultIndicatorMath.trueRange(
        <double>[10, 12, 11],
        <double>[8, 9, 9],
        <double>[9, 11, 10.5],
      );

      expect(result, <double>[0, 3, 2]);
    });
  });

  group('DefaultIndicatorMath.averageTrueRange', () {
    test('zero-fills the lookback region, seeded by the SMA of true range', () {
      final List<double> result = DefaultIndicatorMath.averageTrueRange(
        <double>[10, 12, 11],
        <double>[8, 9, 9],
        <double>[9, 11, 10.5],
        2,
      );

      expect(result, <double>[0, 0, 2.5]);
    });
  });

  group('DefaultIndicatorMath.bandOffset', () {
    test('applies middle + sign * deviation * k elementwise', () {
      final List<double> middle = <double>[10, 10, 10];
      final List<double> deviation = <double>[1, 2, 3];

      expect(
        DefaultIndicatorMath.bandOffset(middle, deviation, 2, 1),
        <double>[12, 14, 16],
      );
      expect(
        DefaultIndicatorMath.bandOffset(middle, deviation, 2, -1),
        <double>[8, 6, 4],
      );
    });
  });
}
