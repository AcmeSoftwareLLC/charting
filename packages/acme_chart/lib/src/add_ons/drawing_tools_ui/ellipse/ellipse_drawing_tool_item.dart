import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/ellipse/ellipse_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';

import 'package:flutter/material.dart';

import '../drawing_tool_item.dart';

/// Ellipse drawing tool item in the list of drawing tool which provide this
/// drawing tools options menu.
class EllipseDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const EllipseDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    EllipseDrawingToolConfig super.config = const EllipseDrawingToolConfig(),
  }) : super(title: 'Ellipse');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      EllipseDrawingToolItemState();
}

/// Ellipse drawing tool Item State class
class EllipseDrawingToolItemState
    extends DrawingToolItemState<EllipseDrawingToolConfig> {
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  EllipseDrawingToolConfig createDrawingToolConfig() =>
      EllipseDrawingToolConfig(
        fillStyle: _currentFillStyle,
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() => Column(
    children: <Widget>[
      _buildColorField(
        ChartLocalization.of(context).labelColor,
        _currentLineStyle,
      ),
      _buildColorField(
        ChartLocalization.of(context).labelFillColor,
        _currentFillStyle,
      ),
      // TODO(NA): implement _buildPatternField() to set pattern
    ],
  );
  Widget _buildColorField(String label, LineStyle style) => Row(
    children: <Widget>[
      Text(label, style: const TextStyle(fontSize: 16)),
      ColorSelector(
        currentColor: style.color,
        onColorChanged: (Color selectedColor) {
          setState(() {
            final LineStyle newColor = style.copyWith(color: selectedColor);
            if (label == ChartLocalization.of(context).labelColor) {
              _lineStyle = newColor;
            } else {
              _fillStyle = newColor;
            }
          });
          updateDrawingTool();
        },
      ),
    ],
  );

  LineStyle get _currentFillStyle =>
      _fillStyle ?? (widget.config as EllipseDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as EllipseDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as EllipseDrawingToolConfig).pattern;
}
