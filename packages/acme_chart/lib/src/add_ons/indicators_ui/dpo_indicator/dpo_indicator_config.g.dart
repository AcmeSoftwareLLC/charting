// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dpo_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DPOIndicatorConfig _$DPOIndicatorConfigFromJson(Map<String, dynamic> json) =>
    DPOIndicatorConfig(
      period: (json['period'] as num?)?.toInt() ?? 14,
      movingAverageType:
          $enumDecodeNullable(
            _$MovingAverageTypeEnumMap,
            json['movingAverageType'],
          ) ??
          MovingAverageType.simple,
      fieldType: json['fieldType'] as String? ?? 'close',
      isCentered: json['isCentered'] as bool? ?? true,
      lineStyle: json['lineStyle'] == null
          ? null
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pipSize: (json['pipSize'] as num?)?.toInt() ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: (json['number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DPOIndicatorConfigToJson(
  DPOIndicatorConfig instance,
) => <String, dynamic>{
  'number': instance.number,
  'showLastIndicator': instance.showLastIndicator,
  'pipSize': instance.pipSize,
  'period': instance.period,
  'movingAverageType': _$MovingAverageTypeEnumMap[instance.movingAverageType]!,
  'fieldType': instance.fieldType,
  'lineStyle': instance.lineStyle,
  'title': instance.title,
  'isCentered': instance.isCentered,
};

const _$MovingAverageTypeEnumMap = {
  MovingAverageType.simple: 'simple',
  MovingAverageType.exponential: 'exponential',
  MovingAverageType.weighted: 'weighted',
  MovingAverageType.hull: 'hull',
  MovingAverageType.zeroLag: 'zeroLag',
  MovingAverageType.timeSeries: 'timeSeries',
  MovingAverageType.wellesWilder: 'wellesWilder',
  MovingAverageType.variable: 'variable',
  MovingAverageType.triangular: 'triangular',
  MovingAverageType.doubleExponential: 'doubleExponential',
  MovingAverageType.tripleExponential: 'tripleExponential',
};
