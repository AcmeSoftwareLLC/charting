import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/trade_ratio/trade_ratio_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';

import 'package:flutter/material.dart';

import '../drawing_tool_item.dart';

/// Trade ratio drawing tool item in the list of drawing tool which provide
/// this drawing tools options menu.
class TradeRatioDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const TradeRatioDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    TradeRatioDrawingToolConfig super.config =
        const TradeRatioDrawingToolConfig(),
  }) : super(title: 'Trade Ratio');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      TradeRatioDrawingToolItemState();
}

/// Trade ratio drawing tool Item State class
class TradeRatioDrawingToolItemState
    extends DrawingToolItemState<TradeRatioDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  TradeRatioDrawingToolConfig createDrawingToolConfig() =>
      TradeRatioDrawingToolConfig(
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
        levels: (widget.config as TradeRatioDrawingToolConfig).levels,
        levelColors: (widget.config as TradeRatioDrawingToolConfig).levelColors,
        labelStyle: (widget.config as TradeRatioDrawingToolConfig).labelStyle,
        extendLeft: (widget.config as TradeRatioDrawingToolConfig).extendLeft,
        farXEpochOffset:
            (widget.config as TradeRatioDrawingToolConfig).farXEpochOffset,
      );

  @override
  Widget getDrawingToolOptions() => Column(
    children: <Widget>[
      _buildColorField(
        ChartLocalization.of(context).labelColor,
        _currentLineStyle,
      ),
      // TODO(NA): implement per-level color editing and _buildPatternField()
    ],
  );

  Widget _buildColorField(String label, LineStyle style) => Row(
    children: <Widget>[
      Text(label, style: const TextStyle(fontSize: 16)),
      ColorSelector(
        currentColor: style.color,
        onColorChanged: (Color selectedColor) {
          setState(() {
            _lineStyle = style.copyWith(color: selectedColor);
          });
          updateDrawingTool();
        },
      ),
    ],
  );

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as TradeRatioDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as TradeRatioDrawingToolConfig).pattern;
}
