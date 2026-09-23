import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A checkbox with an optional label. Wraps Forui's [FCheckbox].
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) => FCheckbox(
    value: value,
    onChange: onChanged,
    label: label == null ? null : Text(label!),
  );
}
