import 'package:flutter/widgets.dart';

import '../tokens/app_palette.dart';
import '../tokens/app_shadows.dart';
import 'graphics_mode.dart';

@immutable
final class AppTokens {
  const AppTokens({required this.palette, required this.graphics});

  static const fallback = AppTokens(
    palette: AppPalette.light,
    graphics: GraphicsMode.quality,
  );

  final AppPalette palette;
  final GraphicsMode graphics;

  Brightness get brightness => palette.brightness;

  AppMotion get motion => AppMotion.of(graphics);

  AppBlur get blur => AppBlur.of(graphics);

  AppElevation get elevation => AppElevation.resolve(brightness, graphics);

  AppTokens copyWith({AppPalette? palette, GraphicsMode? graphics}) =>
      AppTokens(
        palette: palette ?? this.palette,
        graphics: graphics ?? this.graphics,
      );

  @override
  bool operator ==(Object other) =>
      other is AppTokens &&
      other.palette == palette &&
      other.graphics == graphics;

  @override
  int get hashCode => Object.hash(palette, graphics);
}

class AppThemeScope extends InheritedWidget {
  const AppThemeScope({required this.tokens, required super.child, super.key});

  final AppTokens tokens;

  static AppTokens of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppThemeScope>()?.tokens ??
      AppTokens.fallback;

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) =>
      tokens != oldWidget.tokens;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => AppThemeScope.of(this);
}
