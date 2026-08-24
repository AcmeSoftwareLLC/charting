import 'package:acme_indicators/src/indicators/calculations/atr_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/ema_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:acme_indicators/src/indicators/external/keltner/keltner_channel_upper_indicator.dart';
import 'package:acme_indicators/src/indicators/external/peak_valley/peak_indicator.dart';
import 'package:acme_indicators/src/indicators/external/peak_valley/previous_peak_indicator.dart';
import 'package:acme_indicators/src/indicators/external/pivot/pivot_point_indicator.dart';
import 'package:acme_indicators/src/indicators/external/pivot/pivot_r1_indicator.dart';
import 'package:acme_indicators/src/math/indicator_math.dart';
import 'package:acme_indicators/src/math/indicator_math_functions.dart';
import 'package:test/test.dart';

import '../indicators/mock_models.dart';

void main() {
  final List<MockTick> ticks = List<MockTick>.generate(
    5,
    (int i) => MockTick(epoch: i, quote: (i + 1).toDouble()),
  );

  tearDown(IndicatorMathRegistry.resetToDefaults);

  group('Without an injected function', () {
    test('KeltnerChannelUpperIndicator.getValue throws UnimplementedError', () {
      final CloseValueIndicator<MockResult> source =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final KeltnerChannelUpperIndicator<MockResult> keltner =
          KeltnerChannelUpperIndicator<MockResult>(
        EMAIndicator<MockResult>(source, 3),
        ATRIndicator<MockResult>(MockInput(ticks)),
      );

      expect(() => keltner.getValue(0), throwsUnimplementedError);
    });

    test('PivotPointIndicator.getValue throws UnimplementedError', () {
      final PivotPointIndicator<MockResult> pivot =
          PivotPointIndicator<MockResult>(MockInput(ticks));

      expect(() => pivot.getValue(0), throwsUnimplementedError);
    });

    test('PeakIndicator.getValue throws UnimplementedError', () {
      final PeakIndicator<MockResult> peak =
          PeakIndicator<MockResult>(MockInput(ticks));

      expect(() => peak.getValue(0), throwsUnimplementedError);
    });
  });

  group('Per-instance math override', () {
    test('KeltnerChannelUpperIndicator.calculateValues uses the injected bandOffset', () {
      final CloseValueIndicator<MockResult> source =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final KeltnerChannelUpperIndicator<MockResult> keltner =
          KeltnerChannelUpperIndicator<MockResult>(
        EMAIndicator<MockResult>(source, 3),
        ATRIndicator<MockResult>(MockInput(ticks)),
        bandOffset: (
          List<double> middle,
          List<double> deviation,
          double k,
          double sign,
        ) => List<double>.filled(middle.length, 21),
      );

      expect(
        keltner.calculateValues().map((MockResult r) => r.quote),
        everyElement(21),
      );
    });

    PivotPointsResult fakePivotPoints(
      List<double> highs,
      List<double> lows,
      List<double> closes,
    ) => PivotPointsResult(
      pivot: List<double>.filled(highs.length, 5),
      r1: List<double>.filled(highs.length, 9),
      r2: List<double>.filled(highs.length, 10),
      r3: List<double>.filled(highs.length, 11),
      s1: List<double>.filled(highs.length, 1),
      s2: List<double>.filled(highs.length, 2),
      s3: List<double>.filled(highs.length, 3),
    );

    test('PivotPointIndicator.calculateValues extracts .pivot from the injected function', () {
      final PivotPointIndicator<MockResult> pivot = PivotPointIndicator<MockResult>(
        MockInput(ticks),
        pivotPoints: fakePivotPoints,
      );

      expect(pivot.calculateValues().map((MockResult r) => r.quote), everyElement(5));
    });

    test('PivotR1Indicator.calculateValues extracts .r1 from the same injected function', () {
      final PivotR1Indicator<MockResult> r1 = PivotR1Indicator<MockResult>(
        MockInput(ticks),
        pivotPoints: fakePivotPoints,
      );

      expect(r1.calculateValues().map((MockResult r) => r.quote), everyElement(9));
    });

    PeakValleyResult fakePeakValley(List<double> highs, List<double> lows, int strength) =>
        PeakValleyResult(
          isPeak: List<double>.filled(highs.length, 1),
          isValley: List<double>.filled(highs.length, 0),
          previousPeak: List<double>.filled(highs.length, 3),
          previousValley: List<double>.filled(highs.length, 4),
        );

    test('PeakIndicator.calculateValues extracts .isPeak from the injected function', () {
      final PeakIndicator<MockResult> peak = PeakIndicator<MockResult>(
        MockInput(ticks),
        peakValley: fakePeakValley,
      );

      expect(peak.calculateValues().map((MockResult r) => r.quote), everyElement(1));
    });

    test(
      'PreviousPeakIndicator.calculateValues extracts .previousPeak from the same '
      'injected function',
      () {
        final PreviousPeakIndicator<MockResult> previousPeak =
            PreviousPeakIndicator<MockResult>(
          MockInput(ticks),
          peakValley: fakePeakValley,
        );

        expect(
          previousPeak.calculateValues().map((MockResult r) => r.quote),
          everyElement(3),
        );
      },
    );
  });

  group('Registry-level default override', () {
    test(
      'setting IndicatorMathRegistry.bandOffset affects Keltner instances '
      'built afterwards without a per-instance override',
      () {
        IndicatorMathRegistry.bandOffset = (
          List<double> middle,
          List<double> deviation,
          double k,
          double sign,
        ) => List<double>.filled(middle.length, -1);

        final CloseValueIndicator<MockResult> source =
            CloseValueIndicator<MockResult>(MockInput(ticks));
        final KeltnerChannelUpperIndicator<MockResult> keltner =
            KeltnerChannelUpperIndicator<MockResult>(
          EMAIndicator<MockResult>(source, 3),
          ATRIndicator<MockResult>(MockInput(ticks)),
        );

        expect(
          keltner.calculateValues().map((MockResult r) => r.quote),
          everyElement(-1),
        );
      },
    );

    test('resetToDefaults clears the override, falling back to UnimplementedError', () {
      IndicatorMathRegistry.pivotPoints = (
        List<double> highs,
        List<double> lows,
        List<double> closes,
      ) => PivotPointsResult(
        pivot: List<double>.filled(highs.length, -999),
        r1: List<double>.filled(highs.length, -999),
        r2: List<double>.filled(highs.length, -999),
        r3: List<double>.filled(highs.length, -999),
        s1: List<double>.filled(highs.length, -999),
        s2: List<double>.filled(highs.length, -999),
        s3: List<double>.filled(highs.length, -999),
      );
      IndicatorMathRegistry.resetToDefaults();

      final PivotPointIndicator<MockResult> pivot =
          PivotPointIndicator<MockResult>(MockInput(ticks));

      expect(() => pivot.getValue(0), throwsUnimplementedError);
    });
  });
}
