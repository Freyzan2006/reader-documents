import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/app/application.dart';

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

    expect(find.text('MDM'), findsOneWidget);
    expect(find.text('Home'), findsNWidgets(2));
  });
}
