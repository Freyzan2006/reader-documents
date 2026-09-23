import 'package:flutter/widgets.dart';

import '../tokens/app_spacing.dart';

/// A fixed-size spacer for the places a `Row`/`Column`'s own `spacing:`
/// parameter doesn't reach — inside a `ListView`'s `children`, or between a
/// `Wrap`'s runs. Named constructors line up with [AppSpacing].
class AppGap extends StatelessWidget {
  const AppGap(this.size, {this.axis = Axis.vertical, super.key});

  const AppGap.xs({Axis axis = Axis.vertical, Key? key})
    : this(AppSpacing.xs, axis: axis, key: key);

  const AppGap.sm({Axis axis = Axis.vertical, Key? key})
    : this(AppSpacing.sm, axis: axis, key: key);

  const AppGap.md({Axis axis = Axis.vertical, Key? key})
    : this(AppSpacing.md, axis: axis, key: key);

  const AppGap.lg({Axis axis = Axis.vertical, Key? key})
    : this(AppSpacing.lg, axis: axis, key: key);

  const AppGap.xl({Axis axis = Axis.vertical, Key? key})
    : this(AppSpacing.xl, axis: axis, key: key);

  final double size;
  final Axis axis;

  @override
  Widget build(BuildContext context) =>
      axis == Axis.vertical ? SizedBox(height: size) : SizedBox(width: size);
}
