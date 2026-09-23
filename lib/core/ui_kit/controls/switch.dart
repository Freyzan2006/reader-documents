import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) => FSwitch(
    value: value,
    onChange: onChanged,
    label: label == null ? null : Text(label!),
  );
}
