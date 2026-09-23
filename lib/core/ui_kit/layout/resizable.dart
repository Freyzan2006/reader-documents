import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A pane in an [AppResizable], sized proportionally (`flex`) relative to
/// its siblings — the common case (e.g. a document view next to an outline
/// panel). For a pane with a concrete initial pixel size, use Forui's
/// [FResizableRegion.fixed] directly.
class AppResizableRegion {
  const AppResizableRegion({required this.child, this.flex = 1, this.minFlex});

  final Widget child;
  final int flex;
  final int? minFlex;
}

/// A row/column of panes the user can drag to resize. Wraps Forui's
/// [FResizable]/[FResizableRegion].
class AppResizable extends StatelessWidget {
  const AppResizable({required this.axis, required this.regions, super.key});

  final Axis axis;
  final List<AppResizableRegion> regions;

  @override
  Widget build(BuildContext context) => FResizable(
    axis: axis,
    children: [
      for (final region in regions)
        FResizableRegion.flex(
          flex: region.flex,
          minFlex: region.minFlex,
          child: region.child,
          builder: (context, data, child) => child!,
        ),
    ],
  );
}
