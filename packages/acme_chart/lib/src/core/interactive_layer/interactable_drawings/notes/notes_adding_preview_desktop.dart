import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../widgets/note_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'notes_interactable_drawing.dart';

/// A class to show a preview and handle adding a
/// [NotesInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerDesktopBehaviour].
class NotesAddingPreviewDesktop
    extends DrawingAddingPreview<NotesInteractableDrawing> {
  /// Initializes [NotesAddingPreviewDesktop].
  NotesAddingPreviewDesktop({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 1));
  }

  Offset? _hoverPosition;

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) => false;

  @override
  String get id => 'Notes-adding-preview-desktop';

  @override
  void onHover(
    PointerHoverEvent event,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    _hoverPosition = event.localPosition;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState drawingState,
  ) {
    if (_hoverPosition == null) {
      return;
    }

    final config = interactableDrawing.config;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: config.text.isEmpty ? notesEmptyPlaceholder : config.text,
        style: config.textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: notesBoxMaxWidth - notesBoxPadding * 2);

    final double width = (textPainter.width + notesBoxPadding * 2).clamp(
      notesBoxMinWidth,
      notesBoxMaxWidth,
    );
    final double height = textPainter.height + notesBoxPadding * 2;
    final Rect rect = Rect.fromLTWH(
      _hoverPosition!.dx,
      _hoverPosition!.dy,
      width,
      height,
    );
    final RRect roundedRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(6),
    );

    canvas.drawPath(
      dashPath(
        Path()..addRRect(roundedRect),
        dashArray: CircularIntervalList<double>(<double>[4, 4]),
      ),
      Paint()
        ..color = config.lineStyle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = config.lineStyle.thickness,
    );
    textPainter.paint(
      canvas,
      Offset(rect.left + notesBoxPadding, rect.top + notesBoxPadding),
    );
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (interactableDrawing.position == null) {
      interactableDrawing.position = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
      onAddingStateChange(AddingStateInfo(1, 1));
    }
  }
}
