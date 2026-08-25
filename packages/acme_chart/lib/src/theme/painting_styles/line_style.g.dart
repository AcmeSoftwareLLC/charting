// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStyle _$LineStyleFromJson(Map<String, dynamic> json) => LineStyle(
  color: json['color'] == null
      ? const Color(0xFF85ACB0)
      : const ColorConverter().fromJson((json['color'] as num).toInt()),
  thickness: (json['thickness'] as num?)?.toDouble() ?? 1,
  hasArea: json['hasArea'] as bool? ?? false,
  markerRadius: (json['markerRadius'] as num?)?.toDouble() ?? 4,
  areaGradientColors:
      _$recordConvert(
        json['areaGradientColors'],
        ($jsonValue) => (
          end: const ColorConverter().fromJson(
            ($jsonValue['end'] as num).toInt(),
          ),
          start: const ColorConverter().fromJson(
            ($jsonValue['start'] as num).toInt(),
          ),
        ),
      ) ??
      (start: Color(0x29000000), end: Color(0x00000000)),
);

Map<String, dynamic> _$LineStyleToJson(LineStyle instance) => <String, dynamic>{
  'color': const ColorConverter().toJson(instance.color),
  'thickness': instance.thickness,
  'hasArea': instance.hasArea,
  'markerRadius': instance.markerRadius,
  'areaGradientColors': <String, dynamic>{
    'end': const ColorConverter().toJson(instance.areaGradientColors.end),
    'start': const ColorConverter().toJson(instance.areaGradientColors.start),
  },
};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);
