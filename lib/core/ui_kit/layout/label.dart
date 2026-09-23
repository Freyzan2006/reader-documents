import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

enum AppLabelLayout { horizontal, vertical }

class AppLabel extends StatelessWidget {
  const AppLabel({
    required this.child,
    this.label,
    this.description,
    this.error,
    this.layout = AppLabelLayout.vertical,
    super.key,
  });

  final Widget child;
  final String? label;
  final String? description;
  final String? error;
  final AppLabelLayout layout;

  @override
  Widget build(BuildContext context) => FLabel(
    layout: switch (layout) {
      AppLabelLayout.horizontal => FLabelLayout.horizontalTrailing,
      AppLabelLayout.vertical => FLabelLayout.vertical,
    },
    label: label == null ? null : Text(label!),
    description: description == null ? null : Text(description!),
    error: error == null ? null : Text(error!),
    child: child,
  );
}
