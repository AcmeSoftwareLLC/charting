import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../core/interactive_layer/interactive_layer_states/interactive_adding_tool_state.dart';

import '../drawing_adding_preview.dart';
import '../interactable_drawing.dart';
import '../segment/segment_adding_preview_mobile.dart';
import '../segment/segment_interactable_drawing.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'measure_adding_preview_desktop.dart';

/// Interactable drawing implementation for the measure drawing tool.
///
/// A [SegmentInteractableDrawing] through and through — same geometry,
/// hit-test, drag, toolbar — so it renders and edits exactly like a Segment.
/// [MeasureDrawingToolConfig] extends [SegmentDrawingToolConfig] rather than
/// discarding its identity once placed, so reloading keeps it a genuine
/// measure drawing.
///
/// What "measure" changes is the placement preview:
/// [getAddingPreviewForDesktopBehaviour] swaps in
/// [MeasureAddingPreviewDesktop] for a live price-diff/percent/bar-count
/// label; [getAddingPreviewForMobileBehaviour] reuses
/// [SegmentAddingPreviewMobile] unchanged, since mobile places instantly.
///
/// Once placed it paints nothing beyond the segment itself — the readout is
/// the embedding app's, in its chart HUD, not on the canvas.
class MeasureInteractableDrawing extends SegmentInteractableDrawing {
  /// Initializes [MeasureInteractableDrawing].
  MeasureInteractableDrawing({
    required super.config,
    required super.startPoint,
    required super.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  });

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => MeasureAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => SegmentAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );
}
