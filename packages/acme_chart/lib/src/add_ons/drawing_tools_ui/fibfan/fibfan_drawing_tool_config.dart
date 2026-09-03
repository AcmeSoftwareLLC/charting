import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:acme_chart/src/core/chart/helpers/text_style_json_converter.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/fibfan/fibfan_interactable_drawing.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fibfan_drawing_tool_item.dart';

part 'fibfan_drawing_tool_config.g.dart';

/// Fibfan drawing tool config
@JsonSerializable()
class FibfanDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const FibfanDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.labelStyle = const TextStyle(fontSize: 11, color: Colors.white),
    super.number,
  });

  /// Initializes from JSON.
  factory FibfanDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$FibfanDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_fibfan';

  @override
  Map<String, dynamic> toJson() =>
      _$FibfanDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Text style for each ray's percentage label.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => FibfanDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  FibfanDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    TextStyle? labelStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => FibfanDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    fillStyle: fillStyle ?? this.fillStyle,
    labelStyle: labelStyle ?? this.labelStyle,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  FibfanInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => FibfanInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
    endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
