import 'package:flutter/material.dart' show Theme, TextSelectionThemeData;
import 'package:flutter/widgets.dart';

class AppTextSelectionTheme extends StatelessWidget {
  const AppTextSelectionTheme({
    required this.color,
    required this.child,
    super.key,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      textSelectionTheme: TextSelectionThemeData(selectionColor: color),
    ),
    child: child,
  );
}
