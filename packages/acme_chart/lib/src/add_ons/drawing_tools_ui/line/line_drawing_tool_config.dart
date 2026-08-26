import 'package:acme_chart/acme_chart.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_item.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_label_painter.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:acme_chart/src/core/interactive_layer/drawing_context.dart';
import 'package:acme_chart/src/core/interactive_layer/helpers/types.dart';
import 'package:acme_chart/src/core/chart/helpers/text_style_json_converter.dart';
import 'package:acme_chart/src/core/interactive_layer/interactable_drawings/line/line_interactable_drawing.dart';
import 'package:acme_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_drawing_tool_config.g.dart';

/// Line drawing tool config.
///
/// Placed with two anchors exactly like [SegmentDrawingToolConfig] (same
/// fields, same hit-test/drag/toolbar/hover-or-selected measurement label,
/// via [LineInteractableDrawing] extending [SegmentInteractableDrawing]) —
/// but unlike a Segment, the rendered/clickable line extends past both
/// anchors to the chart's edges, the way Horizontal/Vertical extend across
/// their one dimension. [LineInteractableDrawing] shows no Y-axis value
/// label of its own; that's [TrendDrawingToolConfig]'s addition, described
/// below.
///
/// [overlayStyle] is this codebase's own addition — legacy (pre-V2) overlay
/// styling for [getLabelPainter]. Note [TrendDrawingToolConfig] is a
/// *separate*, unrelated config class (not a subclass of this one) with its
/// own `labelStyle` field for [TrendLineInteractableDrawing]'s Y-axis value
/// labels and price/percent/bar-count readout — see that class's doc
/// comment for why it can't share this class's hierarchy.
@JsonSerializable()
class LineDrawingToolConfig extends SegmentDrawingToolConfig {
  /// Initializes
  const LineDrawingToolConfig({
    super.configId,
    super.drawingData,
    super.edgePoints = const <EdgePoint>[],
    super.lineStyle = const LineStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
    ),
    this.labelStyle = const TextStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontFamily: 'Inter',
    ),
    this.overlayStyle,
    super.pattern = DrawingPatterns.solid,
    super.number,
  });

  /// Initializes from JSON.
  factory LineDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$LineDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_line';

  @override
  Map<String, dynamic> toJson() =>
      _$LineDrawingToolConfigToJson(this)
        ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// The style of the label showing on y-axis. Only consumed by
  /// [TrendLineInteractableDrawing] (via [TrendDrawingToolConfig]) — see
  /// the class doc comment above.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  /// Drawing tool overlay style
  @JsonKey(fromJson: _overlayStyleFromJson, toJson: _overlayStyleToJson)
  final OverlayStyle? overlayStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) => LineDrawingToolItem(
    config: this,
    updateDrawingTool: updateDrawingTool,
    deleteDrawingTool: deleteDrawingTool,
  );

  @override
  LineDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    TextStyle? labelStyle,
    OverlayStyle? overlayStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) => LineDrawingToolConfig(
    configId: configId ?? this.configId,
    drawingData: drawingData ?? this.drawingData,
    lineStyle: lineStyle ?? this.lineStyle,
    labelStyle: labelStyle ?? this.labelStyle,
    overlayStyle: overlayStyle ?? this.overlayStyle,
    pattern: pattern ?? this.pattern,
    edgePoints: edgePoints ?? this.edgePoints,
    number: number ?? this.number,
  );

  @override
  LineDrawingToolLabelPainter? getLabelPainter({
    required Point startPoint,
    required Point endPoint,
  }) {
    if (kIsWeb) {
      return null;
    } else {
      return MobileLineDrawingToolLabelPainter(
        this,
        startPoint: startPoint,
        endPoint: endPoint,
      );
    }
  }

  static OverlayStyle? _overlayStyleFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return OverlayStyle(color: Color(json['color'] as int));
  }

  static Map<String, dynamic>? _overlayStyleToJson(OverlayStyle? instance) {
    if (instance == null) {
      return null;
    }
    return {'color': instance.color.toARGB32()};
  }

  @override
  LineInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) => LineInteractableDrawing(
    config: this,
    startPoint: edgePoints.isNotEmpty ? edgePoints.first : null,
    endPoint: edgePoints.isNotEmpty ? edgePoints.last : null,
    drawingContext: drawingContext,
    getDrawingState: getDrawingState,
  );

  static OverlayStyle? _overlayStyleFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return OverlayStyle(color: Color(json['color'] as int));
  }

  static Map<String, dynamic>? _overlayStyleToJson(OverlayStyle? instance) {
    if (instance == null) {
      return null;
    }
    return {'color': instance.color.toARGB32()};
  }
}
