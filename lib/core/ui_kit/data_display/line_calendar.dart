import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppLineCalendar extends StatelessWidget {
  const AppLineCalendar({this.initial, this.onChanged, super.key});

  final DateTime? initial;
  final ValueChanged<DateTime?>? onChanged;

  @override
  Widget build(BuildContext context) => FLineCalendar(
    control: FLineCalendarControl.managed(
      initial: initial,
      onChange: onChanged,
    ),
  );
}
