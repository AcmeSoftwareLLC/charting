import 'dart:math';

import '../../../../add_ons/drawing_tools_ui/callbacks.dart';
import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';
import '../../../../add_ons/drawing_tools_ui/trade_ratio/trade_ratio_drawing_tool_config.dart';
import '../../../../core/chart/data_visualization/chart_data.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import '../../../../core/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import '../../../../core/chart/data_visualization/extensions/extensions.dart';
import '../../../../core/chart/data_visualization/models/animation_info.dart';
import '../../../../core/interactive_layer/enums/drawing_tool_state.dart';
import '../../../../models/axis_range.dart';
import '../../../../models/chart_config.dart';
import '../../../../theme/chart_theme.dart';
import '../../../../theme/painting_styles/line_style.dart';
import '../../../../widgets/color_picker/color_picker_dropdown_button.dart';
import '../../../../widgets/dropdown/line_thickness/line_thickness_dropdown_button.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'trade_ratio_adding_preview_desktop.dart';
import 'trade_ratio_adding_preview_mobile.dart';

/// Horizontal padding between where a level line starts and its label.
const double tradeRatioLabelPadding = 8;

/// How close a tap/pointer position must be (in pixels) to a level's line
/// for it to count as a hit on that line.
const double tradeRatioLevelHitTolerance = 6;

/// Default on-screen width (in pixels) of level lines when a Trade Ratio is
/// first placed and the far-edge handle hasn't been dragged yet.
const double tradeRatioDefaultLevelWidth = 150;

/// A single projected level's value and on-screen geometry, computed once
/// per paint/hit-test call and reused throughout.
class _ProjectedLevel {
  const _ProjectedLevel({
    required this.percent,
    required this.price,
    required this.delta,
    required this.y,
    required this.nearX,
    required this.color,
  });

  final double percent;
  final double price;
  final double delta;
  final double y;

  /// Where this level's line would cross the (possibly extrapolated)
  /// diagonal anchor line — i.e. its natural starting point, matching how
  /// a Fibonacci/trade-ratio fan is conventionally drawn. Overridden to the
  /// chart's left edge when [TradeRatioDrawingToolConfig.extendLeft] is set.
  final double nearX;

  final Color color;
}

