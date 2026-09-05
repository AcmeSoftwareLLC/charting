import 'package:acme_chart/acme_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chart_config.g.dart';

/// Chart's general configuration.
@immutable
@JsonSerializable()
class ChartConfig {
  /// Initializes chart's general configuration.
  const ChartConfig({
    required this.granularity,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.chartTimeConfig = const ChartTimeConfig(),
    this.pipSize = 4,
    this.snapMarkersToIntervals = true,
    this.magnetEnabled = false,
  });

  /// Initializes from JSON.
  factory ChartConfig.fromJson(Map<String, dynamic> json) =>
      _$ChartConfigFromJson(json);

  /// Serialization to JSON. Serves as value in key-value storage.
  Map<String, dynamic> toJson() => _$ChartConfigToJson(this);

  /// PipSize, number of decimal digits when showing prices on the chart.
  final int pipSize;

  /// Granularity.
  final int granularity;

  /// Whether markers' x-positions should snap to interval buckets (e.g., candle).
  ///
  /// When true, marker epochs are snapped to the current granularity bucket
  /// for rendering, aligning markers to candle centerlines on chart.
  final bool snapMarkersToIntervals;

  /// Chart Axis configuration.
  final ChartAxisConfig chartAxisConfig;

  /// Chart time formatting and timezone configuration.
  ///
  /// Contains callbacks, so it is excluded from JSON (de)serialization.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ChartTimeConfig chartTimeConfig;

  /// Whether new drawing tool points snap to the nearest candle's time
  /// bucket instead of the exact cursor position ("magnet" mode).
  final bool magnetEnabled;

  @override
  bool operator ==(covariant ChartConfig other) =>
      pipSize == other.pipSize &&
      granularity == other.granularity &&
      snapMarkersToIntervals == other.snapMarkersToIntervals &&
      magnetEnabled == other.magnetEnabled;

  @override
  int get hashCode =>
      Object.hash(pipSize, granularity, snapMarkersToIntervals, magnetEnabled);
}
