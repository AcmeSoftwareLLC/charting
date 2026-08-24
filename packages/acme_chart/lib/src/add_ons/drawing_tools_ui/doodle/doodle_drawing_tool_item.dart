import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/doodle/doodle_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Doodle drawing tool item in the list of drawing tools which provide this
/// drawing tools options menu.
class DoodleDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const DoodleDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    DoodleDrawingToolConfig super.config = const DoodleDrawingToolConfig(),
  }) : super(title: 'Doodle');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      DoodleDrawingToolItemState();
}

/// DoodleDrawingToolItem State class
class DoodleDrawingToolItemState
    extends DrawingToolItemState<DoodleDrawingToolConfig> {
  LineStyle? _lineStyle;

  @override
  DoodleDrawingToolConfig createDrawingToolConfig() =>
      DoodleDrawingToolConfig(lineStyle: _currentLineStyle);

  @override
  Widget getDrawingToolOptions() => Column(
    children: <Widget>[_buildColorField()],
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
      _lineStyle ?? (widget.config as DoodleDrawingToolConfig).lineStyle;
}
