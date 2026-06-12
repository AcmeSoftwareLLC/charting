<div align="center">

<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/assets/acme-indicators.webp" alt="Acme Indicators" width="200"/>

# Acme Indicators

[![Pub Package](https://img.shields.io/pub/v/acme_indicators.svg)](https://pub.dev/packages/acme_indicators)
[![Pub Points](https://img.shields.io/pub/points/acme_indicators)](https://pub.dev/packages/acme_indicators/score)
[![Publisher](https://img.shields.io/pub/publisher/acme_indicators)](https://pub.dev/publishers/acmesoftware.com/packages)

A pure Dart library for technical analysis — providing 50+ indicators (RSI, MACD, Bollinger Bands, Ichimoku, and more) with no Flutter dependency.

</div>

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  acme_indicators: ^1.0.0
```

**Requires** Dart SDK `>=3.12.0 <4.0.0`.

---

## 🚀 Quick Start

```dart
// 1. Implement IndicatorOHLC with your data model
class MyCandle implements IndicatorOHLC {
  const MyCandle(this.open, this.high, this.low, this.close);

  @override final double open;
  @override final double high;
  @override final double low;
  @override final double close;
}

// 2. Implement IndicatorDataInput
class MyInput implements IndicatorDataInput {
  MyInput(this.entries);

  @override
  final List<IndicatorOHLC> entries;

  @override
  IndicatorResult createResult(int index, double value) =>
      MyResult(value, entries[index] as MyCandle);
}

// 3. Calculate
final input = MyInput(candles);
final rsi = RSIIndicator<MyResult>(input);

final all = rsi.calculateValues();   // List<MyResult>
final single = rsi.getValue(5);      // MyResult
```

---

## 🧩 Core Concepts

The package is built around three interfaces.

### `IndicatorResult`

The output of an indicator calculation:

```dart
abstract class IndicatorResult {
  double get quote;
}
```

Implement this with your own model to carry any extra data (timestamps, candle references, etc.) alongside the calculated value.

```dart
class MyResult implements IndicatorResult {
  MyResult(this.quote, this.candle);

  @override
  final double quote;

  final MyCandle candle; // attach whatever context you need
}
```

### `IndicatorOHLC`

Represents a price bar with Open, High, Low, and Close values:

```dart
abstract class IndicatorOHLC {
  double get open;
  double get high;
  double get low;
  double get close;
}
```

For single-value series (e.g. tick data), map all four fields to the same value:

```dart
class Tick implements IndicatorOHLC {
  const Tick(this.value);
  final double value;

  @override double get open  => value;
  @override double get high  => value;
  @override double get low   => value;
  @override double get close => value;
}
```

### `IndicatorDataInput`

Bridges your data and the indicator engine:

```dart
abstract class IndicatorDataInput {
  List<IndicatorOHLC> get entries;
  IndicatorResult createResult(int index, double value);
}
```

`createResult` is called for each calculated value — use it to produce whatever `IndicatorResult` subclass you need, enriched with index-based context from your source list.

---

## 📈 Available Indicators

### 📉 Moving Averages

| Indicator | Class |
|-----------|-------|
| Simple Moving Average | `SMAIndicator` |
| Exponential Moving Average | `EMAIndicator` |
| Double Exponential Moving Average | `DEMAIndicator` |
| Triple Exponential Moving Average | `TEMAIndicator` |
| Triangular Moving Average | `TRIMAIndicator` |
| Weighted Moving Average | `WMAIndicator` |
| Modified Moving Average | `MMAIndicator` |
| Least Squares Moving Average | `LSMAIndicator` |
| Hull Moving Average | `HMAIndicator` |
| Variable Moving Average | `VMAIndicator` |
| Welles Wilder Smoothing | `WWSMAIndicator` |
| Zero-Lag EMA | `ZELMAIndicator` |

### 〰️ Oscillators

| Indicator | Class |
|-----------|-------|
| Relative Strength Index | `RSIIndicator` |
| Fast / Slow / Smoothed Stochastic | `StochasticIndicator` |
| Stochastic Momentum Index | `SMIIndicator` |
| MACD Line / Signal / Histogram | `MACDIndicator` |
| Awesome Oscillator | `AwesomeOscillatorIndicator` |
| Williams %R | `WilliamsRIndicator` |
| Rate of Change | `ROCIndicator` |
| Chande Momentum Oscillator | `CMOIndicator` |
| Gator Oscillator (Top / Bottom) | `GatorOscillatorIndicator` |

### 📡 Trend Indicators

| Indicator | Class |
|-----------|-------|
| ADX / +DI / -DI / Histogram | `ADXIndicator` |
| Parabolic SAR | `ParabolicSARIndicator` |
| Ichimoku Cloud (all five lines) | `IchimokuIndicator` |

### 💥 Volatility Indicators

| Indicator | Class |
|-----------|-------|
| Bollinger Bands (Upper / Lower / %B / BW) | `BollingerBandsIndicator` |
| Average True Range | `ATRIndicator` |
| Standard Deviation | `StandardDeviationIndicator` |
| Variance | `VarianceIndicator` |

### 📏 Channel Indicators

| Indicator | Class |
|-----------|-------|
| Donchian Channel | `DonchianChannelIndicator` |
| Moving Average Envelope | `MAEnvelopeIndicator` |

### 🔀 Other Indicators

| Indicator | Class |
|-----------|-------|
| Aroon Up / Down / Oscillator | `AroonIndicator` |
| Commodity Channel Index | `CCIIndicator` |
| Detrended Price Oscillator | `DPOIndicator` |
| ZigZag | `ZigZagIndicator` |
| Fixed Channel Bands (High / Low) | `FCBIndicator` |
| Bullish / Bearish Pattern Recognition | `PatternIndicator` |

### 🔧 Helper Indicators

Price values (OHLC), common averages (HL2, HLC3, HLCC4, OHLC4), True Range, Directional Movement, Gain/Loss, Mean, and Difference.

---

## 💡 Usage

### 🔗 Chaining Indicators

Any indicator can be used as input to another:

```dart
final macd = MACDIndicator<MyResult>(input);

// Feed MACD output into a 3-period SMA
final smoothed = SMAIndicator<MyResult>(macd, 3);
```

### ⚡ Caching and Invalidation

All indicators extend `CachedIndicator`, so repeated reads are free:

```dart
// Batch-calculate and cache all values
final values = indicator.calculateValues();

// Read from cache (no recalculation)
final v = indicator.getValue(5);

// Invalidate a single slot (e.g. after a live candle update)
indicator.invalidate(lastIndex);

// Recalculate one value
indicator.refreshValueFor(lastIndex);
```

---

## 🏗️ Architecture

```
Indicator<T>               — base abstract class; generic T extends IndicatorResult
  └─ CachedIndicator<T>    — adds per-index caching, invalidation, and batch helpers
       └─ RSIIndicator<T>  — concrete implementation (same pattern for all indicators)
```

Indicators are composable: any `Indicator<T>` can be passed where an `IndicatorDataInput` is expected, enabling indicator-on-indicator pipelines with shared caching.
