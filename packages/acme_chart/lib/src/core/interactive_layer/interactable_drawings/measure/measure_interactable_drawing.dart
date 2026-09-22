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
/// hit-test, drag, toolbar — so it's rendered and edited exactly like a
/// Segment. Unlike an earlier version of this tool, it does *not* become a
/// plain segment once placed: [MeasureDrawingToolConfig] extends
/// [SegmentDrawingToolConfig] rather than discarding its identity, so
/// [getUpdatedConfig] (inherited from [SegmentInteractableDrawing]
/// unmodified) still persists a genuine [MeasureDrawingToolConfig] across
/// reloads, and picking the tool again keeps its placement behaviour.
///
/// The one thing "measure" changes is what's shown *while it's being placed*:
/// [getAddingPreviewForDesktopBehaviour] swaps in
/// [MeasureAddingPreviewDesktop], which overlays a live price difference /
/// percentage change / bar count label next to the preview line.
/// [getAddingPreviewForMobileBehaviour] reuses [SegmentAddingPreviewMobile]
/// unchanged, since mobile completes placement immediately with no
/// equivalent "measuring" window.
///
/// Once placed it paints nothing beyond the segment itself. The measurement
/// readout for a finished drawing belongs to the embedding app's chart HUD —
/// as in ChartIQ, where `setMeasure` writes into a fixed chart info
/// container rather than onto the canvas — so that hovering any drawing can
/// report it in one consistent place.
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
