// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendDrawingToolConfig _$TrendDrawingToolConfigFromJson(
  Map<String, dynamic> json,
) => TrendDrawingToolConfig(
  configId: json['configId'] as String?,
  drawingData: json['drawingData'] == null
      ? null
      : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
  edgePoints:
      (json['edgePoints'] as List<dynamic>?)
          ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EdgePoint>[],
  fillStyle: json['fillStyle'] == null
      ? const LineStyle(thickness: 0.9, color: Colors.blue)
      : LineStyle.fromJson(json['fillStyle'] as Map<String, dynamic>),
  lineStyle: json['lineStyle'] == null
      ? const LineStyle(thickness: 0.9, color: Colors.white)
      : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  labelStyle: json['labelStyle'] == null
      ? const TextStyle(
          color: CoreDesignTokens.coreColorSolidBlue700,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        )
      : const TextStyleJsonConverter().fromJson(
          json['labelStyle'] as Map<String, dynamic>,
        ),
  pattern:
      $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
      DrawingPatterns.solid,
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TrendDrawingToolConfigToJson(
  TrendDrawingToolConfig instance,
) => <String, dynamic>{
  'configId': instance.configId,
  'number': instance.number,
  'drawingData': instance.drawingData,
  'edgePoints': instance.edgePoints,
  'fillStyle': instance.fillStyle,
  'lineStyle': instance.lineStyle,
  'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
  'labelStyle': const TextStyleJsonConverter().toJson(instance.labelStyle),
};

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
