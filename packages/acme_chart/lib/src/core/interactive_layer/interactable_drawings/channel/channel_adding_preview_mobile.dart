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
import 'channel_adding_preview.dart';

/// A class to show a preview and handle adding a [ChannelInteractableDrawing]
/// to the chart. It's for when we're on [InteractiveLayerMobileBehaviour].
///
/// This mobile preview provides immediate focus mode by:
/// - Automatically placing a default channel in the center of the chart
/// - Immediately completing the adding process for instant focus mode
/// - Delegating visual rendering to the main drawing for consistency
/// - Providing full functionality (drag any of the 3 points, drag body)
class ChannelAddingPreviewMobile extends ChannelAddingPreview {
  /// Initializes [ChannelAddingPreviewMobile].
  ChannelAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      _placeDefaultChannel(
        interactiveLayer.drawingContext.fullSize,
        interactiveLayer.epochFromX,
        interactiveLayer.quoteFromY,
      );

      // Use a post-frame callback to ensure points are fully set before
      // transitioning. Check if the widget is still mounted to prevent race
      // conditions.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (interactiveLayerBehaviour.interactiveLayer.isStillMounted &&
            interactableDrawing.startPoint != null &&
            interactableDrawing.middlePoint != null &&
            interactableDrawing.endPoint != null) {
          onAddingStateChange(AddingStateInfo(3, 3));
        }
      });
    }
  }

  /// Places a default channel spanning the chart area, matching the box used
  /// by the other tools' mobile previews.
  void _placeDefaultChannel(
    Size size,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
  ) {
    final Offset startCenter = Offset(size.width * 0.20, size.height * 0.8);
    final Offset middleCenter = Offset(size.width * 0.70, size.height * 0.45);
    final double heightOffset = size.height * 0.15;

    interactableDrawing
      ..startPoint = EdgePoint(
        epoch: epochFromX(startCenter.dx),
        quote: quoteFromY(startCenter.dy),
      )
      ..middlePoint = EdgePoint(
        epoch: epochFromX(middleCenter.dx),
        quote: quoteFromY(middleCenter.dy),
      )
      ..endPoint = EdgePoint(
        epoch: epochFromX(middleCenter.dx),
        quote: quoteFromY(middleCenter.dy + heightOffset),
      );
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
  ) => interactableDrawing.onDragStart(
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
  ) => interactableDrawing.onDragUpdate(
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
  ) => interactableDrawing.onDragEnd(
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
    // Only paint if we have valid start, middle and end points.
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.middlePoint != null &&
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
        interactableDrawing.middlePoint == null ||
        interactableDrawing.endPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      _placeDefaultChannel(
        interactiveLayer.drawingContext.fullSize,
        epochFromX,
        quoteFromY,
      );
    }

    onAddingStateChange(AddingStateInfo(3, 3));
  }

  @override
  bool shouldRepaint(
    Set<DrawingToolState> drawingState,
    DrawingV2 oldDrawing,
  ) => true;

  @override
  String get id => 'channel-adding-preview-mobile';
}
