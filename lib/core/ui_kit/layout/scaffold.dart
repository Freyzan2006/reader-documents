import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.header,
    this.sidebar,
    this.footer,
    super.key,
  });

  final Widget child;
  final Widget? header;
  final Widget? sidebar;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => FScaffold(
    sidebar: sidebar,
    childPad: false,
    child: header == null && footer == null
        ? child
        : Stack(
            children: [
              child,
              if (header != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x33000000), Color(0x00000000)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      header!,
                    ],
                  ),
                ),
              if (footer != null)
                Positioned(bottom: 0, left: 0, right: 0, child: footer!),
            ],
          ),
  );
}
