import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppDateTimePicker extends StatelessWidget {
  const AppDateTimePicker({this.initial, this.onChanged, super.key});

  final DateTime? initial;
  final ValueChanged<DateTime>? onChanged;

  @override
  Widget build(BuildContext context) => FDateTimePicker(
    control: FDateTimePickerControl.managed(
      initial: initial,
      onChange: onChanged,
    ),
  );
}
