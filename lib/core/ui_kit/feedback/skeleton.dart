import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_radius.dart';

/// A pulsing placeholder box shown while content is loading.
///
/// Forui has no equivalent widget (its Feedback widgets are Alert and
/// Progress only), so this is built from scratch: a looping opacity fade
/// over a [Container] filled with the theme's muted color.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({this.width, this.height = 16, super.key});

  final double? width;
  final double height;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller.drive(Tween(begin: 0.4, end: 1.0)),
    child: Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.theme.colors.muted,
        borderRadius: AppRadius.of(context).sm,
      ),
    ),
  );
}
