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
import 'fib_retracement_adding_preview.dart';

/// A class to show a preview and handle adding a
/// [FibRetracementInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
///
/// This mobile preview provides immediate focus mode by:
/// - Automatically placing a default span in the center of the chart
/// - Immediately completing the adding process for instant focus mode
/// - Delegating visual rendering to the main drawing for consistency
/// - Providing full functionality (drag anchors, drag body)
class FibRetracementAddingPreviewMobile extends FibRetracementAddingPreview {
  /// Initializes [FibRetracementAddingPreviewMobile].
  FibRetracementAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.startPoint == null) {
      _placeDefaultPoints();
    }
  }

  /// How many times [_placeDefaultPoints] has retried because the chart's
  /// price axis looked unready. Capped so a persistently-degenerate axis
  /// (rather than a one- or two-frame startup race) still eventually
  /// places *something*, instead of silently never placing anything.
  int _placementAttempts = 0;

  /// The most retries [_placeDefaultPoints] will wait through before giving
  /// up on detecting a healthy price axis and committing whatever it has.
  static const int _maxPlacementAttempts = 10;

  /// Places the default start/end anchors as fractions of the chart's
  /// current size, then signals placement as finished.
  ///
  /// Right when the tool is selected, the chart's layout and/or its price
  /// axis range may not have settled yet (e.g. this preview can be built
  /// before the chart has finished auto-scaling its Y-axis to the visible
  /// data), in which case
  /// [InteractiveLayerBase.epochFromX]/[InteractiveLayerBase.quoteFromY]
  /// can momentarily map every screen position to the same (or a barely
  /// distinguishable) epoch/quote. Committing that would collapse all nine
  /// retracement levels onto the same price — visually a single flat line
  /// with every percentage label stacked illegibly on top of the others.
  ///
  /// Guard against that two ways: first, by sampling the price axis at its
  /// full extremes (not just our two chosen fractions) to check it spans a
  /// real, non-degenerate range at all; second, by requiring our two
  /// anchors' quotes to differ by a meaningful fraction of that range
  /// rather than merely being unequal — an axis that hasn't finished
  /// auto-scaling can still produce two technically-different quotes that
  /// are visually indistinguishable once rendered. Retry next frame
  /// otherwise, up to [_maxPlacementAttempts].
  void _placeDefaultPoints() {
    final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
    final Size size = interactiveLayer.drawingContext.fullSize;

    final double topQuote = interactiveLayer.quoteFromY(0);
    final double bottomQuote = interactiveLayer.quoteFromY(size.height);
    final double axisSpan = (bottomQuote - topQuote).abs();

    final startCenter = Offset(size.width * 0.20, size.height * 0.8);
    final endCenter = Offset(size.width * 0.70, size.height * 0.25);

    final EdgePoint start = EdgePoint(
      epoch: interactiveLayer.epochFromX(startCenter.dx),
      quote: interactiveLayer.quoteFromY(startCenter.dy),
    );
    final EdgePoint end = EdgePoint(
      epoch: interactiveLayer.epochFromX(endCenter.dx),
      quote: interactiveLayer.quoteFromY(endCenter.dy),
    );

    final bool axisLooksReady =
        size.width > 0 &&
        size.height > 0 &&
        axisSpan > 0 &&
        start.epoch != end.epoch &&
        (start.quote - end.quote).abs() > axisSpan * 0.05;

    if (!axisLooksReady && _placementAttempts < _maxPlacementAttempts) {
      _placementAttempts++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (interactiveLayer.isStillMounted &&
            interactableDrawing.startPoint == null) {
          _placeDefaultPoints();
        }
      });
      return;
    }

    interactableDrawing
      ..startPoint = start
      ..endPoint = end;

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
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
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
    // Route through the same guarded path the constructor uses, rather
    // than duplicating the fraction-based default placement here
    // unguarded — otherwise a tap landing while the axis-readiness retry
    // is still in flight could commit degenerate points through this
    // path instead, defeating that guard entirely.
    if (interactableDrawing.startPoint == null) {
      _placeDefaultPoints();
      return;
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
  String get id => 'fib-retracement-adding-preview-mobile';
}
