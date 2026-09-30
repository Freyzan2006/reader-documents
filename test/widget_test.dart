import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/app/application.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

void main() {
  testWidgets('renders home page with themed title', (
    WidgetTester tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('receive_sharing_intent/messages'),
      (call) async => null,
    );

    await tester.pumpWidget(const ProviderScope(child: Application()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('MDM'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('holds the launch screen long enough to be seen', (
    WidgetTester tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('receive_sharing_intent/messages'),
      (call) async => null,
    );

    await tester.pumpWidget(const ProviderScope(child: Application()));
    await tester.pump();
    await tester.pump();

    expect(
      find.byType(AppProgress),
      findsOneWidget,
      reason: 'launch screen should be up before the home page',
    );

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.byType(AppProgress), findsNothing);
  });
}
