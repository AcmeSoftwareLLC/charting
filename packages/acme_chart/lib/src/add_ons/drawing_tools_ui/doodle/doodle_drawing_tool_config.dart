import 'package:acme_chart/acme_chart.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/doodle/doodle_drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/doodle/doodle_interactable_drawing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

part 'doodle_drawing_tool_config.g.dart';

/// Doodle drawing tool config.
///
/// A doodle (a.k.a. freeform) is a freehand stroke drawn by dragging across
/// the chart. Unlike the other tools it isn't defined by a small, fixed
/// number of points — [edgePoints] holds every point sampled along the drag.
@JsonSerializable()
class DoodleDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const DoodleDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.lineStyle = const LineStyle(thickness: 2, color: Colors.blue),
    super.number,
  });

  /// Initializes from JSON.
  factory DoodleDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$DoodleDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_doodle';

  @override
  Map<String, dynamic> toJson() =>
      _$DoodleDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => DoodleDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  DoodleDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => DoodleDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  DoodleInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => DoodleInteractableDrawing(
    config: this,
    points: List<EdgePoint>.of(edgePoints),
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
