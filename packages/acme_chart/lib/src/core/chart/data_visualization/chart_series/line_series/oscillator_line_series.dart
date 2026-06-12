import '../../../../../models/tick.dart';
import '../../../../../theme/painting_styles/line_style.dart';

import '../data_series.dart';
import '../series_painter.dart';
import 'line_series.dart';
import 'oscillator_line_painter.dart';

/// Oscillator Line Series.
class OscillatorLineSeries extends LineSeries {
  /// Initializes an Oscillator line series.
  OscillatorLineSeries(
    super.entries, {
    required this._topHorizontalLine,
    required this._bottomHorizontalLine,
    this._secondaryHorizontalLines = const <double>[],
    super.style,
    super.id,
    this._secondaryHorizontalLinesStyle,
    this._mainHorizontalLinesStyle,
  });

  final List<double> _secondaryHorizontalLines;
  final double _topHorizontalLine;
  final double _bottomHorizontalLine;
  final LineStyle? _secondaryHorizontalLinesStyle;

  // ignore: unused_field
  final LineStyle? _mainHorizontalLinesStyle;

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => OscillatorLinePainter(
    this,
    bottomHorizontalLine: _bottomHorizontalLine,
    secondaryHorizontalLines: _secondaryHorizontalLines,
    secondaryHorizontalLinesStyle: _secondaryHorizontalLinesStyle,
    topHorizontalLine: _topHorizontalLine,
  );
}
