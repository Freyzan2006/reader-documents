import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppTag extends StatelessWidget {
  const AppTag({required this.label, this.onRemove, super.key});

  final Widget label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) =>
      FMultiSelectTag(label: label, onPress: onRemove);
}
