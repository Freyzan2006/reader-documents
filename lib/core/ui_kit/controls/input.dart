import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'editable_text.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.help,
    this.error,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    super.key,
  });

  static const _height = 44.0;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? help;
  final String? error;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final label = widget.label;
    final help = widget.help;
    final error = widget.error;
    final prefixIcon = widget.prefixIcon;
    final suffix = widget.suffix;
    final focused = _focusNode.hasFocus;
    final borderColor = error != null
        ? palette.danger
        : focused
        ? palette.ink
        : palette.ruleStrong;

    final field = AnimatedContainer(
      duration: tokens.motion.quick,
      constraints: const BoxConstraints(minHeight: AppInput._height),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.enabled ? palette.sheet : palette.shade,
        borderRadius: AppRadii.sm,
        border: Border.all(
          color: borderColor,
          width: focused || error != null ? 2 : 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          if (prefixIcon != null)
            Icon(prefixIcon, size: 18, color: palette.ink3),
          Expanded(
            child: AppEditableText(
              controller: _controller,
              focusNode: _focusNode,
              hint: widget.hint,
              semanticsLabel: label ?? widget.hint,
              textAlign: widget.textAlign,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
            ),
          ),
          if (suffix != null)
            DefaultTextStyle.merge(
              style: AppTextStyles.meta.copyWith(color: palette.ink3),
              child: suffix,
            ),
        ],
      ),
    );

    if (label == null && help == null && error == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (label != null)
          ExcludeSemantics(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                height: 18 / 13,
                color: palette.ink2,
              ),
            ),
          ),
        field,
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: palette.danger,
              ),
            ),
          )
        else if (help != null)
          Text(
            help,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: palette.ink3,
            ),
          ),
      ],
    );
  }
}
