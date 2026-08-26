// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotesDrawingToolConfig _$NotesDrawingToolConfigFromJson(
  Map<String, dynamic> json,
) => NotesDrawingToolConfig(
  configId: json['configId'] as String?,
  drawingData: json['drawingData'] == null
      ? null
      : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
  edgePoints:
      (json['edgePoints'] as List<dynamic>?)
          ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EdgePoint>[],
  text: json['text'] as String? ?? '',
  lineStyle: json['lineStyle'] == null
      ? const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700)
      : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  fillStyle: json['fillStyle'] == null
      ? const LineStyle(color: Colors.white)
      : LineStyle.fromJson(json['fillStyle'] as Map<String, dynamic>),
  textStyle: json['textStyle'] == null
      ? const TextStyle(color: Colors.black87, fontSize: 12)
      : const TextStyleJsonConverter().fromJson(
          json['textStyle'] as Map<String, dynamic>,
        ),
  pattern:
      $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
      DrawingPatterns.solid,
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NotesDrawingToolConfigToJson(
  NotesDrawingToolConfig instance,
) => <String, dynamic>{
  'configId': instance.configId,
  'number': instance.number,
  'drawingData': instance.drawingData,
  'edgePoints': instance.edgePoints,
  'text': instance.text,
  'lineStyle': instance.lineStyle,
  'fillStyle': instance.fillStyle,
  'textStyle': const TextStyleJsonConverter().toJson(instance.textStyle),
  'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
  'width': instance.width,
  'height': instance.height,
};

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
