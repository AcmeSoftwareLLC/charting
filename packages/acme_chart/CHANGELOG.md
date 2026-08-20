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
