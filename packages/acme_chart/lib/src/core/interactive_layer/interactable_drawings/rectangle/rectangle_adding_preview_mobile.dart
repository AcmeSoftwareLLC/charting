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
import 'rectangle_adding_preview.dart';

/// A class to show a preview and handle adding a
/// [RectangleInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
///
/// This mobile preview provides immediate focus mode by:
/// - Automatically placing a default rectangle in the center of the chart
/// - Immediately completing the adding process for instant focus mode
/// - Delegating visual rendering to the main drawing for consistency
/// - Providing full functionality (drag corners, drag body, neon effects)
class RectangleAddingPreviewMobile extends RectangleAddingPreview {
  /// Initializes [RectangleAddingPreviewMobile].
  RectangleAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size size = interactiveLayer.drawingContext.fullSize;

      // Position the rectangle to span the chart area with better spacing
      // from the Y-axis, matching the default box used by other tools'
      // mobile previews.
      final startCenter = Offset(size.width * 0.20, size.height * 0.8);
      final endCenter = Offset(size.width * 0.70, size.height * 0.25);

      interactableDrawing
        ..startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(startCenter.dx),
          quote: interactiveLayer.quoteFromY(startCenter.dy),
        )
        ..endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(endCenter.dx),
          quote: interactiveLayer.quoteFromY(endCenter.dy),
        );

      // Use a post-frame callback to ensure points are fully set before
      // transitioning. Check if the widget is still mounted to prevent race
      // conditions.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (interactiveLayerBehaviour.interactiveLayer.isStillMounted &&
            interactableDrawing.startPoint != null &&
            interactableDrawing.endPoint != null) {
          onAddingStateChange(AddingStateInfo(2, 2));
        }
      });
    }
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
  ) =>
      interactableDrawing.onDragStart(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) =>
      interactableDrawing.onDragUpdate(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) =>
      interactableDrawing.onDragEnd(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );

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
    // Only paint if we have valid start and end points.
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
      // Delegate to main drawing with selected state simulation for full
      // visual appearance.
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
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // Since we immediately complete the adding process in the constructor,
    // this method is primarily for consistency with the interface.
    //
    // If for some reason the points are not set, set them to default
    // positions.
    if (interactableDrawing.startPoint == null ||
        interactableDrawing.endPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size size = interactiveLayer.drawingContext.fullSize;

      final startCenter = Offset(size.width * 0.20, size.height * 0.8);
      final endCenter = Offset(size.width * 0.70, size.height * 0.25);

      interactableDrawing
        ..startPoint = EdgePoint(
          epoch: epochFromX(startCenter.dx),
          quote: quoteFromY(startCenter.dy),
        )
        ..endPoint = EdgePoint(
          epoch: epochFromX(endCenter.dx),
          quote: quoteFromY(endCenter.dy),
        );
    }

    onAddingStateChange(AddingStateInfo(2, 2));
  }

  @override
  bool shouldRepaint(
    Set<DrawingToolState> drawingState,
    DrawingV2 oldDrawing,
  ) =>
      true;

  @override
  String get id => 'rectangle-adding-preview-mobile';
}
