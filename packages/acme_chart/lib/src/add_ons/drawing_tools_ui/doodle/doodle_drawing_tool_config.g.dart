// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doodle_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoodleDrawingToolConfig _$DoodleDrawingToolConfigFromJson(
  Map<String, dynamic> json,
) => DoodleDrawingToolConfig(
  configId: json['configId'] as String?,
  drawingData: json['drawingData'] == null
      ? null
      : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
  edgePoints:
      (json['edgePoints'] as List<dynamic>?)
          ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EdgePoint>[],
  lineStyle: json['lineStyle'] == null
      ? const LineStyle(thickness: 2, color: Colors.blue)
      : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DoodleDrawingToolConfigToJson(
  DoodleDrawingToolConfig instance,
) => <String, dynamic>{
  'configId': instance.configId,
  'number': instance.number,
  'drawingData': instance.drawingData,
  'edgePoints': instance.edgePoints,
  'lineStyle': instance.lineStyle,
};
