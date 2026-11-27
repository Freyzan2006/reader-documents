import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_typography.dart';
import 'text_selection.dart';

class AppEditableText extends StatefulWidget {
  const AppEditableText({
    required this.controller,
    required this.focusNode,
    this.hint,
    this.style,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.semanticsLabel,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hint;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final String? semanticsLabel;

  @override
  State<AppEditableText> createState() => _AppEditableTextState();
}

class _AppEditableTextState extends State<AppEditableText>
    implements TextSelectionGestureDetectorBuilderDelegate {
  static final _selectionControls = AppTextSelectionControls();

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(AppEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final style = (widget.style ?? AppTextStyles.body).copyWith(
      color: widget.enabled ? palette.ink : palette.ink3,
    );
    final hint = widget.hint;
    final showHint = hint != null && widget.controller.text.isEmpty;

    final editable = EditableText(
      key: editableTextKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: style,
      textAlign: widget.textAlign,
      cursorColor: palette.ink,
      backgroundCursorColor: palette.ink3,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(1),
      selectionColor: palette.ink.withValues(alpha: 0.2),
      selectionControls: widget.enabled ? _selectionControls : null,
      contextMenuBuilder: AppTextContextMenu.builder,
      obscureText: widget.obscureText,
      autocorrect: !widget.obscureText,
      enableSuggestions: !widget.obscureText,
      readOnly: !widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      keyboardAppearance: palette.brightness,
      maxLines: 1,
      rendererIgnoresPointer: true,
      enableInteractiveSelection: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );

    return Semantics(
      label: widget.semanticsLabel ?? hint,
      textField: true,
      enabled: widget.enabled,
      child: _gestures.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            if (showHint)
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Align(
                      alignment: switch (widget.textAlign) {
                        TextAlign.center => Alignment.center,
                        TextAlign.right ||
                        TextAlign.end => AlignmentDirectional.centerEnd,
                        _ => AlignmentDirectional.centerStart,
                      },
                      child: Text(
                        hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.copyWith(color: palette.ink3),
                      ),
                    ),
                  ),
                ),
              ),
            editable,
          ],
        ),
      ),
    );
  }
}
