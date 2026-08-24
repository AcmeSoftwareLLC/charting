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
/// It's a [SegmentInteractableDrawing] through and through — same geometry,
/// hit-test, drag and toolbar — so once placed it's stored, rendered, and
/// edited exactly as if it had been drawn with the Segment tool.
///
/// The only thing "measure" changes is what's shown *while it's being
/// placed*: [getAddingPreviewForDesktopBehaviour] swaps in
/// [MeasureAddingPreviewDesktop], which overlays a live price
/// difference / percentage change / bar count label next to the preview
/// line. [getAddingPreviewForMobileBehaviour] reuses
/// [SegmentAddingPreviewMobile] unchanged, since mobile completes placement
/// immediately with no equivalent "measuring" window.
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
