import 'package:material_ui/material_ui.dart';

/// Paints fill between two lines.
void paintFill(Canvas canvas, Path area, Color color) => canvas.drawPath(
  area,
  Paint()
    ..style = PaintingStyle.fill
    ..color = color,
);
