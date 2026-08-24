// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fib_retracement_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FibRetracementDrawingToolConfig _$FibRetracementDrawingToolConfigFromJson(
  Map<String, dynamic> json,
) => FibRetracementDrawingToolConfig(
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
      ? const TextStyle(fontSize: 11, color: Colors.white)
      : const TextStyleJsonConverter().fromJson(
          json['labelStyle'] as Map<String, dynamic>,
        ),
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FibRetracementDrawingToolConfigToJson(
  FibRetracementDrawingToolConfig instance,
) => <String, dynamic>{
  'configId': instance.configId,
  'number': instance.number,
  'drawingData': instance.drawingData,
  'edgePoints': instance.edgePoints,
  'lineStyle': instance.lineStyle,
  'fillStyle': instance.fillStyle,
  'labelStyle': const TextStyleJsonConverter().toJson(instance.labelStyle),
};
