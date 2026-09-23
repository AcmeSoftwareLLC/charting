import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The magnet's fixed colour, kept independent of the theme: the dot marks
/// where the pointer has been captured, not part of the drawing.
const Color _magnetDotColor = Color(0xFF398DFF);

/// Paints the magnet dot — the filled circle sitting on the OHLC point the
/// magnet has snapped to, so the point a click will create is visible before
/// clicking.
class MagnetDotPainter extends CustomPainter {
  /// Initializes [MagnetDotPainter].
  const MagnetDotPainter({required this.position, required this.radius});

  /// The magnet point, in canvas coordinates.
  final Offset position;

  /// Radius of the dot, see [radiusFor].
  final double radius;

  /// The dot's radius for a chart whose candles are [candleWidth] px wide:
  /// a third of the candle's width, never smaller than a 12px-wide candle
  /// would give and never larger than 8.
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
