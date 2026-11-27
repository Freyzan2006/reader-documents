import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

Widget _launcher(void Function(BuildContext context) onOpen) => Center(
  child: Builder(
    builder: (context) =>
        AppButton(onPressed: () => onOpen(context), child: const Text('Open')),
  ),
);

void main() {
  testWidgets('dialog closes on a barrier tap and returns nothing', (
    tester,
  ) async {
    Object? result = 'pending';
    await pumpTestApp(
      tester,
      _launcher(
        (context) async => result = await AppDialog.show<bool>(
          context: context,
          title: const Text('Delete document?'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete document?'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text('Delete document?'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('performance mode draws the barrier without blur', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      _launcher(
        (context) => AppDialog.show<void>(
          context: context,
          title: const Text('Rename document'),
        ),
      ),
      graphics: GraphicsMode.performance,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Rename document'), findsOneWidget);
  });

  testWidgets('quality mode blurs behind the dialog', (tester) async {
    await pumpTestApp(
      tester,
      _launcher(
        (context) => AppDialog.show<void>(
          context: context,
          title: const Text('Rename document'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('a new toast replaces the old one and hides on its own', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      _launcher((context) {
        AppToast.show(context: context, title: const Text('First'));
        AppToast.show(
          context: context,
          title: const Text('Added to favorites'),
        );
      }),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('First'), findsNothing);
    expect(find.text('Added to favorites'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Added to favorites'), findsNothing);
  });

  testWidgets('toast action runs and dismisses the toast', (tester) async {
    var undone = 0;
    await pumpTestApp(
      tester,
      _launcher(
        (context) => AppToast.show(
          context: context,
          title: const Text('Deleted 3 documents'),
          action: AppToastAction(label: 'Undo', onPressed: () => undone++),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(undone, 1);
    expect(find.text('Deleted 3 documents'), findsNothing);
  });

  testWidgets('tooltip appears on long press', (tester) async {
    await pumpTestApp(
      tester,
      const Center(
        child: AppTooltip(message: 'MDocumentsManager', child: Text('MDM')),
      ),
    );

    await tester.longPress(find.text('MDM'));
    await tester.pumpAndSettle();
    expect(find.text('MDocumentsManager'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('MDocumentsManager'), findsNothing);
  });

  testWidgets('popover menu runs the picked item and closes', (tester) async {
    final picked = <String>[];
    await pumpTestApp(
      tester,
      Center(
        child: AppPopoverMenu(
          items: [
            AppCommandItem(
              label: 'Rename',
              onSelect: () => picked.add('rename'),
            ),
            AppCommandItem(label: 'Share', onSelect: () => picked.add('share')),
          ],
          child: const Text('More'),
        ),
      ),
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(picked, ['share']);
    expect(find.text('Rename'), findsNothing);
  });

  testWidgets('system back closes the side panel and the sheet', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      Center(
        child: Builder(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                onPressed: () => AppSidePanel.show(
                  context: context,
                  builder: (context, panel) => const Text('Menu panel'),
                ),
                child: const Text('Panel'),
              ),
              AppButton(
                onPressed: () => AppSheet.showContent<void>(
                  context: context,
                  builder: (context, controller) => const Text('Sheet body'),
                ),
                child: const Text('Sheet'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Panel'));
    await tester.pumpAndSettle();
    expect(find.text('Menu panel'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Menu panel'), findsNothing);
    expect(find.text('Panel'), findsOneWidget);

    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsNothing);
    expect(find.text('Sheet'), findsOneWidget);
  });

  testWidgets('command palette filters, opens the top match on enter and '
      'offers a fallback when nothing matches', (tester) async {
    final picked = <String>[];
    await pumpTestApp(
      tester,
      _launcher(
        (context) => AppCommandPalette.show(
          context: context,
          noResultsLabel: 'Nothing found',
          noResultsAction: AppCommandItem(
            label: 'Import',
            onSelect: () => picked.add('import'),
          ),
          groups: [
            AppCommandGroup(
              label: 'Documents',
              items: [
                AppCommandItem(
                  label: 'Annual report',
                  onSelect: () => picked.add('report'),
                ),
                AppCommandItem(
                  label: 'Lease contract',
                  onSelect: () => picked.add('lease'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'lease');
    await tester.pump();
    expect(find.text('DOCUMENTS · 1'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(picked, ['lease']);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pump();
    expect(find.text('Nothing found'), findsOneWidget);
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(picked, ['lease', 'import']);
  });
}
