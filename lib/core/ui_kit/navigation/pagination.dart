import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppPagination extends StatelessWidget {
  const AppPagination({
    required this.pageCount,
    this.initial = 0,
    this.onChanged,
    super.key,
  });

  final int pageCount;
  final int initial;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: FPagination(
      control: FPaginationControl.managed(
        initial: initial,
        pages: pageCount,
        onChange: onChanged,
      ),
    ),
  );
}
