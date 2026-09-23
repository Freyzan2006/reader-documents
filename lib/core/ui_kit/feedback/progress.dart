import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppProgress extends StatelessWidget {
  const AppProgress({this.value, super.key});

  final double? value;

  @override
  Widget build(BuildContext context) =>
      value == null ? const FProgress() : FDeterminateProgress(value: value!);
}
