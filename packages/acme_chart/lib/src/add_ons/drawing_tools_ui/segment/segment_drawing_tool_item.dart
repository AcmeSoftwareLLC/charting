import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/segment/segment_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Segment drawing tool item in the list of drawing tools which provide this
/// drawing tools options menu.
class SegmentDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const SegmentDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    SegmentDrawingToolConfig super.config = const SegmentDrawingToolConfig(),
  }) : super(title: 'Segment');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      SegmentDrawingToolItemState();
}

/// SegmentDrawingToolItem State class
class SegmentDrawingToolItemState
    extends DrawingToolItemState<SegmentDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  SegmentDrawingToolConfig createDrawingToolConfig() =>
      SegmentDrawingToolConfig(
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

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
      _lineStyle ?? (widget.config as SegmentDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as SegmentDrawingToolConfig).pattern;
}
