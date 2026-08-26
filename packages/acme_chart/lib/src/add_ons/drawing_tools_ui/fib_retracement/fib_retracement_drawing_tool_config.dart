import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:acme_chart/src/core/chart/helpers/text_style_json_converter.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/fib_retracement/fib_retracement_interactable_drawing.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fib_retracement_drawing_tool_item.dart';

part 'fib_retracement_drawing_tool_config.g.dart';

/// Fibonacci retracement drawing tool config.
@JsonSerializable()
class FibRetracementDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const FibRetracementDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.labelStyle = const TextStyle(fontSize: 11, color: Colors.blue),
    super.number,
  });

  /// Initializes from JSON.
  factory FibRetracementDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$FibRetracementDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_fib_retracement';

  @override
  Map<String, dynamic> toJson() =>
      _$FibRetracementDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Text style for each level's percentage label.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => FibRetracementDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  FibRetracementDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    TextStyle? labelStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => FibRetracementDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    fillStyle: fillStyle ?? this.fillStyle,
    labelStyle: labelStyle ?? this.labelStyle,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  FibRetracementInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => FibRetracementInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
    endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
