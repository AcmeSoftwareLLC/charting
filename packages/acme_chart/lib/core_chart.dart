/// Lite public entry point for consumers that manage their own
/// [indicatorsRepo] and [drawingToolsRepo].
///
/// Exports the same surface as [acme_chart.dart] but uses
/// [acme_chart_lite.dart] under the hood, which omits the built-in indicator/
/// drawing-tool dialog imports and shared_preferences. This keeps the Flutter
/// web bundle smaller by allowing dart2js to tree-shake those dependencies.
///
/// Use [package:acme_chart/acme_chart.dart] instead if you need the built-in
/// dialog UI.
library;

export 'package:acme_chart/src/core/acme_chart_lite.dart';

// Re-export everything else from the full library except AcmeChart itself.
export 'package:acme_chart/acme_chart.dart' hide AcmeChart;
