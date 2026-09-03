import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/notes/notes_drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/extensions/extensions.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/enums/drawing_tool_state.dart';
import '../../../../models/axis_range.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../theme/painting_styles/line_style.dart';
import '../../../../widgets/color_picker/color_picker_dropdown_button.dart';
import '../../../../widgets/note_text_field.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'notes_adding_preview_desktop.dart';
import 'notes_adding_preview_mobile.dart';

/// Padding between the note box border and its text content.
const double notesBoxPadding = 8;

/// Maximum width of the note box while it's auto-sizing to fit its text.
const double notesBoxMaxWidth = 220;

/// Minimum width the note box can be, whether auto-sized or resized.
const double notesBoxMinWidth = 64;

/// Minimum height the note box can be resized to.
const double notesBoxMinHeight = 32;

/// Maximum width the note box can be resized to.
const double notesBoxMaxResizableWidth = 480;

/// Maximum height the note box can be resized to.
const double notesBoxMaxResizableHeight = 320;

/// Touch tolerance around the note box's bounds when hit-testing, matching
/// the boundary tolerance rectangle uses for its stroke.
const double notesTouchTolerance = 10;

/// Interactable drawing implementation for the notes drawing tool.
///
/// Pins a text box to a single epoch/quote point on the chart. The box auto-
/// sizes to fit its text until the user drags its resize handle, after which
/// its size is fixed; a separate handle on the opposite corner moves the
/// whole box. Its text is edited in place through an overlay shown directly
/// on top of the box while it's selected, and its colors are edited through
/// the on-canvas toolbar.
class NotesInteractableDrawing
    extends InteractableDrawing<NotesDrawingToolConfig> {
  /// Initializes [NotesInteractableDrawing].
  NotesInteractableDrawing({
    required NotesDrawingToolConfig config,
    required this.position,
    required super.drawingContext,
    required super.getDrawingState,
  }) : width = config.width,
       height = config.height,
       super(drawingConfig: config);

  /// The anchor point of the note box (its top-left corner).
  EdgePoint? position;

  /// The box's width once the user has resized it, or `null` to auto-size.
  double? width;

  /// The box's height once the user has resized it, or `null` to auto-size.
  double? height;

  /// Whether the corner currently being dragged is the resize handle
  /// (bottom-right) rather than the move handle (top-left).
  bool _isResizeHandleDragged = false;

  /// Computes the on-screen box occupied by the note, anchored at [position].
  Rect? _boxRect(EpochToX epochToX, QuoteToY quoteToY) {
    if (position == null) {
      return null;
    }

    final Offset anchor = Offset(
      epochToX(position!.epoch),
      quoteToY(position!.quote),
    );

    final double boxWidth = width ?? _autoWidth();
    final double boxHeight = height ?? _autoHeight(boxWidth);

    return Rect.fromLTWH(anchor.dx, anchor.dy, boxWidth, boxHeight);
  }

  double _autoWidth() {
    final TextPainter textPainter = _buildTextPainter()
      ..layout(maxWidth: notesBoxMaxWidth - notesBoxPadding * 2);

    return (textPainter.width + notesBoxPadding * 2).clamp(
      notesBoxMinWidth,
      notesBoxMaxWidth,
    );
  }

  double _autoHeight(double forWidth) {
    final TextPainter textPainter = _buildTextPainter()
      ..layout(maxWidth: forWidth - notesBoxPadding * 2);

    return textPainter.height + notesBoxPadding * 2;
  }

  TextPainter _buildTextPainter() {
    final bool isEmpty = config.text.isEmpty;

    return TextPainter(
      text: TextSpan(
        text: isEmpty ? notesEmptyPlaceholder : config.text,
        style: isEmpty
            ? config.textStyle.copyWith(
                color: config.textStyle.color?.withValues(alpha: 0.6),
              )
            : config.textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    final Rect? rect = _boxRect(epochToX, quoteToY);
    if (rect == null) {
      return false;
    }

    if (state.contains(DrawingToolState.selected)) {
      return (offset - rect.topLeft).distance <= hitTestMargin ||
          (offset - rect.bottomRight).distance <= hitTestMargin;
    }

    return rect.inflate(notesTouchTolerance).contains(offset);
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    final Rect? rect = _boxRect(epochToX, quoteToY);
    if (rect == null) {
      return;
    }

    final double moveDistance = (details.localPosition - rect.topLeft).distance;
    final double resizeDistance =
        (details.localPosition - rect.bottomRight).distance;

    _isResizeHandleDragged =
        resizeDistance <= hitTestMargin && resizeDistance < moveDistance;
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (position == null) {
      return;
    }

    if (_isResizeHandleDragged) {
      final Rect? rect = _boxRect(epochToX, quoteToY);
      if (rect == null) {
        return;
      }

      if (details.delta.dx != 0) {
        width = (rect.width + details.delta.dx).clamp(
          notesBoxMinWidth,
          notesBoxMaxResizableWidth,
        );
      }
      if (details.delta.dy != 0) {
        height = (rect.height + details.delta.dy).clamp(
          notesBoxMinHeight,
          notesBoxMaxResizableHeight,
        );
      }
      return;
    }

    final Offset currentOffset = Offset(
      epochToX(position!.epoch),
      quoteToY(position!.quote),
    );
    final Offset newOffset = currentOffset + details.delta;

    position = EdgePoint(
      epoch: epochFromX(newOffset.dx),
      quote: quoteFromY(newOffset.dy),
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
    _isResizeHandleDragged = false;
    config = getUpdatedConfig();
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
    final Rect? rect = _boxRect(epochToX, quoteToY);
    if (rect == null) {
      return;
    }

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);
    final RRect roundedRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(6),
    );

    if (config.pattern == DrawingPatterns.solid) {
      canvas
        ..drawRRect(
          roundedRect,
          Paint()
            ..color = fillStyle.color
            ..style = PaintingStyle.fill,
        )
        ..drawRRect(
          roundedRect,
          paintStyle.strokeStyle(lineStyle.color, lineStyle.thickness),
        );

      if (drawingState.contains(DrawingToolState.selected)) {
        final Paint neonPaint = Paint()
          ..color = lineStyle.color.withValues(alpha: 0.4)
          ..strokeWidth = 8 * animationInfo.stateChangePercent
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(roundedRect, neonPaint);
      }
    }

    if (!drawingState.contains(DrawingToolState.selected)) {
      canvas.save();
      canvas.clipRRect(roundedRect);
      _buildTextPainter()
        ..layout(maxWidth: rect.width - notesBoxPadding * 2)
        ..paint(
          canvas,
          Offset(rect.left + notesBoxPadding, rect.top + notesBoxPadding),
        );
      canvas.restore();
    }

    if (drawingState.contains(DrawingToolState.selected) ||
        drawingState.contains(DrawingToolState.hovered) ||
        drawingState.contains(DrawingToolState.dragging)) {
      drawPointOffset(
        rect.topLeft,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      drawPointOffset(
        rect.bottomRight,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );

      if (drawingState.contains(DrawingToolState.dragging)) {
        final Offset draggedCorner = _isResizeHandleDragged
            ? rect.bottomRight
            : rect.topLeft;

        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          draggedCorner,
          10 * animationInfo.stateChangePercent,
          3 * animationInfo.stateChangePercent,
        );

        if (!_isResizeHandleDragged) {
          drawPointAlignmentGuides(
            canvas,
            size,
            rect.topLeft,
            lineColor: lineStyle.color,
          );
        }
      }
    }
  }

  @override
  NotesDrawingToolConfig getUpdatedConfig() => config.copyWith(
    edgePoints: <EdgePoint>[?position],
    width: width,
    height: height,
  );

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      position?.isInEpochRange(epochRange.leftEpoch, epochRange.rightEpoch) ??
      true;

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => NotesAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => NotesAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  Widget? buildSelectedOverlay(
    EpochToX epochToX,
    QuoteToY quoteToY,
    UpdateDrawingTool onUpdate,
  ) {
    final Rect? rect = _boxRect(epochToX, quoteToY);
    if (rect == null) {
      return null;
    }

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Padding(
        padding: const EdgeInsets.all(notesBoxPadding),
        child: NoteTextField(
          key: ValueKey(config.configId),
          text: config.text,
          style: config.textStyle,
          onChanged: (String value) => onUpdate(config.copyWith(text: value)),
        ),
      ),
    );
  }

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
    children: <Widget>[
      _buildLineColorPickerIcon(onUpdate),
      const SizedBox(width: 4),
      _buildFillColorPickerIcon(onUpdate),
    ],
  );

  Widget _buildLineColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
    width: 32,
    height: 32,
    child: ColorPickerDropdownButton(
      currentColor: config.lineStyle.color,
      onColorChanged: (newColor) => onUpdate(
        config.copyWith(lineStyle: config.lineStyle.copyWith(color: newColor)),
      ),
    ),
  );

  Widget _buildFillColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
    width: 32,
    height: 32,
    child: ColorPickerDropdownButton(
      currentColor: config.fillStyle.color,
      onColorChanged: (newColor) => onUpdate(
        config.copyWith(fillStyle: config.fillStyle.copyWith(color: newColor)),
      ),
    ),
  );
}
