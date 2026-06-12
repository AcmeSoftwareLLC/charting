import 'package:acme_indicators/src/indicators/calculations/williams_r_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Williams R indicator', () {
    test('Williams R indicators calculates the result correctly.', () {
      const List<MockOHLC> ticks = <MockOHLC>[
        MockOHLC(1, 44.98, 45.05, 45.17, 44.96),
        MockOHLC(2, 45.05, 45.10, 45.15, 44.99),
        MockOHLC(3, 45.11, 45.19, 45.32, 45.11),
        MockOHLC(4, 45.19, 45.14, 45.25, 45.04),
        MockOHLC(5, 45.12, 45.15, 45.20, 45.10),
        MockOHLC(6, 45.15, 45.14, 45.20, 45.10),
        MockOHLC(7, 45.13, 45.10, 45.16, 45.07),
        MockOHLC(8, 45.12, 45.15, 45.22, 45.10),
        MockOHLC(9, 45.15, 45.22, 45.27, 45.14),
        MockOHLC(10, 45.24, 45.43, 45.45, 45.20),
        MockOHLC(11, 45.43, 45.44, 45.50, 45.39),
        MockOHLC(12, 45.43, 45.55, 45.60, 45.35),
        MockOHLC(13, 45.58, 45.55, 45.61, 45.39),
      ];

      final WilliamsRIndicator<MockResult> wr =
          WilliamsRIndicator<MockResult>(MockInput(ticks), 5);

      expect(wr.getValue(4).quote, closeTo(-47.22222222, 0.000001));
      expect(wr.getValue(5).quote, closeTo(-54.54545454, 0.000001));
      expect(wr.getValue(6).quote, closeTo(-78.57142857, 0.000001));
      expect(wr.getValue(7).quote, closeTo(-47.61904761, 0.000001));
      expect(wr.getValue(8).quote, closeTo(-25.00000000, 0.000001));
      expect(wr.getValue(9).quote, closeTo(-5.26315789, 0.000001));
      expect(wr.getValue(10).quote, closeTo(-13.95348837, 0.000001));
    });
  });
}
