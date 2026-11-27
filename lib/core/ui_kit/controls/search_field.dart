import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'editable_text.dart';
import 'icon_button.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.clearLabel,
    this.trailing,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  static const _height = 44.0;

  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? clearLabel;
  final Widget? trailing;
  final bool autofocus;
  final bool enabled;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final hasText = widget.controller.text.isNotEmpty;
    final trailing = widget.trailing;

    return Container(
      height: AppSearchField._height,
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: 2),
      decoration: BoxDecoration(
        color: palette.shade,
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Icon(AppIcons.search, size: 18, color: palette.ink3),
          Expanded(
            child: AppEditableText(
              controller: widget.controller,
              focusNode: _focusNode,
              hint: widget.hint,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (hasText)
            AppIconButton(
              icon: AppIcons.x,
              onPressed: _clear,
              semanticsLabel: widget.clearLabel,
              color: palette.ink2,
            )
          else
            ?trailing,
        ],
      ),
    );
  }
}
