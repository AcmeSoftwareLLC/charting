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
/// [SegmentDrawingToolConfig] (a bounded line between two points), and while
/// being placed it shows a live label with the price difference, percentage
/// change, and bar count between the two points. Once placed, the "measure"
/// identity is discarded — [getInteractableDrawing] hands the drawing off to
/// [SegmentDrawingToolConfig]'s own interactable, so the finished result is
/// a plain segment with no persisted label, indistinguishable from one drawn
/// with the Segment tool.
@JsonSerializable()
class MeasureDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const MeasureDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.pattern = DrawingPatterns.solid,
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

  /// Line style used both for the in-progress preview and for the segment
  /// this measurement becomes once placed.
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

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
  ) {
    // The measurement is never actually persisted as its own type — the
    // moment it's placed it becomes a real segment (see class doc), so the
    // interactable is built on top of a genuine [SegmentDrawingToolConfig]
    // right from the start.
    final SegmentDrawingToolConfig segmentConfig = SegmentDrawingToolConfig(
      lineStyle: lineStyle,
      pattern: pattern,
      edgePoints: edgePoints,
    );

    return MeasureInteractableDrawing(
      config: segmentConfig,
      startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
      endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
      drawingContext: drawingContext,
      getDrawingState: getDrawingState,
    );
  }
}
