import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/fib_retracement/fib_retracement_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// FibRetracement drawing tool item in the list of drawing tools
class FibRetracementDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const FibRetracementDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    FibRetracementDrawingToolConfig super.config =
        const FibRetracementDrawingToolConfig(),
  }) : super(title: 'Fib Retracement');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      FibRetracementDrawingToolItemState();
}

/// FibRetracementDrawingToolItem State class
class FibRetracementDrawingToolItemState
    extends DrawingToolItemState<FibRetracementDrawingToolConfig> {
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;

  @override
  FibRetracementDrawingToolConfig createDrawingToolConfig() =>
      FibRetracementDrawingToolConfig(
        fillStyle: _currentFillStyle,
        lineStyle: _currentLineStyle,
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
      _fillStyle ?? (widget.config as FibRetracementDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as FibRetracementDrawingToolConfig).lineStyle;
}
