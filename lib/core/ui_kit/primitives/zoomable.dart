import 'package:flutter/widgets.dart';

class AppZoomable extends StatelessWidget {
  const AppZoomable({
    required this.child,
    this.minScale = 1,
    this.maxScale = 4,
    super.key,
  });

  final Widget child;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) =>
      InteractiveViewer(minScale: minScale, maxScale: maxScale, child: child);
}
