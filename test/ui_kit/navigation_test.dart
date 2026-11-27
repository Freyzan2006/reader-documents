import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

double _titleOpacity(WidgetTester tester, String title) => tester
    .widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text(title),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

void main() {
  testWidgets('collapsible header shows its title once content scrolls', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      AppScaffold(
        header: const AppHeader(title: 'Documents', collapsible: true),
        child: ListView(
          children: [
            const AppLargeTitle(title: 'Large', summary: '48 documents'),
            for (var i = 0; i < 40; i++)
              SizedBox(height: 40, child: Text('$i')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_titleOpacity(tester, 'Documents'), 0);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(_titleOpacity(tester, 'Documents'), 1);
  });

  testWidgets('tabs switch the visible page', (tester) async {
    int? changed;
    await pumpTestApp(
      tester,
      AppTabs(
        onChanged: (index) => changed = index,
        tabs: const [
          AppTab(label: 'Outline', child: Text('outline body')),
          AppTab(label: 'Bookmarks', child: Text('bookmarks body')),
        ],
      ),
    );

    await tester.tap(find.text('Bookmarks'));
    await tester.pumpAndSettle();

    expect(changed, 1);
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
  });

  test('page window keeps the ends and the neighbours of the current page', () {
    expect(const AppPageWindow(current: 0, count: 5).slots, [0, 1, 2, 3, 4]);
    expect(const AppPageWindow(current: 6, count: 20).slots, [
      0,
      null,
      5,
      6,
      7,
      null,
      19,
    ]);
    expect(const AppPageWindow(current: 0, count: 20).slots, [0, 1, null, 19]);
  });

  testWidgets('pagination moves forward and reports the page', (tester) async {
    int? page;
    await pumpTestApp(
      tester,
      Center(
        child: AppPagination(
          pageCount: 3,
          nextLabel: 'Next',
          onChanged: (next) => page = next,
        ),
      ),
    );

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    expect(page, 2);
  });

  testWidgets('chip toggles and document card reports taps', (tester) async {
    var chipTaps = 0;
    var opened = 0;
    var held = 0;
    await pumpTestApp(
      tester,
      ListView(
        children: [
          AppChipBar(
            children: [
              AppChip(
                label: 'PDF',
                count: 31,
                selected: false,
                onPressed: () => chipTaps++,
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 160,
              child: AppDocumentCard(
                title: 'Annual report 2025',
                meta: '128 pp · 2.4 MB',
                format: 'pdf',
                progress: 0.42,
                favorite: true,
                onTap: () => opened++,
                onLongPress: () => held++,
              ),
            ),
          ),
        ],
      ),
    );

    await tester.tap(find.byType(AppChip));
    await tester.tap(find.text('Annual report 2025'));
    await tester.longPress(find.text('Annual report 2025'));
    await tester.pumpAndSettle();

    expect(chipTaps, 1);
    expect(opened, 1);
    expect(held, 1);
    expect(find.text('PDF'), findsNWidgets(2));
  });
}
