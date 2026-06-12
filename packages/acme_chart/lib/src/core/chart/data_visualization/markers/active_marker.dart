import 'package:flutter/material.dart';
import 'marker.dart';

/// Focused marker on the chart.
// ignore: must_be_immutable
class ActiveMarker extends Marker {
  /// Creates an active marker of given direction.
  ActiveMarker({
    required super.epoch,
    required super.quote,
    required super.direction,
    required this.text,
    super.onTap,
    this.onTapOutside,
  });

  /// Text displayed on the marker.
  final String text;

  /// Called when chart is tapped outside of active marker.
  final VoidCallback? onTapOutside;
}
