import 'package:acme_chart/src/core/chart/data_visualization/chart_series/indicators_series/macd_series.dart';
import 'package:acme_chart/src/core/chart/data_visualization/chart_series/indicators_series/models/macd_options.dart';
import 'package:acme_chart/src/core/chart/data_visualization/chart_series/series.dart';
import 'package:acme_chart/src/models/indicator_input.dart';
import 'package:acme_chart/src/theme/painting_styles/bar_style.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'macd_indicator_item.dart';

part 'macd_indicator_config.g.dart';

/// MACD Indicator Config
@JsonSerializable()
class MACDIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const MACDIndicatorConfig({
    this.fastMAPeriod = 12,
    this.slowMAPeriod = 26,
    this.signalPeriod = 9,
    this.barStyle = const BarStyle(),
    this.lineStyle = const LineStyle(color: Colors.white),
    this.signalLineStyle = const LineStyle(color: Colors.redAccent),
    super.pipSize,
    super.showLastIndicator,
    String? title,
    super.number,
  }) : super(
          isOverlay: false,
          title: title ?? MACDIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory MACDIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$MACDIndicatorConfigFromJson(json);

  @override
  Series getSeries(IndicatorInput indicatorInput) => MACDSeries(
        indicatorInput,
        config: this,
        options: MACDOptions(
          fastMAPeriod: fastMAPeriod,
          slowMAPeriod: slowMAPeriod,
          signalPeriod: signalPeriod,
          barStyle: barStyle,
          lineStyle: lineStyle,
          signalLineStyle: signalLineStyle,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        ),
      );

  /// Unique name for this indicator.
  static const String name = 'macd';

  @override
  Map<String, dynamic> toJson() => _$MACDIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// The period to calculate the fast MA value.
  final int fastMAPeriod;

  /// The period to calculate the Slow MA value.
  final int slowMAPeriod;

  /// The period to calculate the Signal value.
  final int signalPeriod;

  /// Histogram bar style
  final BarStyle barStyle;

  /// Line style.
  final LineStyle lineStyle;

  /// Signal line style.
  final LineStyle signalLineStyle;

  @override
  String get configSummary => '$fastMAPeriod, $slowMAPeriod, $signalPeriod';

  @override
  String get shortTitle => 'MACD';

  @override
  String get title => 'MACD';

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      MACDIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  MACDIndicatorConfig copyWith({
    int? fastMAPeriod,
    int? slowMAPeriod,
    int? signalPeriod,
    BarStyle? barStyle,
    LineStyle? lineStyle,
    LineStyle? signalLineStyle,
    int? pipSize,
    bool? showLastIndicator,
    String? title,
    int? number,
  }) =>
      MACDIndicatorConfig(
        fastMAPeriod: fastMAPeriod ?? this.fastMAPeriod,
        slowMAPeriod: slowMAPeriod ?? this.slowMAPeriod,
        signalPeriod: signalPeriod ?? this.signalPeriod,
        barStyle: barStyle ?? this.barStyle,
        lineStyle: lineStyle ?? this.lineStyle,
        signalLineStyle: signalLineStyle ?? this.signalLineStyle,
        pipSize: pipSize ?? this.pipSize,
        showLastIndicator: showLastIndicator ?? this.showLastIndicator,
        title: title ?? this.title,
        number: number ?? this.number,
      );
}
