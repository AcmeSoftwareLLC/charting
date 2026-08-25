import 'package:acme_chart/acme_chart.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/helpers/text_style_json_converter.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'trend_drawing_tool_config.g.dart';

/// Trend drawing tool configurations.
///
/// Placed exactly like [LineDrawingToolConfig]/[SegmentDrawingToolConfig] —
/// a straight line bounded strictly between its two points, not extended
/// beyond them — via [TrendLineInteractableDrawing], which renders,
/// hit-tests, and drags it, and additionally shows the
/// price/percent/bar-count readout on hover or selection plus its own
/// Y-axis value labels.
///
/// Deliberately extends [DrawingToolConfig] directly rather than
/// [LineDrawingToolConfig] (even though [TrendLineInteractableDrawing] used
/// to be handed a [LineDrawingToolConfig] built from this class's fields):
/// [LineDrawingToolConfig] itself extends [SegmentDrawingToolConfig], whose
/// `getInteractableDrawing()` is declared to return [SegmentInteractableDrawing]
/// — and Dart's covariant-override rule then forces *every* subclass
/// override (including this one, transitively) to also return a
/// [SegmentInteractableDrawing] subtype. [TrendLineInteractableDrawing] was
/// never built as one (it has its own independent drag/hit-test
/// implementation, predating [SegmentInteractableDrawing]), so that
/// inheritance path is a dead end without a much larger rewrite.
///
/// Instead, identity is preserved the same way
/// [MeasureDrawingToolConfig]/[LineDrawingToolConfig] do it, just anchored
/// one level down: [TrendLineInteractableDrawing] is declared as
/// `InteractableDrawing<TrendDrawingToolConfig>` directly (not
/// `<LineDrawingToolConfig>`), and [getInteractableDrawing] hands `this`
/// straight to it instead of constructing a throwaway
/// [LineDrawingToolConfig]. That means `config`'s type — both static *and*
/// runtime — genuinely is [TrendDrawingToolConfig], so
/// [TrendLineInteractableDrawing.getUpdatedConfig]'s `config.copyWith(...)`
/// call now returns a real [TrendDrawingToolConfig] (name `dt_trend`) every
/// time. Previously it silently returned a plain [LineDrawingToolConfig]
/// (`dt_line`) on the very first drag or placement-completion, permanently
/// swapping this bounded-with-readout "Trend" drawing for the
/// extend-to-edges, no-readout "Line" behavior on the next reload/sync —
/// invisible before "Line" got its own distinct rendering, and a real,
/// visible regression once it did.
@JsonSerializable()
class TrendDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const TrendDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.labelStyle = const TextStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontFamily: 'Inter',
    ),
    this.pattern = DrawingPatterns.solid,
    super.number,
  });

  /// Initializes from JSON.
  factory TrendDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$TrendDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_trend';

  @override
  Map<String, dynamic> toJson() =>
      _$TrendDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

  /// The style of the price/percent/bar-count readout pill and the Y-axis
  /// value labels [TrendLineInteractableDrawing] paints.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => TrendDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  TrendDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? fillStyle,
    LineStyle? lineStyle,
    TextStyle? labelStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => TrendDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    fillStyle: fillStyle ?? this.fillStyle,
    lineStyle: lineStyle ?? this.lineStyle,
    labelStyle: labelStyle ?? this.labelStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  TrendLineInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => TrendLineInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints.first : null,
    endPoint: edgePoints.isNotEmpty ? edgePoints.last : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
