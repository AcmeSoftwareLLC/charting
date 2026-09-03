import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/interactable_drawings/drawing_v2.dart';
import '../../../../core/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import 'package:material_ui/material_ui.dart';

import '../../enums/drawing_tool_state.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import 'doodle_adding_preview.dart';

/// A class to show a preview and handle adding a
/// [DoodleInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
///
/// A finger drag is the natural way to doodle on a touch screen, so unlike
/// the other tools' mobile previews (which auto-place a default shape and
/// let the user adjust it), this behaves the same as the desktop preview:
/// [onDragStart] begins the stroke, [onDragUpdate] samples points, and
/// [onDragEnd] finishes it.
class DoodleAddingPreviewMobile extends DoodleAddingPreview {
  /// Initializes [DoodleAddingPreviewMobile].
  DoodleAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    onAddingStateChange(AddingStateInfo(0, 1));
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) =>
      interactableDrawing.hitTest(offset, epochToX, quoteToY);

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    startStroke(details.localPosition, epochFromX, quoteFromY);
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    extendStrokeByDelta(details.delta, epochFromX, quoteFromY);
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    finishStroke();
    onAddingStateChange(AddingStateInfo(1, 1));
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
    GetDrawingState getDrawingState,
  ) {
    if (interactableDrawing.points.isEmpty) {
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
    // A doodle is drawn by dragging, not tapping — nothing to do here.
  }

  @override
  bool shouldRepaint(
    Set<DrawingToolState> drawingState,
    DrawingV2 oldDrawing,
  ) => true;

  @override
  String get id => 'doodle-adding-preview-mobile';
}
