import 'package:acme_indicators/acme_indicators.dart';

class Candle implements IndicatorOHLC {
  const Candle(this.open, this.high, this.low, this.close);

  @override
  final double open;
  @override
  final double high;
  @override
  final double low;
  @override
  final double close;
}

class CandleResult implements IndicatorResult {
  const CandleResult(this.quote);

  @override
  final double quote;
}

class CandleInput implements IndicatorDataInput {
  CandleInput(this.entries);

  @override
  final List<IndicatorOHLC> entries;

  @override
  IndicatorResult createResult(int index, double value) => CandleResult(value);
}

void main() {
  final input = CandleInput([
    const Candle(44.34, 44.84, 44.32, 44.83),
    const Candle(44.83, 45.10, 44.79, 44.32),
    const Candle(44.32, 44.75, 44.20, 44.83),
    const Candle(44.83, 45.15, 44.60, 45.10),
    const Candle(45.10, 45.23, 44.98, 43.61),
    const Candle(43.61, 44.33, 43.55, 44.33),
    const Candle(44.33, 44.83, 44.32, 44.83),
    const Candle(44.83, 45.10, 44.46, 45.10),
    const Candle(45.10, 45.15, 44.96, 45.15),
    const Candle(45.15, 43.61, 43.55, 43.61),
    const Candle(43.61, 44.33, 43.61, 44.33),
    const Candle(44.33, 44.83, 44.32, 44.83),
    const Candle(44.83, 45.10, 44.46, 45.10),
    const Candle(45.10, 45.23, 44.98, 45.23),
  ]);

  final closeIndicator = CloseValueIndicator<CandleResult>(input);

  final sma = SMAIndicator<CandleResult>(closeIndicator, 5);
  final ema = EMAIndicator<CandleResult>(closeIndicator, 5);
  final rsi = RSIIndicator<CandleResult>.fromIndicator(closeIndicator, 14);

  print('Index | Close  | SMA(5) | EMA(5) | RSI(14)');
  print('------+--------+--------+--------+--------');
  for (int i = 0; i < input.entries.length; i++) {
    final close = input.entries[i].close;
    final smaVal = sma.getValue(i).quote;
    final emaVal = ema.getValue(i).quote;
    final rsiVal = rsi.getValue(i).quote;
    print(
      '${i.toString().padLeft(5)} | '
      '${close.toStringAsFixed(2).padLeft(6)} | '
      '${smaVal.toStringAsFixed(2).padLeft(6)} | '
      '${emaVal.toStringAsFixed(2).padLeft(6)} | '
      '${rsiVal.toStringAsFixed(2).padLeft(7)}',
    );
  }
}
