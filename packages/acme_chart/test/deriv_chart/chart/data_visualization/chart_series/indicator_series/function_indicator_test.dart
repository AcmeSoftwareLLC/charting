import 'package:acme_chart/acme_chart.dart';
import 'package:acme_indicators/acme_indicators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IndicatorInput input;

  setUp(() {
    input = IndicatorInput(const <Tick>[
      Tick(epoch: 1000, quote: 1),
      Tick(epoch: 2000, quote: 2),
      Tick(epoch: 3000, quote: 3),
      Tick(epoch: 4000, quote: 4),
    ], 1000);
  });

  group('FunctionIndicator', () {
    test('computes values via the supplied bulk function', () {
      final Indicator<Tick> closeIndicator = CloseValueIndicator<Tick>(input);
      final FunctionIndicator<Tick> indicator = FunctionIndicator<Tick>(
        closeIndicator,
        (List<IndicatorOHLC> bars, List<double> values) => <double>[
          for (final double v in values) v * 2,
        ],
      );

      final List<Tick> results = indicator.calculateValues();

      expect(results.map((Tick t) => t.quote), <double>[2, 4, 6, 8]);
    });

    test('passes raw OHLC bars through to the compute function', () {
      final Indicator<Tick> closeIndicator = CloseValueIndicator<Tick>(input);
      final FunctionIndicator<Tick> indicator = FunctionIndicator<Tick>(
        closeIndicator,
        (List<IndicatorOHLC> bars, List<double> values) => <double>[
          for (final IndicatorOHLC bar in bars) bar.high,
        ],
      );

      final List<Tick> results = indicator.calculateValues();

      // Tick's high == its quote.
      expect(results.map((Tick t) => t.quote), <double>[1, 2, 3, 4]);
    });

    test('calculate() throws since only bulk computation is supported', () {
      final Indicator<Tick> closeIndicator = CloseValueIndicator<Tick>(input);
      final FunctionIndicator<Tick> indicator = FunctionIndicator<Tick>(
        closeIndicator,
        (List<IndicatorOHLC> bars, List<double> values) => values,
      );

      expect(() => indicator.calculate(0), throwsUnimplementedError);
    });
  });

  group('MemoizedResult', () {
    test('invokes the wrapped function only once across multiple calls', () {
      int callCount = 0;
      final MemoizedResult<List<double>> memoized =
          MemoizedResult<List<double>>((
            List<IndicatorOHLC> bars,
            List<double> values,
          ) {
            callCount++;
            return values;
          });

      final Indicator<Tick> closeIndicator = CloseValueIndicator<Tick>(input);
      final List<double> firstCall = memoized(closeIndicator.entries, <double>[
        1,
        2,
        3,
        4,
      ]);
      final List<double> secondCall = memoized(closeIndicator.entries, <double>[
        1,
        2,
        3,
        4,
      ]);

      expect(callCount, 1);
      expect(identical(firstCall, secondCall), isTrue);
    });

    test('lets multiple FunctionIndicators share one computed result', () {
      int callCount = 0;
      final Indicator<Tick> closeIndicator = CloseValueIndicator<Tick>(input);
      final MemoizedResult<Map<String, List<double>>> shared =
          MemoizedResult<Map<String, List<double>>>((
            List<IndicatorOHLC> bars,
            List<double> values,
          ) {
            callCount++;
            return <String, List<double>>{
              'upper': <double>[for (final double v in values) v + 1],
              'lower': <double>[for (final double v in values) v - 1],
            };
          });

      final FunctionIndicator<Tick> upper = FunctionIndicator<Tick>(
        closeIndicator,
        (List<IndicatorOHLC> bars, List<double> values) =>
            shared(bars, values)['upper']!,
      );
      final FunctionIndicator<Tick> lower = FunctionIndicator<Tick>(
        closeIndicator,
        (List<IndicatorOHLC> bars, List<double> values) =>
            shared(bars, values)['lower']!,
      );

      final List<double> upperValues = upper
          .calculateValues()
          .map((Tick t) => t.quote)
          .toList();
      final List<double> lowerValues = lower
          .calculateValues()
          .map((Tick t) => t.quote)
          .toList();

      expect(upperValues, <double>[2, 3, 4, 5]);
      expect(lowerValues, <double>[0, 1, 2, 3]);
      expect(callCount, 1);
    });
  });
}
