import 'package:acme_chart/acme_chart.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/segment/segment_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/segment/segment_interactable_drawing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

part 'segment_drawing_tool_config.g.dart';

/// Segment drawing tool config.
///
/// A segment is a straight line bounded strictly between its two placed
/// points, unlike [LineDrawingToolConfig] extends indefinitely - it does
/// not extend beyond the points it was drawn with.
@JsonSerializable()
class SegmentDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const SegmentDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.pattern = DrawingPatterns.solid,
    super.number,
  });

  /// Initializes from JSON.
  factory SegmentDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$SegmentDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_segment';

  @override
  Map<String, dynamic> toJson() =>
      _$SegmentDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => SegmentDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  SegmentDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => SegmentDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  SegmentInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => SegmentInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
    endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
