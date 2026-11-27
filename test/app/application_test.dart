import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/app/app_bootstrap.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';

import '../helpers/test_app.dart';

const splashDuration = Duration(milliseconds: 600);

void main() {
  testWidgets('renders the home tab with its own title', (tester) async {
    await pumpApplication(tester);
    await tester.pump();
    await tester.pump();
    await tester.pump(splashDuration);
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('launch screen covers the ready app and then fades away', (
    tester,
  ) async {
    await pumpApplication(tester);
    await tester.pump();

    expect(find.byType(AppSplash), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byType(AppSplash), findsNothing);
  });

  testWidgets('a failing storage keeps the splash with a retry that recovers', (
    tester,
  ) async {
    var attempts = 0;
    await pumpApplication(
      tester,
      documents: () => _FlakyDocumentsNotifier(() => attempts++),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(AppSplash), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(attempts, 2);
    expect(find.byType(AppSplash), findsNothing);
  });
}

class _FlakyDocumentsNotifier extends TestDocumentsNotifier {
  _FlakyDocumentsNotifier(this._attempt);

  final int Function() _attempt;

  @override
  Future<List<DocumentFile>> build() async {
    if (_attempt() == 0) throw const FileSystemException('locked');
    return const [];
  }
}
