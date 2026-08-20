import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/interactable_drawings/drawing_v2.dart';
import '../../../../core/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:flutter/widgets.dart';
import '../../enums/drawing_tool_state.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'notes_interactable_drawing.dart';

/// A class to show a preview and handle adding a
/// [NotesInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
///
/// Immediately places the note at the center of the chart and completes the
/// adding process so the user gets straight to editing its text and moving
/// it, then delegates rendering/dragging to the main drawing for consistency.
class NotesAddingPreviewMobile
    extends DrawingAddingPreview<NotesInteractableDrawing> {
  /// Initializes [NotesAddingPreviewMobile].
  NotesAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.position == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size layerSize = interactiveLayer.drawingContext.fullSize;

      final double centerX = layerSize.width / 2;
      final double centerY = layerSize.height / 2;

      interactableDrawing.position = EdgePoint(
        epoch: interactiveLayer.epochFromX(centerX),
        quote: interactiveLayer.quoteFromY(centerY),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (interactiveLayerBehaviour.interactiveLayer.isStillMounted &&
            interactableDrawing.position != null) {
          onAddingStateChange(AddingStateInfo(1, 1));
        }
      });
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) =>
      interactableDrawing.hitTest(offset, epochToX, quoteToY);

  @override
  String get id => 'Notes-adding-preview-mobile';

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    interactableDrawing.onDragStart(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    interactableDrawing.onDragUpdate(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    interactableDrawing.onDragEnd(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
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
    if (interactableDrawing.position == null) {
      return;
    }

    Set<DrawingToolState> mockGetDrawingState(DrawingV2 drawing) => {
      DrawingToolState.selected,
    };

    interactableDrawing.paint(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      chartConfig,
      chartTheme,
      mockGetDrawingState,
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
    interactableDrawing.position ??= EdgePoint(
      epoch: epochFromX(details.localPosition.dx),
      quote: quoteFromY(details.localPosition.dy),
    );

    onAddingStateChange(AddingStateInfo(1, 1));
  }
}
