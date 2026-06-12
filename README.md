<p align="center">
  <img src="assets/acme-logo.webp" alt="Acme Software" width="280"/>
</p>

<h1 align="center">Acme Charting</h1>

<p align="center">
  A collection of Flutter packages for financial charting and technical analysis.
</p>

<p align="center">
  <a href="https://github.com/AcmeSoftwareLLC/charting/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"/></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.44%2B-blue?logo=flutter" alt="Flutter 3.44+"/></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.12%2B-blue?logo=dart" alt="Dart 3.12+"/></a>
</p>

---

## Packages

| Package | Description | Version |
|---------|-------------|---------|
| [`acme_chart`](packages/acme_chart) | Financial charting library — candlestick/line charts, indicators, drawing tools | `1.0.0` |
| [`acme_indicators`](packages/acme_indicators) | Pure Dart technical analysis computations | `1.0.0` |

---

## Features

### acme_chart

- **Chart Types** — Candlestick (OHLC) and line series
- **20+ Technical Indicators** — RSI, MACD, Bollinger Bands, Ichimoku Cloud, ADX, Alligator, Aroon, CCI, Donchian Channels, DPO, Fractals, Gator, MA/MA Rainbow/MA Envelope, Parabolic SAR, ROC, SMI, Stochastic Oscillator, Williams %R, ZigZag, and more
- **Drawing Tools** — Trend lines, horizontal/vertical lines, rays, channels, rectangles, Fibonacci fan, and more
- **Interactive** — Pinch-to-zoom, pan, crosshair, tap-to-select
- **Barriers & Markers** — Entry/exit markers, price barriers, tick indicators
- **Theming** — Built-in dark/light themes, fully customizable
- **Persistent Storage** — Saves indicator and drawing tool configuration via `shared_preferences`

### acme_indicators

- Standalone Dart package — no Flutter dependency required for computations
- Used internally by `acme_chart` for all indicator calculations

---

## Getting Started

Add `acme_chart` to your `pubspec.yaml`:

```yaml
dependencies:
  acme_chart: ^1.0.0
```

### Basic Usage

```dart
import 'package:acme_chart/acme_chart.dart';

AcmeChart(
  mainSeries: CandleSeries(
    candles: candles, // List<Candle>
  ),
)
```

### With Indicators and Drawing Tools

Use `AcmeChart` for the full-featured widget with UI controls for adding/removing indicators and drawing tools:

```dart
AcmeChart(
  mainSeries: CandleSeries(candles: candles),
  pipSize: 2,
  granularity: 60, // seconds
)
```

Use the lower-level `Chart` widget when you need manual control:

```dart
Chart(
  mainSeries: CandleSeries(candles: candles),
  overlaySeries: [
    BollingerBandsSeries(candles: candles),
  ],
  bottomSeries: [
    RSISeries(candles: candles),
    MACDSeries(candles: candles),
  ],
)
```

---

## Architecture

```
XAxisWrapper          ← zoom/scroll, data management
  └── GestureManager  ← pan, zoom, tap
      └── Chart        ← visualization coordinator
          ├── MainChart    ← candles, overlays, drawings, crosshair
          └── BottomCharts ← RSI, MACD, and other independent-axis indicators
```

See [doc/how_chart_lib_works.md](packages/acme_chart/doc/how_chart_lib_works.md) for a detailed technical walkthrough.

---

## Development

This repository uses [Melos](https://melos.invertase.dev) to manage the monorepo.

```bash
# Install dependencies across all packages
dart pub get

# Analyze all packages
flutter analyze --no-fatal-infos

# Format code
dart format .

# Run tests
flutter test

# Run code generation (JSON serialization)
dart run build_runner build --delete-conflicting-outputs
```

### Example App

```bash
cd packages/acme_chart/example
flutter run
```

---

## Theming

The chart ships with `ChartDefaultDarkTheme` and `ChartDefaultLightTheme`, which switch automatically based on `Theme.of(context).brightness`. Override specific tokens by extending either class:

```dart
class MyChartTheme extends ChartDefaultDarkTheme {
  @override
  Color get backgroundColor => const Color(0xFF1A1A2E);
}
```

---

## Contributing

See [CONTRIBUTING](packages/acme_chart/doc/contribution.md) for code style, commit format, and review checklist.

- Follow [Conventional Commits](https://www.conventionalcommits.org) for PR titles
- Run `flutter analyze` and `flutter test` before submitting
- Add dartdoc comments to all public APIs

---

## License

[MIT](LICENSE) © 2026 Acme Software LLC
