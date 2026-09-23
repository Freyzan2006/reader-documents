import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A thin line separating content. Wraps Forui's [FDivider].
class AppDivider extends StatelessWidget {
  const AppDivider({this.axis = Axis.horizontal, super.key});

  final Axis axis;

  @override
  Widget build(BuildContext context) => FDivider(axis: axis);
}
