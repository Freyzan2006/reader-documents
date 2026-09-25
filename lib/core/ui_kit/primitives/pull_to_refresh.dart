import 'package:flutter/widgets.dart';

import '../feedback/spinner.dart';

class AppPullToRefresh extends StatefulWidget {
  const AppPullToRefresh({
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 80,
    this.indicatorOffset = 0,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double triggerDistance;
  final double indicatorOffset;

  @override
  State<AppPullToRefresh> createState() => _AppPullToRefreshState();
}

class _AppPullToRefreshState extends State<AppPullToRefresh> {
  double _pull = 0;
  bool _refreshing = false;
  bool _armed = false;

  bool _onNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical || _refreshing) return false;

    if (notification is ScrollStartNotification) {
      _armed =
          notification.dragDetails != null &&
          notification.metrics.extentBefore == 0;
    } else if (notification is OverscrollNotification) {
      if (_armed &&
          notification.metrics.extentBefore == 0 &&
          notification.overscroll < 0) {
        setState(
          () => _pull = (_pull - notification.overscroll).clamp(
            0,
            widget.triggerDistance * 1.5,
          ),
        );
      }
    } else if (notification is ScrollEndNotification) {
      _armed = false;
      if (_pull >= widget.triggerDistance) {
        _refresh();
      } else if (_pull > 0) {
        setState(() => _pull = 0);
      }
    }
    return false;
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _pull = widget.triggerDistance;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _pull = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: Stack(
          children: [
            Positioned.fill(child: widget.child),
            Positioned(
              top: widget.indicatorOffset,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: _pull,
                alignment: Alignment.center,
                child: _pull > 0 || _refreshing
                    ? const AppSpinner(size: AppSpinnerSize.lg)
                    : null,
              ),
            ),
          ],
        ),
      );
}
