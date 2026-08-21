import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/ellipse/ellipse_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/ellipse/ellipse_interactable_drawing.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'ellipse_drawing_tool_config.g.dart';

/// Ellipse drawing tool config
@JsonSerializable()
class EllipseDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const EllipseDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.pattern = DrawingPatterns.solid,
    super.number,
  });

  /// Initializes from JSON.
  factory EllipseDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$EllipseDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_ellipse';

  @override
  Map<String, dynamic> toJson() =>
      _$EllipseDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(NA): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => EllipseDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  EllipseDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => EllipseDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    fillStyle: fillStyle ?? this.fillStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  EllipseInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => EllipseInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints[0] : null,
    endPoint: edgePoints.length > 1 ? edgePoints[1] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
