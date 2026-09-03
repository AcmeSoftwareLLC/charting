import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/measure/measure_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:material_ui/material_ui.dart';

/// Measure drawing tool item in the list of drawing tools which provide this
/// drawing tools options menu.
class MeasureDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const MeasureDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    MeasureDrawingToolConfig super.config = const MeasureDrawingToolConfig(),
  }) : super(title: 'Measure');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      MeasureDrawingToolItemState();
}

/// MeasureDrawingToolItem State class
class MeasureDrawingToolItemState
    extends DrawingToolItemState<MeasureDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  MeasureDrawingToolConfig createDrawingToolConfig() =>
      MeasureDrawingToolConfig(
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() =>
      Column(children: <Widget>[_buildColorField()]);

  Widget _buildColorField() => Row(
    children: <Widget>[
      Text(
        ChartLocalization.of(context).labelColor,
        style: const TextStyle(fontSize: 16),
      ),
      ColorSelector(
        currentColor: _currentLineStyle.color,
        onColorChanged: (Color selectedColor) {
          setState(() {
            _lineStyle = _currentLineStyle.copyWith(color: selectedColor);
          });
          updateDrawingTool();
        },
      ),
    ],
  );

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as MeasureDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as MeasureDrawingToolConfig).pattern;
}
