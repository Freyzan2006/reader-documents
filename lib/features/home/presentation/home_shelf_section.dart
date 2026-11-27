import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

class HomeShelfSection extends StatelessWidget {
  const HomeShelfSection({
    required this.title,
    required this.child,
    this.linkLabel,
    this.onLink,
    super.key,
  });

  final String title;
  final Widget child;
  final String? linkLabel;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    final linkLabel = this.linkLabel;
    final onLink = this.onLink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: AppSpacing.md,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: AppText(title, variant: AppTextVariant.subtitle),
                ),
              ),
              if (linkLabel != null && onLink != null)
                AppTappable(
                  onPressed: onLink,
                  child: Text(
                    linkLabel,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: palette.ink2,
                      decoration: TextDecoration.underline,
                      decorationColor: palette.ruleStrong,
                    ),
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class HomeDocumentShelf extends StatelessWidget {
  const HomeDocumentShelf({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: children,
    ),
  );
}
