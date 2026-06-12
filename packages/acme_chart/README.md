<div align="center">

# Acme Chart

[![Pub Package](https://img.shields.io/pub/v/acme_chart.svg)](https://pub.dev/packages/acme_chart)
[![Pub Points](https://img.shields.io/pub/points/acme_chart)](https://pub.dev/packages/acme_chart/score)
[![Publisher](https://img.shields.io/pub/publisher/acme_chart)](https://pub.dev/publishers/acmesoftware.com/packages)

A financial charting library for Flutter - candlestick & line charts, 50+ technical indicators, interactive drawing tools, and customizable themes. Built for trading platforms and market data visualization.

|<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/intro.gif" alt="intro" width="627" height="330">|
| --- |

</div>

| Different Chart Types | Annotations & Crosshair |
|---|---|
| <img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/different_chart_types.gif" alt="Chart types" width="300" height="400"> | <img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/annotations_and_crosshair.gif" alt="Annotations" width="300" height="400"> |

| Technical Indicators | Interactive Tools |
|---|---|
| <img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/indicators.gif" alt="Indicators" width="300" height="400"> | <img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/interactive_tools.gif" alt="Tools" width="300" height="400"> |

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  acme_chart: ^1.0.0
```

**Requires** Dart SDK `>=3.12.0 <4.0.0` and Flutter `^3.44.0`.

---

## Quick Start

```dart
import 'package:acme_chart/acme_chart.dart';

final candles = [
  Candle(epoch: DateTime(...), open: 200, high: 400, low: 50, close: 100),
  Candle(epoch: DateTime(...), open: 100, high: 500, low: 100, close: 500),
];

Chart(
  mainSeries: CandleSeries(candles),
  pipSize: 3,       // decimal places on the y-axis
  granularity: 60,  // candle period in seconds
)
```

<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/candle_chart_example.png" alt="candle_series" width="450" height="250">

---

## Chart Types

Pass a different `Series` to `mainSeries` to switch chart types:

```dart
// Candlestick
Chart(mainSeries: CandleSeries(candles), pipSize: 3)

// Line
Chart(mainSeries: LineSeries(candles), pipSize: 3)
```

<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/line_chart_example.png" alt="line_series" width="450" height="250">

### Styling Series

```dart
Chart(
  mainSeries: CandleSeries(
    candles,
    style: CandleStyle(
      positiveColor: Colors.green,
      negativeColor: Colors.red,
    ),
  ),
)
```

---

## Annotations

Add horizontal or vertical barriers via the `annotations` parameter:

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 3,
  annotations: [
    HorizontalBarrier(98161.950),
    VerticalBarrier(candles.last.epoch, title: 'V Barrier'),
  ],
)
```

<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/barriers_example.png" alt="barriers" width="450" height="250">

### Styling Annotations

```dart
HorizontalBarrier(
  98161.950,
  style: HorizontalBarrierStyle(
    color: const Color(0xFF00A79E),
    isDashed: false,
  ),
  visibility: HorizontalBarrierVisibility.forceToStayOnRange,
)
```

Custom annotations are supported - subclass `ChartAnnotation` to render anything you need.

### TickIndicator

A built-in annotation that highlights the most recent tick:

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 3,
  annotations: [TickIndicator(candles.last)],
)
```

<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/tick_indicator_example.png" alt="tick_indicator" width="450" height="250">

---

## Technical Indicators

Use `overlayConfigs` for indicators that share the main y-axis (e.g. Bollinger Bands) and `bottomConfigs` for indicators with their own scale (e.g. RSI, MACD):

```dart
Chart(
  mainSeries: CandleSeries(candles),
  overlayConfigs: [
    BollingerBandsIndicatorConfig(
      period: 20,
      standardDeviation: 2,
      movingAverageType: MovingAverageType.exponential,
      upperLineStyle: LineStyle(color: Colors.purple),
      middleLineStyle: LineStyle(color: Colors.black),
      lowerLineStyle: LineStyle(color: Colors.blue),
    ),
  ],
  bottomConfigs: [
    RSIIndicatorConfig(
      period: 14,
      lineStyle: LineStyle(color: Colors.green, thickness: 1),
      oscillatorLinesConfig: OscillatorLinesConfig(
        overboughtValue: 70,
        oversoldValue: 30,
        overboughtStyle: LineStyle(color: Colors.red),
        oversoldStyle: LineStyle(color: Colors.green),
      ),
      showZones: true,
    ),
    SMIIndicatorConfig(
      period: 14,
      signalPeriod: 9,
      lineStyle: LineStyle(color: Colors.blue, thickness: 2),
      signalLineStyle: LineStyle(color: Colors.red),
    ),
  ],
  pipSize: 3,
  granularity: 60,
)
```

<img src="https://raw.githubusercontent.com/AcmeSoftwareLLC/charting/main/packages/acme_chart/doc/images/bb_smi_rsi.png" alt="bb_smi_rsi" width="450" height="250">

### Available Indicators

#### Moving Averages

| Indicator | Config Class |
|-----------|-------------|
| Simple Moving Average | `SMAIndicatorConfig` |
| Exponential Moving Average | `EMAIndicatorConfig` |
| Double Exponential Moving Average | `DEMAIndicatorConfig` |
| Triple Exponential Moving Average | `TEMAIndicatorConfig` |
| Triangular Moving Average | `TRIMAIndicatorConfig` |
| Weighted Moving Average | `WMAIndicatorConfig` |
| Modified Moving Average | `MMAIndicatorConfig` |
| Least Squares Moving Average | `LSMAIndicatorConfig` |
| Hull Moving Average | `HMAIndicatorConfig` |
| Variable Moving Average | `VMAIndicatorConfig` |
| Welles Wilder Smoothing | `WWSMAIndicatorConfig` |
| Zero-Lag EMA | `ZELMAIndicatorConfig` |

#### Oscillators

| Indicator | Config Class |
|-----------|-------------|
| Relative Strength Index | `RSIIndicatorConfig` |
| Stochastic Momentum Index | `SMIIndicatorConfig` |
| MACD Line / Signal / Histogram | `MACDIndicatorConfig` |
| Awesome Oscillator | `AwesomeOscillatorIndicatorConfig` |
| Williams %R | `WilliamsRIndicatorConfig` |
| Rate of Change | `ROCIndicatorConfig` |
| Chande Momentum Oscillator | `CMOIndicatorConfig` |
| Gator Oscillator | `GatorOscillatorIndicatorConfig` |

#### Trend Indicators

| Indicator | Config Class |
|-----------|-------------|
| Average Directional Index | `ADXIndicatorConfig` |
| Parabolic SAR | `ParabolicSARIndicatorConfig` |
| Ichimoku Cloud | `IchimokuIndicatorConfig` |

#### Volatility Indicators

| Indicator | Config Class |
|-----------|-------------|
| Bollinger Bands | `BollingerBandsIndicatorConfig` |
| Average True Range | `ATRIndicatorConfig` |
| Standard Deviation | `StandardDeviationIndicatorConfig` |
| Variance | `VarianceIndicatorConfig` |

#### Channel Indicators

| Indicator | Config Class |
|-----------|-------------|
| Donchian Channel | `DonchianChannelIndicatorConfig` |
| Moving Average Envelope | `MAEnvelopeIndicatorConfig` |

#### Other Indicators

| Indicator | Config Class |
|-----------|-------------|
| Aroon Up / Down / Oscillator | `AroonIndicatorConfig` |
| Commodity Channel Index | `CCIIndicatorConfig` |
| Detrended Price Oscillator | `DPOIndicatorConfig` |
| ZigZag | `ZigZagIndicatorConfig` |
| Fixed Channel Bands | `FCBIndicatorConfig` |
| Bullish / Bearish Pattern Recognition | `PatternIndicatorConfig` |

---

## Drawing Tools

Interactive drawing tools (trend lines, channels, Fibonacci retracements, and more) are supported. See the [Drawing Tools documentation](doc/drawing_tools.md) for the full list and configuration options.

---

## Markers

Supply `markerSeries` to show trade entry/exit markers:

```dart
Chart(
  mainSeries: CandleSeries(candles),
  markerSeries: MarkerSeries([
    Marker.up(epoch: 123, quote: 10, onTap: () {}),
    Marker.down(epoch: 124, quote: 12, onTap: () {}),
  ]),
)
```

For an active (expanded) marker:

```dart
MarkerSeries(
  [...],
  activeMarker: ActiveMarker(
    epoch: 123,
    quote: 10,
    onTap: () {},
    onOutsideTap: () { /* dismiss */ },
  ),
)
```

For entry/exit tick markers:

```dart
MarkerSeries(
  [...],
  entryTick: Tick(epoch: ..., quote: ...),
  exitTick: Tick(epoch: ..., quote: ...),
)
```

---

## Callbacks

### Visible Area Changes

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
    // load more data when scrolled to the left edge
  },
)
```

### Crosshair

```dart
Chart(
  mainSeries: LineSeries(candles),
  pipSize: 4,
  onCrosshairAppeared: () => Vibration.vibrate(duration: 50),
)
```

---

## Theme

The chart automatically switches between its built-in dark and light themes based on `Theme.of(context).brightness`. To customise, extend `ChartDefaultDarkTheme` or `ChartDefaultLightTheme` and override only what you need:

```dart
class CustomTheme extends ChartDefaultDarkTheme {
  @override
  GridStyle get gridStyle => GridStyle(
    gridLineColor: Colors.yellow,
    xLabelStyle: textStyle(
      textStyle: caption2,
      color: Colors.yellow,
      fontSize: 13,
    ),
  );
}

Chart(
  mainSeries: CandleSeries(candles),
  theme: CustomTheme(),
)
```

See [ChartTheme](lib/src/theme/chart_theme.dart) for all overridable properties.

---

## Localization

Add `ChartLocalization.delegate` to your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: [
    ChartLocalization.delegate,
    // ...
  ],
)
```

To change the chart locale at runtime:

```dart
ChartLocalization.load(locale);
```

---

## AcmeChart

`AcmeChart` is a batteries-included wrapper around `Chart` that adds a built-in UI for adding, removing, and configuring indicators and drawing tools, with automatic persistence via `shared_preferences`.

```dart
AcmeChart(
  mainSeries: CandleSeries(candles),
  granularity: 60,
  activeSymbol: 'default',
  pipSize: 4,
)
```

All `Chart` parameters are available on `AcmeChart` except `overlayConfigs` and `bottomConfigs`, which are managed internally. See the [AcmeChart documentation](doc/acme_chart_widget_usage.md) for full details.

---

## ChartController

Programmatically control scroll and zoom:

```dart
final controller = ChartController();

Chart(
  mainSeries: CandleSeries(candles),
  controller: controller,
)

controller.scrollToLastTick();
controller.scale(100);
```

---

## Additional Documentation

- [How Chart Library Works](doc/how_chart_lib_works.md)
- [Drawing Tools](doc/drawing_tools.md)
- [AcmeChart Widget Usage](doc/acme_chart_widget_usage.md)
- [Contributing](doc/contribution.md)
