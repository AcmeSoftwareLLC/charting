import 'package:acme_indicators/src/indicators/calculations/atr_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/bollinger/bollinger_bands_lower_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/ema_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:acme_indicators/src/indicators/calculations/helper_indicators/tr_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/macd/macd_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/rsi_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/sma_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:acme_indicators/src/indicators/calculations/statistics/variance_indicator.dart';
import 'package:test/test.dart';

import '../indicators/mock_models.dart';

void main() {
  List<double> quotesOf(List<dynamic> results) =>
      results.map<double>((dynamic r) => (r as MockResult).quote).toList();

  group('SMAIndicator.calculateValues', () {
    test('zero-fills the lookback region, matching gc-core Sma', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 3, 4, 5]) MockTick(quote: q),
      ];
      final SMAIndicator<MockResult> sma = SMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
      );

      expect(quotesOf(sma.calculateValues()), <double>[0, 0, 2, 3, 4]);
    });
  });

  group('EMAIndicator.calculateValues', () {
    test('seeds via SMA of the first `period` values, matching gc-core Ema', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 3, 4, 5]) MockTick(quote: q),
      ];
      final EMAIndicator<MockResult> ema = EMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
      );

      expect(quotesOf(ema.calculateValues()), <double>[0, 0, 2, 3, 4]);
    });
  });

  group('RSIIndicator.calculateValues', () {
    test('matches gc-core\'s custom Rsi tie-break/rounding behavior', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 1, 2, 3]) MockTick(quote: q),
      ];
      final RSIIndicator<MockResult> rsi = RSIIndicator<MockResult>.fromIndicator(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        2,
      );

      expect(quotesOf(rsi.calculateValues()), <double>[0, 0, 50, 75, 87.5]);
    });
  });

  group('MACDIndicator.calculateValues', () {
    test('clamps to 0 until both EMAs are valid, then diffs the EMAs', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 3, 4, 5]) MockTick(quote: q),
      ];
      final MACDIndicator<MockResult> macd = MACDIndicator<MockResult>(
        MockInput(ticks),
        fastMAPeriod: 2,
        slowMAPeriod: 3,
      );

      final List<double> result = quotesOf(macd.calculateValues());
      expect(result[0], 0);
      expect(result[1], 0);
      expect(result[2], closeTo(0.5, 1e-9));
      expect(result[3], closeTo(0.5, 1e-9));
      expect(result[4], closeTo(0.5, 1e-9));
    });
  });

  group('VarianceIndicator.calculateValues', () {
    test('population variance of consecutive integers over a window of 3 is 2/3', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 3, 4, 5]) MockTick(quote: q),
      ];
      final VarianceIndicator<MockResult> variance = VarianceIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
      );

      final List<double> result = quotesOf(variance.calculateValues());
      expect(result[0], 0);
      expect(result[1], 0);
      expect(result[2], closeTo(2 / 3, 1e-9));
      expect(result[3], closeTo(2 / 3, 1e-9));
      expect(result[4], closeTo(2 / 3, 1e-9));
    });
  });

  group('StandardDeviationIndicator.calculateValues', () {
    test('is the square root of the bulk-computed variance', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 3, 4, 5]) MockTick(quote: q),
      ];
      final StandardDeviationIndicator<MockResult> stdDev = StandardDeviationIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        3,
      );

      final List<double> result = quotesOf(stdDev.calculateValues());
      expect(result[0], 0);
      expect(result[1], 0);
      expect(result[2], closeTo(0.8164965809, 1e-9));
    });
  });

  group('TRIndicator.calculateValues', () {
    test('index 0 is 0; matches the high/low/prevClose formula after that', () {
      final List<MockOHLC> ticks = <MockOHLC>[
        const MockOHLC.withNames(epoch: 0, open: 9, close: 9, high: 10, low: 8),
        const MockOHLC.withNames(epoch: 1, open: 11, close: 11, high: 12, low: 9),
        const MockOHLC.withNames(epoch: 2, open: 10.5, close: 10.5, high: 11, low: 9),
      ];
      final TRIndicator<MockResult> tr = TRIndicator<MockResult>(MockInput(ticks));

      expect(quotesOf(tr.calculateValues()), <double>[0, 3, 2]);
    });
  });

  group('ATRIndicator.calculateValues', () {
    test('zero-fills the lookback region, seeded by the SMA of true range', () {
      final List<MockOHLC> ticks = <MockOHLC>[
        const MockOHLC.withNames(epoch: 0, open: 9, close: 9, high: 10, low: 8),
        const MockOHLC.withNames(epoch: 1, open: 11, close: 11, high: 12, low: 9),
        const MockOHLC.withNames(epoch: 2, open: 10.5, close: 10.5, high: 11, low: 9),
      ];
      final ATRIndicator<MockResult> atr = ATRIndicator<MockResult>(
        MockInput(ticks),
        period: 2,
      );

      expect(quotesOf(atr.calculateValues()), <double>[0, 0, 2.5]);
    });
  });

  group('Bollinger Bands calculateValues', () {
    test('upper/lower bands are middle +/- deviation * k, both bulk-computed', () {
      final List<MockTick> ticks = <MockTick>[
        for (final double q in <double>[1, 2, 3, 4, 5]) MockTick(quote: q),
      ];
      final CloseValueIndicator<MockResult> close = CloseValueIndicator<MockResult>(
        MockInput(ticks),
      );
      final SMAIndicator<MockResult> bbm = SMAIndicator<MockResult>(close, 3);
      final StandardDeviationIndicator<MockResult> deviation =
          StandardDeviationIndicator<MockResult>(close, 3);

      final BollingerBandsUpperIndicator<MockResult> upper =
          BollingerBandsUpperIndicator<MockResult>(bbm, deviation);
      final BollingerBandsLowerIndicator<MockResult> lower =
          BollingerBandsLowerIndicator<MockResult>(bbm, deviation);

      final List<double> upperResult = quotesOf(upper.calculateValues());
      final List<double> lowerResult = quotesOf(lower.calculateValues());

      expect(upperResult[0], 0);
      expect(upperResult[2], closeTo(2 + (0.8164965809 * 2), 1e-9));
      expect(lowerResult[0], 0);
      expect(lowerResult[2], closeTo(2 - (0.8164965809 * 2), 1e-9));
    });
  });
}
