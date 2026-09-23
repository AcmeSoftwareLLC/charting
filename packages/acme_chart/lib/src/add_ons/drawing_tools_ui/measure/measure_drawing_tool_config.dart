import 'package:acme_chart/acme_chart.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/measure/measure_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/measure/measure_interactable_drawing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

part 'measure_drawing_tool_config.g.dart';

/// Measure drawing tool config.
///
/// Extends [SegmentDrawingToolConfig] rather than [DrawingToolConfig]
/// directly, so it's placed, rendered, hit-tested, and dragged exactly like
/// a segment ([MeasureInteractableDrawing] extends
/// [SegmentInteractableDrawing]), without duplicating any of Segment's
/// fields or logic.
///
/// Unlike an earlier version of this tool, the "measure" identity is *not*
/// discarded once placed — [name] stays `dt_measure` through
/// [getUpdatedConfig]/persistence/reload, since `config`'s *runtime* type
/// stays this class and Dart's dynamic dispatch calls this class's own
/// [copyWith] override. So a reloaded drawing is still a measure drawing,
/// and placing it again keeps [MeasureInteractableDrawing]'s live
/// placement-time label. (The price-difference / percentage-change /
/// bar-count readout for a *placed* drawing is the embedding app's, drawn
/// in its chart HUD, not on the canvas.)
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
