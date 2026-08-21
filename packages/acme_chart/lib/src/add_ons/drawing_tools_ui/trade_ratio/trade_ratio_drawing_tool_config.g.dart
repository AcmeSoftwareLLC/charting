// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_ratio_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradeRatioDrawingToolConfig _$TradeRatioDrawingToolConfigFromJson(
  Map<String, dynamic> json,
) => TradeRatioDrawingToolConfig(
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
      ? const LineStyle(thickness: 0.9, color: Colors.blue)
      : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  pattern:
      $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
      DrawingPatterns.solid,
  levels:
      (json['levels'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      defaultTradeRatioLevels,
  levelColors: json['levelColors'] == null
      ? defaultTradeRatioLevelColors
      : const ColorListConverter().fromJson(json['levelColors'] as List),
  labelStyle: json['labelStyle'] == null
      ? const TextStyle(fontSize: 11)
      : const TextStyleJsonConverter().fromJson(
          json['labelStyle'] as Map<String, dynamic>,
        ),
  extendLeft: json['extendLeft'] as bool? ?? false,
  farXEpochOffset: (json['farXEpochOffset'] as num?)?.toInt(),
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TradeRatioDrawingToolConfigToJson(
  TradeRatioDrawingToolConfig instance,
) => <String, dynamic>{
  'configId': instance.configId,
  'number': instance.number,
  'drawingData': instance.drawingData,
  'edgePoints': instance.edgePoints,
  'lineStyle': instance.lineStyle,
  'fillStyle': instance.fillStyle,
  'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
  'levels': instance.levels,
  'levelColors': const ColorListConverter().toJson(instance.levelColors),
  'labelStyle': const TextStyleJsonConverter().toJson(instance.labelStyle),
  'extendLeft': instance.extendLeft,
  'farXEpochOffset': instance.farXEpochOffset,
};

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
