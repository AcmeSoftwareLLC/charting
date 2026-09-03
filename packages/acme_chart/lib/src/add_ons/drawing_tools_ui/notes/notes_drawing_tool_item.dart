import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/notes/notes_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:acme_chart/src/core/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:acme_chart/src/theme/painting_styles/line_style.dart';

import 'package:material_ui/material_ui.dart';

import '../drawing_tool_item.dart';

/// Notes drawing tool item in the list of drawing tool which provide this
/// drawing tools options menu.
class NotesDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const NotesDrawingToolItem({
    required super.updateDrawingTool,
    required super.deleteDrawingTool,
    super.key,
    NotesDrawingToolConfig super.config = const NotesDrawingToolConfig(),
  }) : super(title: 'Notes');

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      NotesDrawingToolItemState();
}

/// Notes drawing tool Item State class
class NotesDrawingToolItemState
    extends DrawingToolItemState<NotesDrawingToolConfig> {
  LineStyle? _lineStyle;
  LineStyle? _fillStyle;
  DrawingPatterns? _pattern;

  @override
  NotesDrawingToolConfig createDrawingToolConfig() {
    final NotesDrawingToolConfig current =
        widget.config as NotesDrawingToolConfig;

    // This item only manages line/fill/pattern below; text is edited inline
    // on the canvas and width/height/textStyle aren't editable here at all,
    // so those must be carried over from the current config or they'd
    // silently reset to their defaults on any color change.
    return NotesDrawingToolConfig(
      text: current.text,
      lineStyle: _currentLineStyle,
      fillStyle: _currentFillStyle,
      pattern: _currentPattern,
      textStyle: current.textStyle,
      width: current.width,
      height: current.height,
    );
  }

  @override
  Widget getDrawingToolOptions() => Column(
    children: <Widget>[
      _buildColorField(
        ChartLocalization.of(context).labelColor,
        _currentLineStyle,
      ),
      _buildColorField(
        ChartLocalization.of(context).labelFillColor,
        _currentFillStyle,
      ),
      // TODO(NA): implement pattern field to set pattern
    ],
  );

  Widget _buildColorField(String label, LineStyle style) => Row(
    children: <Widget>[
      Text(label, style: const TextStyle(fontSize: 16)),
      ColorSelector(
        currentColor: style.color,
        onColorChanged: (Color selectedColor) {
          setState(() {
            final LineStyle newColor = style.copyWith(color: selectedColor);
            if (label == ChartLocalization.of(context).labelColor) {
              _lineStyle = newColor;
            } else {
              _fillStyle = newColor;
            }
          });
          updateDrawingTool();
        },
      ),
    ],
  );

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as NotesDrawingToolConfig).lineStyle;

  LineStyle get _currentFillStyle =>
      _fillStyle ?? (widget.config as NotesDrawingToolConfig).fillStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as NotesDrawingToolConfig).pattern;
}
