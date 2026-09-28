import 'package:flutter/widgets.dart';

/// A warm, sepia-like tint over [child] for low-light reading comfort —
/// independent of the app's light/dark theme, and applied purely at paint
/// time, so it works the same for any document format.
class DocumentReadingFilter extends StatelessWidget {
  const DocumentReadingFilter({
    required this.enabled,
    required this.child,
    super.key,
  });

  static const _warmTint = Color(0xFFFFD9A0);

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => enabled
      ? ColorFiltered(
          colorFilter: const ColorFilter.mode(_warmTint, BlendMode.multiply),
          child: child,
        )
      : child;
}
