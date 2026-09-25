import 'package:flutter/widgets.dart';

class AppPageView extends StatefulWidget {
  const AppPageView({
    required this.children,
    this.initialPage = 0,
    this.onPageChanged,
    super.key,
  });

  final List<Widget> children;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;

  @override
  State<AppPageView> createState() => _AppPageViewState();
}

class _AppPageViewState extends State<AppPageView> {
  late final PageController _controller = PageController(
    initialPage: widget.initialPage,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView(
    controller: _controller,
    onPageChanged: widget.onPageChanged,
    children: widget.children,
  );
}
