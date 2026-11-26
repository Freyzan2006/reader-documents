import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:reader_documents/core/ui_kit/overlay/sheet_surface.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

void main() {
  testWidgets('content-sized sheet hugs a short payload', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: FTheme(
          data: AppTheme.of(Brightness.light),
          child: FToaster(
            child: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => AppButton(
                    onPressed: () => AppSheet.showContent<void>(
                      context: context,
                      builder: (context, scrollController) => const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: AppText('Tiny sheet'),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final sheet = find.byType(SheetSurface);
    expect(sheet, findsOneWidget);
    expect(find.text('Tiny sheet'), findsOneWidget);
    expect(
      tester.getSize(sheet).height,
      lessThan(
        tester.view.physicalSize.height / tester.view.devicePixelRatio * 0.3,
      ),
      reason: 'short content must not inherit a fixed fraction of the screen',
    );

    final handle = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 36 && widget.height == 4,
    );
    expect(
      handle,
      findsOneWidget,
      reason: 'the sheet handle must stay visible',
    );

    await tester.timedDragFrom(
      tester.getCenter(handle),
      const Offset(0, 120),
      const Duration(milliseconds: 150),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SheetSurface), findsNothing);
  });
}
