// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GatorIndicatorConfig _$GatorIndicatorConfigFromJson(
  Map<String, dynamic> json,
) => GatorIndicatorConfig(
  jawPeriod: (json['jawPeriod'] as num?)?.toInt() ?? 13,
  teethPeriod: (json['teethPeriod'] as num?)?.toInt() ?? 8,
  lipsPeriod: (json['lipsPeriod'] as num?)?.toInt() ?? 5,
  jawOffset: (json['jawOffset'] as num?)?.toInt() ?? 8,
  teethOffset: (json['teethOffset'] as num?)?.toInt() ?? 5,
  lipsOffset: (json['lipsOffset'] as num?)?.toInt() ?? 3,
  barStyle: json['barStyle'] == null
      ? const BarStyle()
      : BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
  pipSize: (json['pipSize'] as num?)?.toInt() ?? 4,
  title: json['title'] as String?,
  number: (json['number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GatorIndicatorConfigToJson(
  GatorIndicatorConfig instance,
) => <String, dynamic>{
  'number': instance.number,
  'title': instance.title,
  'pipSize': instance.pipSize,
  'jawOffset': instance.jawOffset,
  'jawPeriod': instance.jawPeriod,
  'teethOffset': instance.teethOffset,
  'teethPeriod': instance.teethPeriod,
  'lipsOffset': instance.lipsOffset,
  'lipsPeriod': instance.lipsPeriod,
  'barStyle': instance.barStyle,
};
