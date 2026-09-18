import 'dart:async';

import '../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../core/interactive_layer/helpers/types.dart';
import '../../../core/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../../core/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../enums/drawing_tool_state.dart';
import '../enums/state_change_direction.dart';
import '../interactable_drawings/drawing_adding_preview.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_base.dart';
import '../interactive_layer_controller.dart';
import '../interactive_layer_states/interactive_adding_tool_state.dart';
import '../interactive_layer_states/interactive_normal_state.dart';
import '../interactive_layer_states/interactive_selected_tool_state.dart';
import '../interactive_layer_states/interactive_state.dart';

/// Manages gestures and [currentState] transitions for [InteractiveLayerBase],
/// customizable per platform or condition by extending this class.
///
/// See [InteractiveLayerMobileBehaviour] and [InteractiveLayerDesktopBehaviour]
/// for the platform-specific implementations.
abstract class InteractiveLayerBehaviour {
  /// Creates an instance of [InteractiveLayerBehaviour].
  InteractiveLayerBehaviour({InteractiveLayerController? controller})
    : _controller = controller ?? InteractiveLayerController() {
    _controller
      ..currentState = InteractiveNormalState(interactiveLayerBehaviour: this)
      ..onCancelAdding = () {
        updateStateTo(
          InteractiveNormalState(interactiveLayerBehaviour: this),
          StateChangeAnimationDirection.backward,
          animate: false,
        );
      }
      ..onAddNewTool = (DrawingToolConfig drawingTool) {
        startAddingTool(drawingTool);
      };
  }

  late final InteractiveLayerController _controller;

  /// The controller for state changes in the interactive layer.
  ///
  /// Note: This is not final to allow reassignment when the widget rebuilds
  /// (e.g., during symbol switches). The old controller gets disposed by the
  /// widget, and a new one is created and assigned here.
  late AnimationController stateChangeController;

  /// The controller for the interactive layer.
  InteractiveLayerController get controller => _controller;

  /// Current state of the interactive layer.
  InteractiveState get currentState => controller.currentState;

  bool _initialized = false;

  /// The interactive layer that this manager is managing.
  ///
  /// Note: This is not final to allow reassignment when the widget rebuilds.
  late InteractiveLayerBase interactiveLayer;

  /// The callback that is called when the interactive layer needs to be updated.
  ///
  /// Note: This is not final to allow reassignment when the widget rebuilds.
  late VoidCallback onUpdate;

  /// Initializes the [InteractiveLayerBehaviour].
  ///
  /// Safe to call multiple times (e.g. on widget rebuilds during symbol
  /// switches) — later calls just update the stored references.
  void init({
    required InteractiveLayerBase interactiveLayer,
    required VoidCallback onUpdate,
    required AnimationController stateChangeController,
  }) {
    if (_initialized) {
      // Update the references to the new instances
      this.stateChangeController = stateChangeController;
      this.interactiveLayer = interactiveLayer;
      this.onUpdate = onUpdate;

      return;
    }

    // First-time initialization
    this.stateChangeController = stateChangeController;
    this.interactiveLayer = interactiveLayer;
    this.onUpdate = onUpdate;
    _initialized = true;
  }

  /// The adding preview for [drawing].
  DrawingAddingPreview getAddingDrawingPreview(
    InteractableDrawing drawing,
    Function(AddingStateInfo) onAddingStateChange,
  );

  /// Updates the interactive layer state to [newState], then calls
  /// [onUpdate].
  ///
  /// [waitForAnimation] controls whether this awaits the state-change
  /// animation before returning.
  Future<void> updateStateTo(
    InteractiveState newState,
    StateChangeAnimationDirection direction, {
    bool waitForAnimation = true,
    bool animate = true,
  }) async {
    if (waitForAnimation) {
      await interactiveLayer.animateStateChange(direction, animate: animate);
    } else {
      unawaited(
        interactiveLayer.animateStateChange(direction, animate: animate),
      );
    }

    _controller.currentState = newState;
    onUpdate();
  }

  /// Starts adding [drawingTool] to the layer.
  void startAddingTool(DrawingToolConfig drawingTool) {
    updateStateTo(
      InteractiveAddingToolState(drawingTool, interactiveLayerBehaviour: this),
      StateChangeAnimationDirection.forward,
      animate: false,
      waitForAnimation: false,
    );
  }

  /// Called once [startAddingTool] completes without cancellation.
  ///
  /// By default, updates the state to [InteractiveSelectedToolState] with
  /// the newly added [drawing]. Override to add extra behavior.
  void aNewToolsIsAdded(InteractableDrawing drawing) => updateStateTo(
    InteractiveSelectedToolState(
      selected: drawing,
      interactiveLayerBehaviour: this,
    ),
    StateChangeAnimationDirection.forward,
    waitForAnimation: false,
  );

  /// The drawings of the interactive layer.
  Set<DrawingToolState> getToolState(DrawingV2 drawing) =>
      currentState.getToolState(drawing);

  /// Returns the z-order for the tool drawings.
  DrawingZOrder getToolZOrder(DrawingV2 drawing) =>
      currentState.getToolZOrder(drawing);

  /// Short-lived drawings the current state shows for preview or temporary
  /// guides on top of [InteractiveLayerBase].
  List<DrawingV2> get previewDrawings => currentState.previewDrawings;

  /// Extra widgets the current state shows on top of the interactive layer.
  List<Widget> get previewWidgets => currentState.previewWidgets;

  /// Handles tap event.
  bool onTap(TapUpDetails details) => currentState.onTap(details);

  /// Handles secondary tap (right-click) event.
  bool onSecondaryTap(TapUpDetails details) =>
      currentState.onSecondaryTap(details);

  /// Handles pan update event.
  bool onPanUpdate(DragUpdateDetails details) =>
      currentState.onPanUpdate(details);

  /// Handles pan end event.
  bool onPanEnd(DragEndDetails details) => currentState.onPanEnd(details);

  /// Handles pan start event.
  bool onPanStart(DragStartDetails details) => currentState.onPanStart(details);

  /// Handles hover event.
  bool onHover(PointerHoverEvent event) => currentState.onHover(event);

  /// Handles long press event.
  bool onLongPress(Offset localPosition) =>
      currentState.onLongPress(localPosition);

  /// Handles long press end event.
  bool onLongPressEnd() => currentState.onLongPressEnd();

  /// Whether [localPosition] hits any regular or preview drawing.
  bool hitTestDrawings(Offset localPosition) {
    // First check if the point is within the floating menu bounds
    // If it is, don't allow drawing hit testing to prevent interference
    if (controller.isPointInFloatingMenu(localPosition)) {
      return false;
    }

    // A tool that's drawn by dragging from an empty canvas (e.g. a freehand
    // doodle) has nothing to positionally hit yet — treat any position as a
    // hit so the drawing-tool gesture recognizer claims the pointer instead
    // of rejecting it and handing the gesture to chart panning/scrolling.
    final InteractiveState state = currentState;
    if (state is InteractiveAddingToolState &&
        (state.addingDrawingPreview?.canStartDragFromEmpty ?? false)) {
      return true;
    }

    // Check regular and preview drawings
    for (final drawing in [...interactiveLayer.drawings, ...previewDrawings]) {
      if (drawing.hitTest(
        localPosition,
        interactiveLayer.epochToX,
        interactiveLayer.quoteToY,
      )) {
        return true;
      }
    }

    return false;
  }
}
