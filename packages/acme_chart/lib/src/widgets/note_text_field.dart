import 'dart:async';

import 'package:flutter/material.dart';

/// Placeholder shown inside an empty note box.
const String notesEmptyPlaceholder = 'Add note...';

/// How long to wait after the last keystroke before persisting the note's
/// text, so typing doesn't trigger a storage write on every character.
const Duration notesTextSaveDebounce = Duration(milliseconds: 400);

/// A borderless, multi-line text field used to edit a note's content in
/// place, directly on top of where the note is drawn on the chart.
///
/// Keeps its own [TextEditingController] so the cursor position survives
/// rebuilds triggered by [onChanged] updating the drawing's config.
class NoteTextField extends StatefulWidget {
  /// Initializes [NoteTextField].
  const NoteTextField({
    required this.text,
    required this.style,
    required this.onChanged,
    super.key,
  });

  /// The current text of the note.
  final String text;

  /// The text style to render the note's content with.
  final TextStyle style;

  /// Called with the new text whenever the user edits it.
  final ValueChanged<String> onChanged;

  @override
  State<NoteTextField> createState() => _NoteTextFieldState();
}

class _NoteTextFieldState extends State<NoteTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  Timer? _saveDebounce;

  @override
  void didUpdateWidget(NoteTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    if (_saveDebounce != null && _controller.text != widget.text) {
      final String pendingText = _controller.text;
      final ValueChanged<String> onChanged = widget.onChanged;
      scheduleMicrotask(() => onChanged(pendingText));
    }
    _saveDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(notesTextSaveDebounce, () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    autofocus: true,
    maxLines: null,
    style: widget.style,
    cursorColor: widget.style.color,
    decoration: InputDecoration.collapsed(
      hintText: notesEmptyPlaceholder,
      hintStyle: widget.style.copyWith(
        color: widget.style.color?.withValues(alpha: 0.6),
      ),
    ),
    onChanged: _onChanged,
  );
}
