import '../../../../theme/painting_styles/entry_spot_style.dart';
import 'package:material_ui/material_ui.dart';

/// Paints an entry spot point for accumulators.
void paintAccumulatorsEntrySpot(
  Canvas canvas,
  Offset center,
  EntrySpotStyle style,
) {
  canvas
    ..drawCircle(
      center,
      style.radius,
      Paint()
        ..color = style.mainColor
        ..style = PaintingStyle.fill,
    )
    ..drawCircle(
      center,
      style.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = style.borderColor
        ..strokeWidth = style.strokeWidth,
    );
}
