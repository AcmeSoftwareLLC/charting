## 1.0.0
**June 12, 2026**

- Initial release of `acme_indicators`.
- Pure Dart library for technical analysis - no Flutter dependency required.
- Includes 20+ indicators: SMA, EMA, DEMA, TEMA, WMA, HMA, LSMA, TRIMA, MMA, VMA, WWSMA, ZELMA, RSI, MACD, Bollinger Bands, Ichimoku Clouds, Parabolic SAR, ATR, ADX, Aroon, Stochastic (Fast/Slow/SMI), CCI, Williams %R, ROC, DPO, Awesome Oscillator, Gator Oscillator, FCB, Donchian Channel, ZigZag, and more.
- Composable indicator architecture - chain indicators together (e.g. RSI built on top of MMA of gain/loss).
- Caching layer via `CachedIndicator` avoids redundant recalculations.
- Bring-your-own model: implement `IndicatorDataInput`, `IndicatorOHLC`, and `IndicatorResult` to integrate with any data source.
