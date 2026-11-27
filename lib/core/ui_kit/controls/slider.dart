import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    this.value = 0.25,
    this.onChanged,
    this.enabled = true,
    this.semanticsLabel,
    super.key,
  });

  static const _trackHeight = 4.0;
  static const _thumb = 20.0;
  static const _height = 32.0;
  static const _step = 0.05;

  final double value;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final String? semanticsLabel;

  bool get _active => enabled && onChanged != null;

  static String _percent(double fraction) =>
      '${(fraction.clamp(0.0, 1.0) * 100).round()}%';

  void _emit(double next) => onChanged?.call(next.clamp(0.0, 1.0));

  void _seek(Offset local, double width) {
    final usable = width - _thumb;
    if (usable <= 0) return;
    _emit((local.dx - _thumb / 2) / usable);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final fraction = value.clamp(0.0, 1.0);

    return Semantics(
      slider: true,
      enabled: _active,
      label: semanticsLabel,
      value: _percent(fraction),
      increasedValue: _percent(fraction + _step),
      decreasedValue: _percent(fraction - _step),
      onIncrease: _active ? () => _emit(fraction + _step) : null,
      onDecrease: _active ? () => _emit(fraction - _step) : null,
      child: Opacity(
        opacity: _active ? 1 : 0.38,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final usable = width - _thumb;
            final thumbLeft = usable * fraction;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapDown: _active
                  ? (details) => _seek(details.localPosition, width)
                  : null,
              onHorizontalDragUpdate: _active
                  ? (details) => _seek(details.localPosition, width)
                  : null,
              child: SizedBox(
                height: _height,
                width: width,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: _thumb / 2,
                      right: _thumb / 2,
                      child: Container(
                        height: _trackHeight,
                        decoration: BoxDecoration(
                          color: palette.shadeStrong,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _thumb / 2,
                      width: thumbLeft,
                      child: Container(
                        height: _trackHeight,
                        decoration: BoxDecoration(
                          color: palette.ink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: thumbLeft,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: BoxDecoration(
                          color: palette.ink,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.sheet,
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
