import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Linear progress indicator. Wraps Forui's [FDeterminateProgress] when [value]
/// is given and its indeterminate [FProgress] otherwise.
///
/// Pass [trackColor]/[fillColor] only where the surrounding surface makes the
/// theme's `muted`/`primary` unreadable — the launch screen paints a forced
/// black background, where the theme has nothing to say.
class AppProgress extends StatelessWidget {
  const AppProgress({this.value, this.trackColor, this.fillColor, super.key});

  final double? value;
  final Color? trackColor;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final trackDecoration = trackColor == null
        ? null
        : DecorationDelta.shapeDelta(color: trackColor);
    final fillDecoration = fillColor == null
        ? null
        : DecorationDelta.shapeDelta(color: fillColor);

    if (value == null) {
      return FProgress(
        style: FProgressStyleDelta.delta(
          trackDecoration: trackDecoration,
          fillDecoration: fillDecoration,
        ),
      );
    }
    return FDeterminateProgress(
      value: value!,
      style: FDeterminateProgressStyleDelta.delta(
        trackDecoration: trackDecoration,
        fillDecoration: fillDecoration,
      ),
    );
  }
}
