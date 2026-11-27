import 'package:flutter/widgets.dart';

import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_palette.dart';
import '../theme/graphics_mode.dart';
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

class AppSegmented<T> extends StatefulWidget {
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
  State<AppSegmented<T>> createState() => _AppSegmentedState<T>();
}

class _AppSegmentedState<T> extends State<AppSegmented<T>> {
  final _stackKey = GlobalKey();
  List<GlobalKey> _keys = const [];
  Rect? _plate;

  static BoxDecoration _plateDecoration(AppPalette palette) => BoxDecoration(
    color: palette.sheet,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: palette.rule),
  );

  void _syncKeys() {
    if (_keys.length != widget.segments.length) {
      _keys = [for (final _ in widget.segments) GlobalKey()];
    }
  }

  void _measure() {
    if (!mounted) return;
    final index = widget.segments.indexWhere(
      (segment) => segment.value == widget.value,
    );
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final item = index < 0
        ? null
        : _keys[index].currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || item == null || !stack.hasSize || !item.hasSize) {
      return;
    }
    final rect = item.localToGlobal(Offset.zero, ancestor: stack) & item.size;
    if (rect != _plate) setState(() => _plate = rect);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    final plate = _plate;
    final sliding = tokens.motion.slide;
    _syncKeys();
    if (sliding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
    final drawPlate = sliding && plate != null;

    return Container(
      padding: const EdgeInsets.all(AppSegmented._inset),
      decoration: BoxDecoration(
        color: palette.shade,
        borderRadius: AppRadii.sm,
      ),
      child: Stack(
        key: _stackKey,
        children: [
          if (drawPlate)
            AnimatedPositioned.fromRect(
              rect: plate,
              duration: tokens.motion.quick,
              curve: AppMotion.curve,
              child: DecoratedBox(decoration: _plateDecoration(palette)),
            ),
          Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            spacing: 2,
            children: [
              for (final (index, segment) in widget.segments.indexed)
                _wrap(
                  AppTappable(
                    key: _keys[index],
                    onPressed: () => widget.onChanged(segment.value),
                    selected: segment.value == widget.value,
                    semanticsLabel: segment.semanticsLabel ?? segment.label,
                    excludeChildSemantics: true,
                    pressedOpacity: 0.8,
                    child: Container(
                      height: AppSegmented._height,
                      constraints: const BoxConstraints(minWidth: 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: drawPlate || segment.value != widget.value
                          ? null
                          : _plateDecoration(palette),
                      child: _SegmentContent(
                        segment: segment,
                        color: segment.value == widget.value
                            ? palette.ink
                            : palette.ink2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wrap(Widget child) => widget.expand ? Expanded(child: child) : child;
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
