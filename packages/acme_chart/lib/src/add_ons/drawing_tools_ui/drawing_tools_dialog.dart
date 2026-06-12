import 'package:acme_chart/generated/l10n.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/channel/channel_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/continuous/continuous_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/ray/ray_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:acme_chart/src/core/drawing_tool_chart/drawing_tools.dart';
import 'package:acme_chart/src/core/interactive_layer/interactive_layer_controller.dart';
import 'package:acme_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawing_tool_config.dart';
import 'package:acme_chart/src/add_ons/repository.dart';

/// Drawing tools dialog with available drawing tools.
class DrawingToolsDialog extends StatefulWidget {
  /// Creates drawing tools dialog.
  const DrawingToolsDialog({
    required this.drawingTools,
    required this.interactiveLayerController,
    super.key,
  });

  /// Keep the reference to the drawing tools class for
  /// sharing data between the AcmeChart and the DrawingToolsDialog
  final DrawingTools drawingTools;

  /// Controller for the interactive layer.
  final InteractiveLayerController interactiveLayerController;

  @override
  State<DrawingToolsDialog> createState() => _DrawingToolsDialogState();
}

class _DrawingToolsDialogState extends State<DrawingToolsDialog> {
  DrawingToolConfig? _selectedDrawingTool;

  @override
  Widget build(BuildContext context) {
    final Repository<DrawingToolConfig> repo = context
        .watch<Repository<DrawingToolConfig>>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<DrawingToolConfig>(
                value: _selectedDrawingTool,
                hint: Text(ChartLocalization.of(context).selectDrawingTool),
                items: const <DropdownMenuItem<DrawingToolConfig>>[
                  DropdownMenuItem<DrawingToolConfig>(
                    value: ChannelDrawingToolConfig(),
                    child: Text('Channel'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: ContinuousDrawingToolConfig(),
                    child: Text('Continuous'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: FibfanDrawingToolConfig(),
                    child: Text('Fib Fan'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: HorizontalDrawingToolConfig(),
                    child: Text('Horizontal'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: LineDrawingToolConfig(),
                    child: Text('Line'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: RayDrawingToolConfig(),
                    child: Text('Ray'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: RectangleDrawingToolConfig(),
                    child: Text('Rectangle'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: TrendDrawingToolConfig(),
                    child: Text('Trend'),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    value: VerticalDrawingToolConfig(),
                    child: Text('Vertical'),
                  ),
                  // TODO(maryia-binary): add the rest of drawing tools above
                ],
                onChanged: (DrawingToolConfig? config) {
                  setState(() {
                    _selectedDrawingTool = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _selectedDrawingTool != null
                    ? () {
                        widget.interactiveLayerController.startAddingNewTool(
                          _selectedDrawingTool!,
                        );
                        repo.update();
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Add'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.items.length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.items[index].getItem(
                    (DrawingToolConfig updatedConfig) {
                      DrawingToolConfig config = updatedConfig;

                      config = config.copyWith(
                        configId: repo.items[index].configId,
                        edgePoints: repo.items[index].edgePoints,
                        drawingData: repo.items[index].drawingData,
                      );

                      repo.updateAt(index, config);
                    },
                    () {
                      repo.removeAt(index);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
