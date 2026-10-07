import 'package:flutter/widgets.dart';

class AppEffects extends InheritedWidget {
  const AppEffects({required this.blur, required super.child, super.key});

  final bool blur;

  static AppEffects? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppEffects>();

  static bool blurOf(BuildContext context) =>
      maybeOf(context)?.blur ?? !MediaQuery.disableAnimationsOf(context);

  @override
  bool updateShouldNotify(AppEffects oldWidget) => blur != oldWidget.blur;
}
