import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:reader_documents/core/app/application.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Widget Function(Widget app)? wrapApp,
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) {
  final app = MaterialApp(
    locale: locale,
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: FTheme(
      data: AppTheme.of(brightness),
      child: FToaster(child: child),
    ),
  );

  return tester.pumpWidget(wrapApp?.call(app) ?? app);
}

Future<void> pumpApplication(WidgetTester tester) async {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('receive_sharing_intent/messages'),
    (call) async => null,
  );

  await tester.pumpWidget(const ProviderScope(child: Application()));
}

void testWidgetsWithSemantics(
  String description,
  Future<void> Function(WidgetTester tester) body,
) => testWidgets(description, (tester) async {
  final handle = tester.ensureSemantics();
  try {
    await body(tester);
  } finally {
    handle.dispose();
  }
});
