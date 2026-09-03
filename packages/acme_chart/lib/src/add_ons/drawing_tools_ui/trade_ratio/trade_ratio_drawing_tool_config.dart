import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/trade_ratio/trade_ratio_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:acme_chart/src/core/chart/helpers/color_converter.dart';
import 'package:acme_chart/src/core/chart/helpers/text_style_json_converter.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/trade_ratio/trade_ratio_interactable_drawing.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'trade_ratio_drawing_tool_config.g.dart';

/// Default percentage levels projected from the anchor segment.
const List<double> defaultTradeRatioLevels = <double>[-200, 0, 100, 200];

/// Default per-level colors, matched by index to [defaultTradeRatioLevels].
const List<Color> defaultTradeRatioLevelColors = <Color>[
  Color(0xFFFF0000), // -200%
  Color(0xFFFFBC00), //    0%
  Color(0xFF90EE90), //  100%
  Color(0xFF9E9E9E), //  200%
];

/// Trade ratio drawing tool config.
///
/// Anchors two points defining a base price span, then projects a set of
/// percentage levels of that span as horizontal lines across the chart,
/// matching ChartIQ's `retracement` tool: 0% sits at the start anchor (the
/// entry), positive percentages extend past the start anchor away from the
/// end anchor (e.g. 100% is one full span beyond the start, on the opposite
/// side from the end anchor), and negative percentages extend past the end
/// anchor instead, continuing in the same direction as the start->end move.
@JsonSerializable()
class TradeRatioDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const TradeRatioDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.pattern = DrawingPatterns.solid,
    this.levels = defaultTradeRatioLevels,
    this.levelColors = defaultTradeRatioLevelColors,
    this.labelStyle = const TextStyle(fontSize: 11),
    this.extendLeft = false,
    this.farXEpochOffset,
    super.number,
  });

  /// Initializes from JSON.
  factory TradeRatioDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$TradeRatioDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_trade_ratio';

  @override
  Map<String, dynamic> toJson() =>
      _$TradeRatioDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Style of the diagonal line connecting the two anchor points.
  final LineStyle lineStyle;

  /// Unused by this tool; kept for parity with the shared `copyWith` surface
  /// other drawing tools use.
  final LineStyle fillStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(NA): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  /// The percentage levels of the anchor span to project as horizontal
  /// lines, e.g. `100` projects a line one full span past the start point,
  /// on the opposite side from the end point.
  final List<double> levels;

  /// The color for each entry in [levels], matched by index. If shorter than
  /// [levels], colors repeat from the start.
  @ColorListConverter()
  final List<Color> levelColors;

  /// Text style for each level's price/delta/percentage label.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  /// Whether level lines are pinned to the chart's left edge instead of
  /// starting where they cross the (possibly extrapolated) diagonal anchor
  /// line.
  final bool extendLeft;

  /// How far (in epoch milliseconds) past the start anchor's epoch the
  /// level lines' shared far (right) edge sits, once the user has dragged
  /// the far-edge handle. `null` means "use the default, modest on-screen
  /// width" (the default, before any dragging).
  final int? farXEpochOffset;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => TradeRatioDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  TradeRatioDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
    List<double>? levels,
    List<Color>? levelColors,
    TextStyle? labelStyle,
    bool? extendLeft,
    int? farXEpochOffset,
  }) => TradeRatioDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    fillStyle: fillStyle ?? this.fillStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
    levels: levels ?? this.levels,
    levelColors: levelColors ?? this.levelColors,
    labelStyle: labelStyle ?? this.labelStyle,
    extendLeft: extendLeft ?? this.extendLeft,
    farXEpochOffset: farXEpochOffset ?? this.farXEpochOffset,
  );

  @override
  TradeRatioInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => TradeRatioInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
    endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
