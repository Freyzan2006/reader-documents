import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../tokens/app_spacing.dart';
import 'text.dart';

class AppCollapsible extends StatefulWidget {
  const AppCollapsible({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<AppCollapsible> createState() => _AppCollapsibleState();
}

class _AppCollapsibleState extends State<AppCollapsible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.initiallyExpanded ? 1 : 0,
  );
  late bool _expanded = widget.initiallyExpanded;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FTappable(
        onPress: _toggle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: AppText(widget.title)),
            RotationTransition(
              turns: _controller.drive(Tween(begin: 0, end: 0.5)),
              child: Icon(
                FLucideIcons.chevronDown,
                size: 20,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
      AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            FCollapsible(value: _controller.value, child: child!),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: widget.child,
        ),
      ),
    ],
  );
}
