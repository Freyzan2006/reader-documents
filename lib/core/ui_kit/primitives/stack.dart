import 'package:flutter/widgets.dart';

/// An overlaid layout, like [Stack], but centered by default — [Stack]
/// itself defaults to top-start, which is rarely what an overlay (a badge,
/// a spinner over content) actually wants.
class AppStack extends StatelessWidget {
  const AppStack({
    required this.children,
    this.alignment = AlignmentDirectional.center,
    this.fit = StackFit.loose,
    super.key,
  });

  final List<Widget> children;
  final AlignmentGeometry alignment;
  final StackFit fit;

  @override
  Widget build(BuildContext context) =>
      Stack(alignment: alignment, fit: fit, children: children);
}
