import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// ChartIQ's magnet colour (`#398dff`), kept fixed rather than themed: the dot
/// marks where the pointer has been captured, not part of the drawing.
const Color _magnetDotColor = Color(0xFF398DFF);

/// Paints the magnet dot — the filled circle sitting on the OHLC point the
/// magnet has snapped to, so the point a click will create is visible before
/// clicking.
///
/// ChartIQ draws the same affordance at the end of `magnetize()`, on its
/// temp canvas so it follows the pointer:
/// `arc(pixelFromTick(tick), magnetY, min(max(candleWidth, 12) / 3, 8))`
/// filled with `#398dff` — hence [radiusFor].
class MagnetDotPainter extends CustomPainter {
  /// Initializes [MagnetDotPainter].
  const MagnetDotPainter({required this.position, required this.radius});

  /// The magnet point, in canvas coordinates.
  final Offset position;

  /// Radius of the dot, see [radiusFor].
  final double radius;

  /// The dot's radius for a chart whose candles are [candleWidth] px wide,
  /// matching ChartIQ: a third of the candle's width, never smaller than a
  /// 12px-wide candle would give and never larger than 8.
  static double radiusFor(double candleWidth) =>
      math.min(math.max(candleWidth, 12) / 3, 8);

  @override
  void paint(Canvas canvas, Size size) => canvas.drawCircle(
    position,
    radius,
    Paint()
      ..color = _magnetDotColor
      ..style = PaintingStyle.fill,
  );

  @override
  bool shouldRepaint(MagnetDotPainter oldDelegate) =>
      oldDelegate.position != position || oldDelegate.radius != radius;
}
