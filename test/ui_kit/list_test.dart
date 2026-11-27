import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('list rows fire their own taps and the trailing action', (
    tester,
  ) async {
    final taps = <String>[];
    await pumpTestApp(
      tester,
      SingleChildScrollView(
        child: AppList(
          items: [
            AppListItem(
              title: 'Rename',
              leading: AppIcons.pencil,
              onTap: () => taps.add('rename'),
            ),
            AppListItem(
              title: 'Page 12',
              value: '12',
              trailing: AppIcons.trash,
              trailingLabel: 'Remove bookmark',
              onTap: () => taps.add('open'),
              onTrailingTap: () => taps.add('remove'),
            ),
            AppListItem(
              title: 'Delete',
              leading: AppIcons.trash,
              destructive: true,
              onTap: () => taps.add('delete'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Rename'));
    await tester.tap(find.text('Page 12'));
    await tester.tap(find.byType(AppIconButton));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(taps, ['rename', 'open', 'remove', 'delete']);
    final delete = tester.widget<Text>(find.text('Delete'));
    expect(delete.style?.color, AppPalette.light.danger);
  });

  testWidgets('destructive alert uses the danger colors', (tester) async {
    await pumpTestApp(
      tester,
      const AppAlert(
        title: Text('Could not load documents'),
        subtitle: Text('Check storage access and try again.'),
        variant: AppAlertVariant.destructive,
      ),
      brightness: Brightness.dark,
    );

    final title = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Could not load documents'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(title.style.color, AppPalette.dark.danger);
  });

  testWidgets('avatar shows initials without an image', (tester) async {
    await pumpTestApp(tester, const Center(child: AppAvatar(initials: 'fr')));
    expect(find.text('FR'), findsOneWidget);
  });

  test('screen size follows the breakpoints', () {
    expect(ScreenSize.forWidth(360), ScreenSize.mobile);
    expect(ScreenSize.forWidth(640), ScreenSize.tablet);
    expect(ScreenSize.forWidth(1024), ScreenSize.desktop);
  });
}
