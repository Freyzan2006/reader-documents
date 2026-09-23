import 'package:flutter/widgets.dart';

/// A scrollable region with a visible scrollbar.
///
/// Neither Flutter nor Forui ships a named "scroll area" widget — a plain
/// [ScrollView] has no scrollbar by default on most platforms. This pairs one
/// with [RawScrollbar] (not Material's [Scrollbar], to keep the ui_kit on
/// `flutter/widgets.dart` rather than pulling in Material theming).
///
/// Owns its own [ScrollController] when [controller] isn't given, rather than
/// falling back to the ambient `PrimaryScrollController` — that default
/// breaks as soon as two [AppScrollArea]s are mounted at once (e.g. sibling
/// tabs kept alive by an `IndexedStack`), since a scrollbar with
/// `thumbVisibility: true` requires its controller to have exactly one
/// attached [ScrollPosition].
class AppScrollArea extends StatefulWidget {
  const AppScrollArea({required this.child, this.controller, super.key});

  final Widget child;
  final ScrollController? controller;

  @override
  State<AppScrollArea> createState() => _AppScrollAreaState();
}

class _AppScrollAreaState extends State<AppScrollArea> {
  ScrollController? _ownedController;

  ScrollController get _controller =>
      widget.controller ?? (_ownedController ??= ScrollController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(controller: controller, child: widget.child),
    );
  }
}
