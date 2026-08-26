import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/notes/notes_drawing_tool_item.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:acme_chart/src/core/chart/helpers/text_style_json_converter.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/notes/notes_interactable_drawing.dart';
import 'package:acme_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'notes_drawing_tool_config.g.dart';

/// Notes drawing tool configurations.
///
/// Pins a short text note to a single epoch/quote on the chart, rendered as
/// a bordered, filled text box.
@JsonSerializable()
class NotesDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const NotesDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    this.text = '',
    this.lineStyle = const LineStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
    ),
    this.fillStyle = const LineStyle(color: Colors.white),
    this.textStyle = const TextStyle(color: Colors.black87, fontSize: 12),
    this.pattern = DrawingPatterns.solid,
    this.width,
    this.height,
    super.number,
  });

  /// Initializes from JSON.
  factory NotesDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$NotesDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_notes';

  @override
  Map<String, dynamic> toJson() =>
      _$NotesDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// The note's text content.
  final String text;

  /// Border style of the note box.
  final LineStyle lineStyle;

  /// Background fill style of the note box.
  final LineStyle fillStyle;

  /// Text style of the note's content.
  @TextStyleJsonConverter()
  final TextStyle textStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(NA): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  /// The note box's width, in pixels, once the user has resized it.
  ///
  /// `null` means the box auto-sizes to fit [text].
  final double? width;

  /// The note box's height, in pixels, once the user has resized it.
  ///
  /// `null` means the box auto-sizes to fit [text].
  final double? height;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => NotesDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  NotesDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
    String? text,
    TextStyle? textStyle,
    double? width,
    double? height,
  }) => NotesDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    text: text ?? this.text,
    lineStyle: lineStyle ?? this.lineStyle,
    fillStyle: fillStyle ?? this.fillStyle,
    textStyle: textStyle ?? this.textStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
    width: width ?? this.width,
    height: height ?? this.height,
  );

  @override
  NotesInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => NotesInteractableDrawing(
    config: this,
    position: edgePoints.isNotEmpty ? edgePoints[0] : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );
}
