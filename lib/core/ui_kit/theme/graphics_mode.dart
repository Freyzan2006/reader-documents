import 'package:flutter/animation.dart';

enum GraphicsMode {
  performance,
  quality;

  bool get blur => this == GraphicsMode.quality;
}

final class AppMotion {
  const AppMotion._({
    required this.quick,
    required this.sheet,
    required this.route,
  });

  static const quality = AppMotion._(
    quick: Duration(milliseconds: 180),
    sheet: Duration(milliseconds: 280),
    route: Duration(milliseconds: 320),
  );

  static const performance = AppMotion._(
    quick: Duration(milliseconds: 100),
    sheet: Duration(milliseconds: 160),
    route: Duration(milliseconds: 150),
  );

  static const curve = Cubic(0.2, 0, 0, 1);

  static AppMotion of(GraphicsMode mode) => switch (mode) {
    GraphicsMode.quality => quality,
    GraphicsMode.performance => performance,
  };

  final Duration quick;
  final Duration sheet;
  final Duration route;
}

final class AppBlur {
  const AppBlur._({required this.glass, required this.scrim});

  static const quality = AppBlur._(glass: 20, scrim: 6);
  static const performance = AppBlur._(glass: 0, scrim: 0);

  static AppBlur of(GraphicsMode mode) => switch (mode) {
    GraphicsMode.quality => quality,
    GraphicsMode.performance => performance,
  };

  final double glass;
  final double scrim;
}
