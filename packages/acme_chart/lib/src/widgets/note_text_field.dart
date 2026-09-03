import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../misc/debounce.dart';

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

  final FocusNode _focusNode = FocusNode();

  final Debounce _saveDebounce = Debounce(delay: notesTextSaveDebounce);

  @override
  void didUpdateWidget(NoteTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_focusNode.hasFocus && widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    // Flush a pending edit rather than losing it, but defer the callback via
    // a microtask instead of calling it synchronously here: `dispose()` runs
    // mid-teardown as part of the current widget-tree rebuild, and
    // `onChanged` ultimately triggers `setState` on an unrelated ancestor
    // (the interactive layer syncing with the drawings repository) — calling
    // it synchronously risks Flutter's "setState() called during build"
    // hazard. A microtask runs after the current build/dispose pass finishes.
    if (_controller.text != widget.text) {
      final String pendingText = _controller.text;
      final ValueChanged<String> onChanged = widget.onChanged;
      scheduleMicrotask(() => onChanged(pendingText));
    }
    _saveDebounce.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _saveDebounce.run(() => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: _focusNode,
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
