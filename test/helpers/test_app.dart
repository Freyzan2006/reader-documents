import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/app/application.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/application/documents_providers.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Widget Function(Widget app)? wrapApp,
  Brightness brightness = Brightness.light,
  GraphicsMode graphics = GraphicsMode.quality,
  Locale locale = const Locale('en'),
}) {
  final app = MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, navigator) => AppTheme(
      tokens: AppTokens(palette: AppPalette.of(brightness), graphics: graphics),
      child: AppToaster(child: navigator!),
    ),
    home: child,
  );

  return tester.pumpWidget(wrapApp?.call(app) ?? app);
}

class TestDocumentsNotifier extends DocumentsNotifier {
  @override
  Future<List<DocumentFile>> build() async => const [];
}

class TestSettingsNotifier extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => AppSettings.defaults;
}

Future<void> pumpApplication(
  WidgetTester tester, {
  DocumentsNotifier Function()? documents,
}) async {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('receive_sharing_intent/messages'),
    (call) async => null,
  );

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        settingsProvider.overrideWith(TestSettingsNotifier.new),
        documentsProvider.overrideWith(documents ?? TestDocumentsNotifier.new),
      ],
      child: const Application(),
    ),
  );
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
