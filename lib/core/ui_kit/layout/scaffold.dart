import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';

class AppScrollScope extends InheritedWidget {
  const AppScrollScope({
    required this.scrolled,
    required super.child,
    super.key,
  });

  final bool scrolled;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScrollScope>()?.scrolled ??
      false;

  @override
  bool updateShouldNotify(AppScrollScope oldWidget) =>
      scrolled != oldWidget.scrolled;
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    required this.child,
    this.header,
    this.sidebar,
    this.footer,
    this.scrolledThreshold = 8,
    this.contentKey,
    super.key,
  });

  final Widget child;
  final Widget? header;
  final Widget? sidebar;
  final Widget? footer;
  final double scrolledThreshold;
  final Object? contentKey;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _scrolled = false;

  @override
  void didUpdateWidget(AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentKey != widget.contentKey) _scrolled = false;
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final scrolled =
        notification.metrics.extentBefore > widget.scrolledThreshold;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final header = widget.header;
    final footer = widget.footer;
    final sidebar = widget.sidebar;
    final body = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: widget.child,
    );

    final content = AppScrollScope(
      scrolled: _scrolled,
      child: Stack(
        children: [
          Positioned.fill(child: body),
          if (header != null)
            Positioned(top: 0, left: 0, right: 0, child: header),
          if (footer != null)
            Positioned(bottom: 0, left: 0, right: 0, child: footer),
        ],
      ),
    );

    return ColoredBox(
      color: context.tokens.palette.paper,
      child: sidebar == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sidebar,
                Expanded(child: content),
              ],
            ),
    );
  }
}
