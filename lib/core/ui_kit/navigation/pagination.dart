import 'package:flutter/widgets.dart';

import '../controls/icon_button.dart';
import '../primitives/tappable.dart';
import '../theme/app_tokens.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

final class AppPageWindow {
  const AppPageWindow({required this.current, required this.count});

  static const _span = 1;

  final int current;
  final int count;

  List<int?> get slots {
    if (count <= 7) return [for (var i = 0; i < count; i++) i];
    final start = (current - _span).clamp(1, count - 2);
    final end = (current + _span).clamp(1, count - 2);
    return [
      0,
      if (start > 1) null,
      for (var i = start; i <= end; i++) i,
      if (end < count - 2) null,
      count - 1,
    ];
  }
}

class AppPagination extends StatefulWidget {
  const AppPagination({
    required this.pageCount,
    this.initial = 0,
    this.onChanged,
    this.previousLabel,
    this.nextLabel,
    super.key,
  });

  final int pageCount;
  final int initial;
  final ValueChanged<int>? onChanged;
  final String? previousLabel;
  final String? nextLabel;

  @override
  State<AppPagination> createState() => _AppPaginationState();
}

class _AppPaginationState extends State<AppPagination> {
  late int _page = widget.initial;

  @override
  void didUpdateWidget(AppPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initial != oldWidget.initial) _page = widget.initial;
    _page = _page.clamp(0, widget.pageCount - 1);
  }

  void _go(int page) {
    if (page == _page || page < 0 || page >= widget.pageCount) return;
    setState(() => _page = page);
    widget.onChanged?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    final window = AppPageWindow(current: _page, count: widget.pageCount);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          AppIconButton(
            icon: AppIcons.arrowLeft,
            semanticsLabel: widget.previousLabel,
            onPressed: _page > 0 ? () => _go(_page - 1) : null,
          ),
          for (final slot in window.slots)
            slot == null
                ? const _Gap()
                : _PageButton(
                    page: slot,
                    selected: slot == _page,
                    onPressed: () => _go(slot),
                  ),
          AppIconButton(
            icon: AppIcons.arrowRight,
            semanticsLabel: widget.nextLabel,
            onPressed: _page < widget.pageCount - 1
                ? () => _go(_page + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.onPressed,
  });

  static const _size = 36.0;

  final int page;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.palette;
    return AppTappable.builder(
      onPressed: onPressed,
      selected: selected,
      builder: (context, state) => AnimatedContainer(
        duration: tokens.motion.quick,
        constraints: const BoxConstraints(minWidth: _size),
        height: _size,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? palette.ink
              : state.pressed
              ? palette.shade
              : const Color(0x00000000),
          borderRadius: AppRadii.sm,
        ),
        child: Text(
          '${page + 1}',
          style: AppTextStyles.meta.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? palette.onInk : palette.ink2,
          ),
        ),
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    child: Text(
      '…',
      textAlign: TextAlign.center,
      style: AppTextStyles.meta.copyWith(color: context.tokens.palette.ink3),
    ),
  );
}
