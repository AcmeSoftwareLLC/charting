## 1.0.6
**September 5, 2026**

- Added `Chart.chartTimeConfig` for configuring the timezone (`utcOffset`) used across axis, crosshair, and drawing-tool time labels, instead of always forcing UTC.
- Added custom label builder callbacks on `ChartTimeConfig` for the x-axis and crosshair, so implementors can fully customize the displayed time format (e.g. always show seconds).

## 1.0.5
**September 3, 2026**

- Added `BasicChart.showQuoteGrid` / `IndicatorConfig.showQuoteGrid`: lets an individual pane hide its y-axis quote grid (lines + labels) independently of the shared `ChartAxisConfig.showQuoteGrid` setting.
- Added tap interactivity: `BasicChart` now detects taps and forwards them to the pane's series via the new `Series.onTap(Offset localPosition)` method, letting series subclasses handle taps on drawn regions.
- Migrated to material_ui.

## 1.0.4
**August 27, 2026**

- Added `Series.axisGroup`: an overlay series can now be scaled on its own value range instead of the shared price axis, while still rendering layered over the candles. `null` (default) shares the main price axis; a non-null value scales independently, and overlay series sharing the same `axisGroup` value share one combined scale — so unrelated indicators with very different ranges (e.g. a 0-10-bounded oscillator and a MACD-scale signal) don't distort each other.
- Fixed `MinMaxCalculator` treating a `NaN` entry (e.g. an indicator's not-yet-warmed-up values) as the largest key in its sorted map, silently corrupting `Series.maxValue`/`minValue` for the whole visible frame whenever any `NaN` entry was in view.
- Fixed slow, erratic typing when editing "Notes" drawing tool text boxes.

## 1.0.3
**August 26, 2026**

- Added new interactive drawing tools: Rectangle, Channel, Notes, Ellipse, Fibonacci Retracement, Fib Fan, Trade Ratio, Doodle, Segment, and Measure.
- Added magnet snapping for drawing tools via the new `magnetEnabled` property on `ChartConfig`.
- Added a copy button for drawings and improved trend line interaction handling.
- Updated line and label drawing tool configs to default to blue styling.
- Removed unused overlay style JSON serialization methods.

## 1.0.2
**August 25, 2026**

- Added `StochasticOscillatorIndicatorConfig` and its indicator item (Fast/Slow Stochastic Oscillator).
- Added `FunctionIndicator` and `MemoizedResult` for supplying custom bulk math computations to indicator series.
- Exported `ChannelFillPainter` from `chart_series`.
- Fixed indicator series repaint logic to also honor `super.shouldRepaint`.
- Fixed a null-safety issue where `followCurrentTick` was checked before confirming width was non-null.

## 1.0.1
**June 12, 2026**

- Improved pub score

## 1.0.0
**June 12, 2026**

- Initial release of `acme_chart`.
- Candlestick and line chart types via `CandleSeries` and `LineSeries`, with configurable `CandleStyle` and `LineStyle`.
- Overlay indicators (share the main y-axis) and bottom indicators (independent y-axis) via `overlayConfigs` and `bottomConfigs`.
- 50+ technical indicators including RSI, MACD, Bollinger Bands, Ichimoku Cloud, Parabolic SAR, ADX, Stochastic (Fast/Slow/SMI), ATR, Aroon, CCI, Williams %R, ROC, DPO, Gator Oscillator, Donchian Channel, ZigZag, and all major moving averages (SMA, EMA, DEMA, TEMA, WMA, HMA, LSMA, TRIMA, MMA, VMA, WWSMA, ZELMA).
- Annotations support: `HorizontalBarrier`, `VerticalBarrier`, and `TickIndicator`, with customizable styles and visibility modes.
- Interactive drawing tools (trend lines, channels, Fibonacci retracements, and more).
- Trade markers via `MarkerSeries` with support for up/down markers, active markers, and entry/exit tick markers.
- `AcmeChart` widget - batteries-included wrapper with built-in UI for adding, removing, and configuring indicators and drawing tools, with automatic persistence via `shared_preferences`.
- `ChartController` for programmatic scroll (`scrollToLastTick`) and zoom (`scale`).
- Built-in dark and light themes that automatically follow `Theme.of(context).brightness`; extend `ChartDefaultDarkTheme` or `ChartDefaultLightTheme` to customise.
- Localization support via `ChartLocalization.delegate` and `ChartLocalization.load`.
- Callbacks: `onVisibleAreaChanged` (left/right epoch bounds) and `onCrosshairAppeared`.
- Performance optimisations: binary search for visible data, per-index indicator value caching via `acme_indicators`.
