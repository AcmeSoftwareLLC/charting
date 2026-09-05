import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Default formatter for the date portion of the crosshair info box.
String defaultCrosshairDateLabel(DateTime time) =>
    DateFormat('dd MMM yyyy').format(time);

/// Default formatter for the time portion of the crosshair info box.
String defaultCrosshairTimeLabel(DateTime time) =>
    DateFormat('HH:mm:ss').format(time);

/// Configuration for how chart timestamps (x-axis grid labels, crosshair,
/// drawing-tool epoch labels) are displayed.
@immutable
class ChartTimeConfig {
  /// Initializes the chart time configuration.
  const ChartTimeConfig({
    this.utcOffset = Duration.zero,
    this.axisTimeLabelBuilder,
    this.crosshairDateLabelBuilder,
    this.crosshairTimeLabelBuilder,
  });

  /// Fixed offset applied to every displayed timestamp (axis labels,
  /// crosshair, drawing-tool epoch labels) before formatting.
  ///
  /// Defaults to [Duration.zero], i.e. times are displayed in UTC.
  /// Pass a fixed offset to display another timezone, e.g.
  /// `Duration(hours: 5, minutes: 30)` for IST.
  final Duration utcOffset;

  /// Builds the text shown for x-axis time-grid labels.
  ///
  /// Receives the already offset-adjusted [DateTime]. If `null`, the
  /// built-in granularity-based formatter (`timeLabel`) is used.
  final String Function(DateTime time)? axisTimeLabelBuilder;

  /// Builds the date portion of the crosshair info box / bottom epoch label.
  ///
  /// Receives the already offset-adjusted [DateTime]. If `null`,
  /// [defaultCrosshairDateLabel] is used.
  final String Function(DateTime time)? crosshairDateLabelBuilder;

  /// Builds the time portion of the crosshair info box.
  ///
  /// Receives the already offset-adjusted [DateTime]. If `null`,
  /// [defaultCrosshairTimeLabel] is used.
  final String Function(DateTime time)? crosshairTimeLabelBuilder;

  /// Creates a copy of this [ChartTimeConfig] but with the given fields
  /// replaced.
  ChartTimeConfig copyWith({
    Duration? utcOffset,
    String Function(DateTime time)? axisTimeLabelBuilder,
    String Function(DateTime time)? crosshairDateLabelBuilder,
    String Function(DateTime time)? crosshairTimeLabelBuilder,
  }) => ChartTimeConfig(
    utcOffset: utcOffset ?? this.utcOffset,
    axisTimeLabelBuilder: axisTimeLabelBuilder ?? this.axisTimeLabelBuilder,
    crosshairDateLabelBuilder:
        crosshairDateLabelBuilder ?? this.crosshairDateLabelBuilder,
    crosshairTimeLabelBuilder:
        crosshairTimeLabelBuilder ?? this.crosshairTimeLabelBuilder,
  );
}
