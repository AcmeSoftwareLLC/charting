import 'package:acme_indicators/src/indicators/calculations/ema_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:acme_indicators/src/indicators/calculations/rsi_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/sma_indicator.dart';
import 'package:acme_indicators/src/math/indicator_math.dart';
import 'package:test/test.dart';

import '../indicators/mock_models.dart';

void main() {
  final List<MockTick> ticks = List<MockTick>.generate(
    5,
    (int i) => MockTick(epoch: i, quote: (i + 1).toDouble()),
  );

  tearDown(IndicatorMathRegistry.resetToDefaults);

  group('Per-instance math override', () {
    test('SMAIndicator.calculateValues uses the injected windowedAverage', () {
      bool wasCalled = false;
      List<double> fakeWindowedAverage(List<double> values, int period) {
        wasCalled = true;
        return List<double>.filled(values.length, 42);
      }

      final SMAIndicator<MockResult> sma = SMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
        windowedAverage: fakeWindowedAverage,
      );

      expect(sma.calculateValues().map((MockResult r) => r.quote), everyElement(42));
      expect(wasCalled, isTrue);
    });

    test('RSIIndicator.calculateValues uses the injected relativeStrength', () {
      final RSIIndicator<MockResult> rsi = RSIIndicator<MockResult>.fromIndicator(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
        relativeStrength: (List<double> values, int period) =>
            List<double>.filled(values.length, 7),
      );

      expect(rsi.calculateValues().map((MockResult r) => r.quote), everyElement(7));
    });

    test('EMAIndicator.calculateValues uses the injected ema', () {
      bool wasCalled = false;
      List<double> fakeEma(
        List<double> values,
        int period,
        double multiplier,
      ) {
        wasCalled = true;
        return List<double>.filled(values.length, 13);
      }

      final EMAIndicator<MockResult> ema = EMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
        ema: fakeEma,
      );

      expect(ema.calculateValues().map((MockResult r) => r.quote), everyElement(13));
      expect(wasCalled, isTrue);
    });
  });

  group('Registry-level default override', () {
    test(
      'setting IndicatorMathRegistry.ema affects EMA '
      'instances built afterwards without a per-instance override',
      () {
        IndicatorMathRegistry.ema = (List<double> values, int period, double multiplier) =>
            List<double>.filled(values.length, -1);

        final EMAIndicator<MockResult> ema = EMAIndicator<MockResult>(
          CloseValueIndicator<MockResult>(MockInput(ticks)),
          3,
        );

        expect(ema.calculateValues().map((MockResult r) => r.quote), everyElement(-1));
      },
    );

    test('resetToDefaults clears the override, falling back to per-index calculate', () {
      IndicatorMathRegistry.windowedAverage = (List<double> values, int period) =>
          List<double>.filled(values.length, -999);
      IndicatorMathRegistry.resetToDefaults();

      final SMAIndicator<MockResult> sma = SMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
      );

      expect(sma.calculateValues()[2].quote, 2); // real SMA math via calculate()
    });
  });
}
