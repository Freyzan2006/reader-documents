import 'package:flutter/widgets.dart';

import '../data_display/text.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';

class AppCheckMark extends StatelessWidget {
  const AppCheckMark({
    required this.checked,
    this.round = false,
    this.size = 22,
    super.key,
  });

  final bool checked;
  final bool round;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final radius = round ? AppRadii.pill : AppRadii.xs;

    return AnimatedContainer(
      duration: tokens.motion.quick,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? palette.ink : palette.sheet,
        borderRadius: radius,
        border: Border.all(
          color: checked ? palette.ink : palette.ruleStrong,
          width: 1.5,
        ),
      ),
      child: checked
          ? Icon(AppIcons.check, size: size * 0.7, color: palette.onInk)
          : null,
    );
  }
}

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final text = label;

    return Semantics(
      checked: value,
      child: AppTappable.builder(
        onPressed: onChanged == null ? null : () => onChanged(!value),
        semanticsLabel: text,
        excludeChildSemantics: true,
        builder: (context, state) => Opacity(
          opacity: state.enabled ? 1 : 0.38,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              AppFocusRing(
                visible: state.focused,
                borderRadius: AppRadii.xs,
                child: AppCheckMark(checked: value),
              ),
              if (text != null) Flexible(child: AppText(text)),
            ],
          ),
        ),
      ),
    );
  }
}
