import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

class AppSegment<T> {
  const AppSegment({
    required this.value,
    this.label,
    this.icon,
    this.semanticsLabel,
  }) : assert(label != null || icon != null);

  final T value;
  final String? label;
  final IconData? icon;
  final String? semanticsLabel;
}

class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.expand = false,
    super.key,
  });

  static const _height = 30.0;
  static const _inset = 3.0;

  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;

    return Container(
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: palette.shade,
        borderRadius: AppRadii.sm,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        spacing: 2,
        children: [
          for (final segment in segments)
            _wrap(
              AppTappable(
                onPressed: () => onChanged(segment.value),
                selected: segment.value == value,
                semanticsLabel: segment.semanticsLabel ?? segment.label,
                excludeChildSemantics: true,
                pressedOpacity: 0.8,
                child: AnimatedContainer(
                  duration: tokens.motion.quick,
                  height: _height,
                  constraints: const BoxConstraints(minWidth: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: segment.value == value
                        ? palette.sheet
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: segment.value == value
                          ? palette.rule
                          : const Color(0x00000000),
                    ),
                  ),
                  child: _SegmentContent(
                    segment: segment,
                    color: segment.value == value ? palette.ink : palette.ink2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrap(Widget child) => expand ? Expanded(child: child) : child;
}

class _SegmentContent<T> extends StatelessWidget {
  const _SegmentContent({required this.segment, required this.color});

  final AppSegment<T> segment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = segment.icon;
    final label = segment.label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (icon != null) Icon(icon, size: 16, color: color),
        if (label != null)
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                height: 18 / 13,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}
