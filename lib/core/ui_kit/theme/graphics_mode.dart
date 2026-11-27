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
    required this.exit,
    required this.routeExit,
    required this.expressive,
  });

  static const quality = AppMotion._(
    quick: Duration(milliseconds: 180),
    sheet: Duration(milliseconds: 280),
    route: Duration(milliseconds: 320),
    exit: Duration(milliseconds: 200),
    routeExit: Duration(milliseconds: 200),
    expressive: true,
  );

  static const performance = AppMotion._(
    quick: Duration(milliseconds: 100),
    sheet: Duration(milliseconds: 160),
    route: Duration(milliseconds: 150),
    exit: Duration(milliseconds: 120),
    routeExit: Duration(milliseconds: 150),
    expressive: false,
  );

  static const reduced = AppMotion._(
    quick: Duration.zero,
    sheet: Duration.zero,
    route: Duration.zero,
    exit: Duration.zero,
    routeExit: Duration.zero,
    expressive: false,
  );

  static const curve = Cubic(0.2, 0, 0, 1);
  static const scaleFrom = 0.94;
  static const staggerLimit = 5;
  static const _press = Duration(milliseconds: 100);
  static const _emphasis = Duration(milliseconds: 240);
  static const _stagger = Duration(milliseconds: 30);

  static AppMotion resolve(GraphicsMode mode, {bool reduceMotion = false}) {
    if (reduceMotion) return reduced;
    return switch (mode) {
      GraphicsMode.quality => quality,
      GraphicsMode.performance => performance,
    };
  }

  final Duration quick;
  final Duration sheet;
  final Duration route;
  final Duration exit;
  final Duration routeExit;
  final bool expressive;

  bool get scale => expressive;
  bool get slide => expressive;
  bool get loops => expressive;
  bool get hero => expressive;

  Duration get press => _onlyExpressive(_press);
  Duration get emphasis => _onlyExpressive(_emphasis);
  Duration get reveal => _onlyExpressive(quick);
  Duration get layoutChange => _onlyExpressive(quick);
  Duration get paletteChange => _onlyExpressive(sheet);

  Duration? staggerDelay(int index) =>
      expressive && index < staggerLimit ? _stagger * index : null;

  Duration _onlyExpressive(Duration duration) =>
      expressive ? duration : Duration.zero;
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
