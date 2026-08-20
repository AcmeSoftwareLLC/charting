import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'ray_drawing_tool_config.dart';

/// Ray drawing tool item in the list of drawing tools
class RayDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const RayDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    RayDrawingToolConfig super.config = const RayDrawingToolConfig(),
  }) : super(title: 'Ray');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      RayDrawingToolItemState();
}

/// RayDrawingToolItem State class
class RayDrawingToolItemState
    extends DrawingToolItemState<RayDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  RayDrawingToolConfig createDrawingToolConfig() => RayDrawingToolConfig(
    lineStyle: _currentLineStyle,
    pattern: _currentPattern,
  );

  @override
  Widget getDrawingToolOptions() => Column(
    children: <Widget>[
      _buildColorField(),
      // TODO(maryia-binary): implement _buildPatternField() to set pattern
    ],
  );

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
      _lineStyle ?? (widget.config as RayDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as RayDrawingToolConfig).pattern;
}
