import 'package:acme_chart/src/widgets/color_picker/color_button.dart';
import 'package:acme_chart/src/widgets/color_picker/color_picker_sheet.dart';
import 'package:flutter/material.dart';

/// Color selector widget.
class ColorSelector extends StatelessWidget {
  /// Initializes
  const ColorSelector({
    required this.currentColor,
    required this.onColorChanged,
    super.key,
  });

  /// Current color.
  final Color currentColor;

  /// Will be called when a color is selected from [ColorPickerSheet].
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) => ColorButton(
        color: currentColor,
        onTap: () {
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) => ColorPickerSheet(
              selectedColor: currentColor,
              onChanged: onColorChanged,
            ),
          );
        },
      );
}
