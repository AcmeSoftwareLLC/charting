import 'package:acme_chart/acme_chart.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/measure/measure_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/measure/measure_interactable_drawing.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'measure_drawing_tool_config.g.dart';

/// Measure drawing tool config.
///
/// Matches ChartIQ's `measure` tool: it's placed exactly like
/// [SegmentDrawingToolConfig] (a bounded line between two points, same
/// [lineStyle]/[pattern] fields, inherited rather than duplicated), and it
/// renders/hit-tests/drags exactly like one too, via
/// [MeasureInteractableDrawing] extending [SegmentInteractableDrawing].
///
/// Unlike an earlier version of this tool, the "measure" identity is *not*
/// discarded once placed — [name] stays `dt_measure` through
/// [getUpdatedConfig]/persistence/reload, specifically so
/// [MeasureInteractableDrawing]'s price-difference / percentage-change /
/// bar-count label keeps showing on hover or selection after placement, not
/// just during the initial drawing gesture. Extending
/// [SegmentDrawingToolConfig] (rather than [DrawingToolConfig] directly) is
/// what makes this possible without duplicating any of Segment's config
/// fields or interactable-drawing logic: [MeasureInteractableDrawing]
/// inherits `getUpdatedConfig() => config.copyWith(...)` from
/// [SegmentInteractableDrawing] unmodified, and since `config`'s *runtime*
/// type is this class, Dart's dynamic dispatch calls this class's own
/// [copyWith] override — producing a genuine [MeasureDrawingToolConfig]
/// each time, even though the inherited method's *static* return type is
/// [SegmentDrawingToolConfig].
@JsonSerializable()
class MeasureDrawingToolConfig extends SegmentDrawingToolConfig {
  /// Initializes
  const MeasureDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    super.lineStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    super.pattern = DrawingPatterns.solid,
    super.number,
  });

  /// Initializes from JSON.
  factory MeasureDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$MeasureDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_measure';

  @override
  Map<String, dynamic> toJson() =>
      _$MeasureDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => MeasureDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  MeasureDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => MeasureDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  MeasureInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => MeasureInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
    endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
