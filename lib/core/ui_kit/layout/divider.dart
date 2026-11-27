import 'package:flutter/widgets.dart';

import '../theme/app_tokens.dart';
import '../tokens/app_borders.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({this.axis = Axis.horizontal, this.indent = 0, super.key});

  final Axis axis;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final line = ColoredBox(color: context.tokens.palette.rule);
    return switch (axis) {
      Axis.horizontal => Padding(
        padding: EdgeInsetsDirectional.only(start: indent),
        child: SizedBox(
          height: AppBorderWidth.thin,
          width: double.infinity,
          child: line,
        ),
      ),
      Axis.vertical => Padding(
        padding: EdgeInsets.only(top: indent),
        child: SizedBox(
          width: AppBorderWidth.thin,
          height: double.infinity,
          child: line,
        ),
      ),
    };
  }
}