/// Interactable drawing implementation for the trade ratio drawing tool.
///
/// Anchors two points defining a base price span (drawn as a diagonal
/// reference line, draggable at either corner or as a whole), then projects
/// [TradeRatioDrawingToolConfig.levels] — percentages of that span — as
/// horizontal lines. Each line starts where it crosses the (possibly
/// extrapolated) diagonal and, by default, extends a modest, fixed width
/// ([tradeRatioDefaultLevelWidth]) to the right; the right edge can be
/// dragged further out (including all the way to the chart's edge) via the
/// far-edge handle, and the left edge can be pinned to the chart's left edge
/// via the "extend left" toolbar toggle.
class TradeRatioInteractableDrawing
    extends InteractableDrawing<TradeRatioDrawingToolConfig> {
  /// Initializes [TradeRatioInteractableDrawing].
  TradeRatioInteractableDrawing({
    required TradeRatioDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : farXEpochOffset = config.farXEpochOffset,
       super(drawingConfig: config);

  /// Start anchor of the base span.
  EdgePoint? startPoint;

  /// End anchor of the base span.
  EdgePoint? endPoint;

  /// How far right of [startPoint]'s epoch the lines extend, once the user
  /// has dragged the far-edge handle. `null` means "use
  /// [tradeRatioDefaultLevelWidth]" (the default, before any dragging).
  int? farXEpochOffset;

  /// Tracks which handle is being dragged, if any.
  ///
  /// [null]: dragging the whole tool.
  ///
  /// [true]: dragging the start corner.
  ///
  /// [false]: dragging the end corner.
  bool? isDraggingStartPoint;

  /// Whether the far-edge (right side) resize handle is being dragged.
  bool _isDraggingFarXHandle = false;

  /// The X coordinate at which the (possibly extrapolated) line through
  /// [start] and [end] crosses height [y]. Falls back to [start]'s X if the
  /// line is horizontal (no unique crossing point).
  double _diagonalXAtY(Offset start, Offset end, double y) {
    if (start.dy == end.dy) {
      return start.dx;
    }

    final double t = (y - start.dy) / (end.dy - start.dy);
    return start.dx + t * (end.dx - start.dx);
  }

  /// The two endpoints of the dimmed anchor "backbone" line: from the
  /// topmost to the bottommost rendered [levels], extrapolated along the
  /// start/end diagonal — not just the raw anchor segment, which is often
  /// shorter than the full span of levels actually displayed.
  List<Offset> _backboneEndpoints(
    List<_ProjectedLevel> levels,
    Offset startOffset,
    Offset endOffset,
  ) {
    if (levels.isEmpty) {
      return <Offset>[startOffset, endOffset];
    }

    _ProjectedLevel top = levels.first;
    _ProjectedLevel bottom = levels.first;
    for (final _ProjectedLevel level in levels) {
      if (level.y < top.y) {
        top = level;
      }
      if (level.y > bottom.y) {
        bottom = level;
      }
    }

    return <Offset>[
      Offset(_diagonalXAtY(startOffset, endOffset, top.y), top.y),
      Offset(_diagonalXAtY(startOffset, endOffset, bottom.y), bottom.y),
    ];
  }

  /// The on-screen X of the far (right) edge shared by every level line.
  double _farX(EpochToX epochToX) {
    final int? offset = farXEpochOffset;
    if (offset == null) {
      return epochToX(startPoint!.epoch) + tradeRatioDefaultLevelWidth;
    }

    return epochToX(startPoint!.epoch + offset);
  }

  List<_ProjectedLevel> _projectLevels(EpochToX epochToX, QuoteToY quoteToY) {
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    final double startQuote = startPoint!.quote;
    final double span = endPoint!.quote - startQuote;
    final List<Color> colors = config.levelColors;

    final List<_ProjectedLevel> levels = <_ProjectedLevel>[];
    for (int i = 0; i < config.levels.length; i++) {
      final double percent = config.levels[i];
      // Matches ChartIQ's `retracement` tool: 0% sits at the start anchor
      // (the entry). Positive percentages extend past the start anchor,
      // away from the end anchor (e.g. 100% is one full span beyond the
      // start, on the opposite side from the end anchor). Negative
      // percentages extend past the end anchor instead, continuing in the
      // same direction as the start->end move.
      final double price = startQuote - span * (percent / 100);
      final double y = quoteToY(price);

      levels.add(
        _ProjectedLevel(
          percent: percent,
          price: price,
          delta: (price - startQuote).abs(),
          y: y,
          nearX: config.extendLeft
              ? 0
              : _diagonalXAtY(startOffset, endOffset, y),
          color: colors.isEmpty
              ? config.lineStyle.color
              : colors[i % colors.length],
        ),
      );
    }

    return levels;
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final Offset farXHandleOffset = Offset(_farX(epochToX), startOffset.dy);

    final double startDistance = (details.localPosition - startOffset).distance;
    final double endDistance = (details.localPosition - endOffset).distance;
    final double farXDistance =
        (details.localPosition - farXHandleOffset).distance;

    _isDraggingFarXHandle = false;

    if (startDistance <= hitTestMargin) {
      isDraggingStartPoint = true;
    } else if (endDistance <= hitTestMargin) {
      isDraggingStartPoint = false;
    } else if (farXDistance <= hitTestMargin) {
      isDraggingStartPoint = null;
      _isDraggingFarXHandle = true;
    } else {
      isDraggingStartPoint = null;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final double farX = _farX(epochToX);

    if ((offset - startOffset).distance <= hitTestMargin ||
        (offset - endOffset).distance <= hitTestMargin ||
        (offset - Offset(farX, startOffset.dy)).distance <= hitTestMargin) {
      return true;
    }

    final List<_ProjectedLevel> levels = _projectLevels(epochToX, quoteToY);
    for (final _ProjectedLevel level in levels) {
      final double lo = min(level.nearX, farX);
      final double hi = max(level.nearX, farX);
      if (offset.dx >= lo &&
          offset.dx <= hi &&
          (offset.dy - level.y).abs() <= tradeRatioLevelHitTolerance) {
        return true;
      }
    }

    final List<Offset> backbone = _backboneEndpoints(
      levels,
      startOffset,
      endOffset,
    );
    final Offset backboneStart = backbone[0];
    final Offset backboneEnd = backbone[1];

    final double lineLength = (backboneEnd - backboneStart).distance;
    if (lineLength < 1) {
      return false;
    }

    final double perpendicularDistance =
        ((backboneEnd.dy - backboneStart.dy) * offset.dx -
                (backboneEnd.dx - backboneStart.dx) * offset.dy +
                backboneEnd.dx * backboneStart.dy -
                backboneEnd.dy * backboneStart.dx)
            .abs() /
        lineLength;

    final double dotProduct =
        (offset.dx - backboneStart.dx) * (backboneEnd.dx - backboneStart.dx) +
        (offset.dy - backboneStart.dy) * (backboneEnd.dy - backboneStart.dy);
    final bool isWithinSegment =
        dotProduct >= 0 && dotProduct <= lineLength * lineLength;

    return isWithinSegment && perpendicularDistance <= hitTestMargin;
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    if (_isDraggingFarXHandle) {
      final double newFarX = _farX(epochToX) + details.delta.dx;
      farXEpochOffset = epochFromX(newFarX) - startPoint!.epoch;
      return;
    }

    final Offset delta = details.delta;

    if (isDraggingStartPoint != null) {
      final EdgePoint pointBeingDragged = isDraggingStartPoint!
          ? startPoint!
          : endPoint!;

      final Offset currentOffset = Offset(
        epochToX(pointBeingDragged.epoch),
        quoteToY(pointBeingDragged.quote),
      );
      final Offset newOffset = currentOffset + delta;

      final EdgePoint updatedPoint = EdgePoint(
        epoch: epochFromX(newOffset.dx),
        quote: quoteFromY(newOffset.dy),
      );

      if (isDraggingStartPoint!) {
        startPoint = updatedPoint;
      } else {
        endPoint = updatedPoint;
      }
    } else {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      final Offset newStartOffset = startOffset + delta;
      final Offset newEndOffset = endOffset + delta;

      startPoint = EdgePoint(
        epoch: epochFromX(newStartOffset.dx),
        quote: quoteFromY(newStartOffset.dy),
      );
      endPoint = EdgePoint(
        epoch: epochFromX(newEndOffset.dx),
        quote: quoteFromY(newEndOffset.dy),
      );
    }
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    isDraggingStartPoint = null;
    _isDraggingFarXHandle = false;

    // Fold the dragged points into `config` immediately. Nothing else ever
    // refreshes this instance's `config` from what gets persisted, so
    // without this, the next toolbar color/thickness change would build its
    // `config.copyWith(...)` off the pre-drag `config` (whose `edgePoints`
    // are stale) and silently revert this move/resize on next reload.
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
    if (startPoint == null || endPoint == null) {
      return;
    }

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );
    final double farX = _farX(epochToX);
    final List<_ProjectedLevel> levels = _projectLevels(epochToX, quoteToY);

    // The anchor line is drawn dimmed and extended to span from the topmost
    // to the bottommost rendered level (extrapolated along the same
    // diagonal), not just between the two raw anchor points — matching the
    // reference tool, whose two clicks (0% and, implicitly, -100%) are
    // rarely the extremes of the level fan actually shown.
    final List<Offset> backbone = _backboneEndpoints(
      levels,
      startOffset,
      endOffset,
    );
    canvas.drawLine(
      backbone[0],
      backbone[1],
      paintStyle.linePaintStyle(
        lineStyle.color.withValues(alpha: 0.25),
        lineStyle.thickness,
      ),
    );

    for (int i = 0; i < levels.length; i++) {
      final _ProjectedLevel level = levels[i];

      canvas.drawLine(
        Offset(level.nearX, level.y),
        Offset(farX, level.y),
        paintStyle.linePaintStyle(level.color, lineStyle.thickness),
      );

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text:
              '${level.price.toStringAsFixed(chartConfig.pipSize)}  '
              '${level.delta.toStringAsFixed(chartConfig.pipSize)}  '
              '${level.percent.toStringAsFixed(level.percent % 1 == 0 ? 0 : 1)}%',
          style: config.labelStyle.copyWith(color: level.color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelX = min(level.nearX, farX) + tradeRatioLabelPadding;
      // Sit just above the line rather than centered on it — centering
      // makes the line cut straight through the text.
      labelPainter.paint(
        canvas,
        Offset(labelX, level.y - labelPainter.height - 2),
      );
    }

    if (drawingState.contains(DrawingToolState.selected)) {
      final Paint neonPaint = Paint()
        ..color = lineStyle.color.withValues(alpha: 0.4)
        ..strokeWidth = 8 * animationInfo.stateChangePercent
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(startOffset, endOffset, neonPaint);
    }

    if (drawingState.contains(DrawingToolState.selected) ||
        drawingState.contains(DrawingToolState.hovered) ||
        drawingState.contains(DrawingToolState.dragging)) {
      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      drawPointOffset(
        endOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );
      // The far-edge (width) resize handle.
      drawPointOffset(
        Offset(farX, startOffset.dy),
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 4,
      );

      if (drawingState.contains(DrawingToolState.dragging)) {
        final Offset? draggedOffset = _isDraggingFarXHandle
            ? Offset(farX, startOffset.dy)
            : isDraggingStartPoint == null
            ? null
            : (isDraggingStartPoint! ? startOffset : endOffset);

        if (draggedOffset != null) {
          drawFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            draggedOffset,
            10 * animationInfo.stateChangePercent,
            3 * animationInfo.stateChangePercent,
          );
        }
      } else if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.hovered)) {
        drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          drawingState.contains(DrawingToolState.selected)
              ? 10 * animationInfo.stateChangePercent
              : 10,
          drawingState.contains(DrawingToolState.selected)
              ? 3 * animationInfo.stateChangePercent
              : 3,
          endOffset,
        );
      }
    }

    if (drawingState.contains(DrawingToolState.dragging)) {
      if (_isDraggingFarXHandle) {
        drawPointAlignmentGuides(
          canvas,
          size,
          Offset(farX, startOffset.dy),
          lineColor: lineStyle.color,
        );
      } else if (isDraggingStartPoint == null) {
        drawPointAlignmentGuides(
          canvas,
          size,
          startOffset,
          lineColor: lineStyle.color,
        );
        drawPointAlignmentGuides(
          canvas,
          size,
          endOffset,
          lineColor: lineStyle.color,
        );
      } else {
        drawPointAlignmentGuides(
          canvas,
          size,
          isDraggingStartPoint! ? startOffset : endOffset,
          lineColor: lineStyle.color,
        );
      }
    }
  }

  @override
  TradeRatioDrawingToolConfig getUpdatedConfig() => config.copyWith(
    edgePoints: <EdgePoint>[?startPoint, ?endPoint],
    farXEpochOffset: farXEpochOffset,
  );

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) {
    if (startPoint == null || endPoint == null) {
      return true;
    }

    if (startPoint!.isInEpochRange(
          epochRange.leftEpoch,
          epochRange.rightEpoch,
        ) ||
        endPoint!.isInEpochRange(epochRange.leftEpoch, epochRange.rightEpoch)) {
      return true;
    }

    // Neither anchor is in range, but the level lines can extend well past
    // them — all the way to the chart's left edge when `extendLeft` is set,
    // or out to wherever the far-edge handle was dragged — so a drawing
    // whose anchors have both scrolled off-screen can still be partially
    // visible. Only cull it once the rendered extent is confirmed to not
    // overlap the visible range.
    if (config.extendLeft) {
      return true;
    }

    final int? offset = farXEpochOffset;
    if (offset == null) {
      return false;
    }

    final int farEpoch = startPoint!.epoch + offset;
    final int lowEpoch = min(startPoint!.epoch, farEpoch);
    final int highEpoch = max(startPoint!.epoch, farEpoch);
    return highEpoch >= epochRange.leftEpoch &&
        lowEpoch <= epochRange.rightEpoch;
  }

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => TradeRatioAddingPreviewDesktop(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
  getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) => TradeRatioAddingPreviewMobile(
    interactiveLayerBehaviour: layerBehaviour,
    interactableDrawing: this,
    onAddingStateChange: onAddingStateChange,
  );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
    children: <Widget>[
      _buildLineThicknessIcon(onUpdate),
      const SizedBox(width: 4),
      _buildLineColorPickerIcon(onUpdate),
      const SizedBox(width: 4),
      _buildExtendLeftToggle(onUpdate),
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

  Widget _buildLineThicknessIcon(UpdateDrawingTool onUpdate) =>
      LineThicknessDropdownButton(
        thickness: config.lineStyle.thickness,
        onValueChanged: (double newValue) {
          onUpdate(
            config.copyWith(
              lineStyle: config.lineStyle.copyWith(thickness: newValue),
            ),
          );
        },
      );

  Widget _buildExtendLeftToggle(UpdateDrawingTool onUpdate) => SizedBox(
    width: 32,
    height: 32,
    child: IconButton(
      padding: EdgeInsets.zero,
      tooltip: 'Extend left',
      isSelected: config.extendLeft,
      icon: const Icon(Icons.horizontal_rule, size: 18),
      selectedIcon: const Icon(Icons.keyboard_double_arrow_left, size: 18),
      onPressed: () =>
          onUpdate(config.copyWith(extendLeft: !config.extendLeft)),
    ),
  );
}
