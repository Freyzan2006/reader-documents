import 'package:flutter/widgets.dart';

enum ScreenSize {
  mobile,
  tablet,
  desktop;

  static const tabletFrom = 640.0;
  static const desktopFrom = 1024.0;

  static ScreenSize forWidth(double width) {
    if (width < tabletFrom) return mobile;
    if (width < desktopFrom) return tablet;
    return desktop;
  }
}

extension AppScreenSizeX on BuildContext {
  ScreenSize get screenSize =>
      ScreenSize.forWidth(MediaQuery.sizeOf(this).width);
}
