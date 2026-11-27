import 'package:flutter/widgets.dart';

import '../data_display/text.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  static const _width = 44.0;
  static const _height = 26.0;
  static const _thumb = 20.0;
  static const _inset = 3.0;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final onChanged = this.onChanged;
    final text = label;

    return Semantics(
      toggled: value,
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
              if (text != null) Flexible(child: AppText(text)),
              AppFocusRing(
                visible: state.focused,
                borderRadius: AppRadii.pill,
                child: AnimatedContainer(
                  duration: tokens.motion.quick,
                  curve: Curves.easeOut,
                  width: _width,
                  height: _height,
                  padding: const EdgeInsets.all(_inset),
                  decoration: BoxDecoration(
                    color: value ? palette.ink : palette.shadeStrong,
                    borderRadius: AppRadii.pill,
                    border: value
                        ? null
                        : Border.all(
                            color: palette.ruleStrong,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                  ),
                  child: AnimatedAlign(
                    duration: tokens.motion.quick,
                    curve: Curves.easeOut,
                    alignment: value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: _thumb,
                      height: _thumb,
                      decoration: BoxDecoration(
                        color: value ? palette.onInk : palette.sheet,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3D000000),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
