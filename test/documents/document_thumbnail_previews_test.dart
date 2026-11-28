import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/presentation/list/document_thumbnail.dart';
import 'package:reader_documents/features/documents/presentation/list/thumbnail/document_thumbnail_engine.dart';
import 'package:reader_documents/features/documents/presentation/list/thumbnail/document_thumbnail_registry.dart';
import 'package:reader_documents/features/settings/application/settings_providers.dart';
import 'package:reader_documents/features/settings/data/app_settings.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

const _renderedKey = Key('rendered-page');

class _FakeEngine implements DocumentThumbnailEngine {
  int builds = 0;

  @override
  bool supports(DocumentType type) => true;

  @override
  Widget build(BuildContext context, DocumentFile file, {bool preview = true}) {
    builds++;
    return const SizedBox(key: _renderedKey);
  }
}

class _Settings extends SettingsNotifier {
  _Settings(this.previews);

  final DocumentPreviews previews;

  @override
  Future<AppSettings> build() async =>
      AppSettings.defaults.copyWith(documentPreviews: previews);
}

void main() {
  group('DocumentPreviews.enabled', () {
    test('auto follows the graphics mode', () {
      expect(DocumentPreviews.auto.enabled(GraphicsMode.quality), isTrue);
      expect(DocumentPreviews.auto.enabled(GraphicsMode.performance), isFalse);
    });

    test('show and hide ignore the graphics mode', () {
      for (final mode in GraphicsMode.values) {
        expect(DocumentPreviews.show.enabled(mode), isTrue);
        expect(DocumentPreviews.hide.enabled(mode), isFalse);
      }
    });
  });

  late DocumentThumbnailRegistry original;
  late _FakeEngine engine;

  setUp(() {
    original = DocumentThumbnail.registry;
    engine = _FakeEngine();
    DocumentThumbnail.registry = DocumentThumbnailRegistry([engine]);
  });
  tearDown(() => DocumentThumbnail.registry = original);

  for (final (previews, graphics, rendered) in const [
    (DocumentPreviews.auto, GraphicsMode.quality, true),
    (DocumentPreviews.auto, GraphicsMode.performance, false),
    (DocumentPreviews.show, GraphicsMode.performance, true),
    (DocumentPreviews.hide, GraphicsMode.quality, false),
  ]) {
    testWidgets('${previews.name} in ${graphics.name} '
        '${rendered ? 'renders' : 'skips'} the page', (tester) async {
      await pumpTestApp(
        tester,
        graphics: graphics,
        ProviderScope(
          overrides: [settingsProvider.overrideWith(() => _Settings(previews))],
          child: Center(
            child: SizedBox(
              width: 60,
              height: 85,
              child: Consumer(
                builder: (context, ref, _) =>
                    ref.watch(settingsProvider).hasValue
                    ? AppPageThumbnail(
                        image: DocumentThumbnail.of(testDocuments.first),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(_renderedKey),
        rendered ? findsOneWidget : findsNothing,
      );
      expect(engine.builds > 0, rendered);
    });
  }
}
