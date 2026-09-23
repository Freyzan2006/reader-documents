import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A coarse screen-size bucket, derived from Forui's own [FBreakpoints]
/// (`context.theme.breakpoints`) so our layout primitives (e.g. [AppGrid])
/// switch at the same widths Forui's adaptive widgets use.
enum ScreenSize { mobile, tablet, desktop }

extension AppScreenSizeX on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    final breakpoints = theme.breakpoints;
    if (width < breakpoints.sm) return ScreenSize.mobile;
    if (width < breakpoints.lg) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }
}
