import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import 'barrier.dart';
import 'edge.dart';
import 'modal_route.dart';
import 'sheet_surface.dart';

typedef AppSheetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

abstract final class AppSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required AppSheetBuilder builder,
    double initialSize = 0.5,
    double minSize = 0.25,
    double maxSize = 1.0,
    AppBarrierVariant? barrierVariant,
    String? dismissLabel,
  }) => _push(
    context,
    barrierVariant: barrierVariant,
    dismissLabel: dismissLabel,
    builder: (context) => _DraggableSheet(
      initialSize: initialSize,
      minSize: minSize,
      maxSize: maxSize,
      builder: builder,
    ),
  );

  static Future<T?> showContent<T>({
    required BuildContext context,
    required AppSheetBuilder builder,
    AppBarrierVariant? barrierVariant,
    String? dismissLabel,
  }) => _push(
    context,
    barrierVariant: barrierVariant,
    dismissLabel: dismissLabel,
    builder: (context) => _ContentSheet(builder: builder),
  );

  static Future<T?> _push<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    AppBarrierVariant? barrierVariant,
    String? dismissLabel,
  }) {
    HapticFeedback.lightImpact();
    return Navigator.of(context).push(
      AppModalRoute<T>(
        placement: AppModalPlacement.bottom,
        tokens: context.tokens,
        barrier: AppBarrier.resolve(context, barrierVariant),
        dismissLabel: dismissLabel,
        builder: (context) => _KeyboardAware(child: builder(context)),
      ),
    );
  }
}

class _KeyboardAware extends StatelessWidget {
  const _KeyboardAware({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: child,
  );
}

class _ContentSheet extends StatefulWidget {
  const _ContentSheet({required this.builder});

  final AppSheetBuilder builder;

  @override
  State<_ContentSheet> createState() => _ContentSheetState();
}

class _ContentSheetState extends State<_ContentSheet> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SheetSurface(
        side: AppEdge.bottom,
        expand: false,
        onHandleDismiss: () => Navigator.of(context).maybePop(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                media.size.height -
                media.padding.vertical -
                media.viewInsets.bottom,
          ),
          child: widget.builder(context, _controller),
        ),
      ),
    );
  }
}

class _DraggableSheet extends StatefulWidget {
  const _DraggableSheet({
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
    required this.builder,
  });

  final double initialSize;
  final double minSize;
  final double maxSize;
  final AppSheetBuilder builder;

  @override
  State<_DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<_DraggableSheet> {
  bool _armed = true;

  bool _onNotification(DraggableScrollableNotification notification) {
    final atThreshold = notification.extent <= notification.minExtent;
    if (atThreshold && _armed) {
      _armed = false;
      HapticFeedback.mediumImpact();
    } else if (!atThreshold) {
      _armed = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<DraggableScrollableNotification>(
        onNotification: _onNotification,
        child: DraggableScrollableSheet(
          initialChildSize: widget.initialSize,
          minChildSize: widget.minSize,
          maxChildSize: widget.maxSize,
          builder: (context, scrollController) => SheetSurface(
            side: AppEdge.bottom,
            onHandleDismiss: () => Navigator.of(context).maybePop(),
            child: widget.builder(context, scrollController),
          ),
        ),
      );
}
