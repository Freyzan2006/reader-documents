import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';

import '../helpers/test_app.dart';

Future<void> _pump(WidgetTester tester, Widget child) =>
    pumpTestApp(tester, Center(child: child));

void main() {
  testWidgets('button fires when enabled and ignores taps when disabled', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(onPressed: () => taps++, child: const Text('Save')),
          const AppButton(onPressed: null, child: Text('Locked')),
        ],
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgetsWithSemantics('icon button exposes its label and fires', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      AppIconButton(
        icon: AppIcons.search,
        semanticsLabel: 'Search',
        onPressed: () => taps++,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('switch and checkbox report the toggled value', (tester) async {
    bool? switched;
    bool? checked;
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSwitch(
            value: false,
            label: 'Warm filter',
            onChanged: (value) => switched = value,
          ),
          AppCheckbox(
            value: true,
            label: 'Keep copy',
            onChanged: (value) => checked = value,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Warm filter'));
    await tester.tap(find.text('Keep copy'));
    await tester.pumpAndSettle();

    expect(switched, isTrue);
    expect(checked, isFalse);
  });

  testWidgets('radio group selects the tapped option', (tester) async {
    String? picked;
    await _pump(
      tester,
      AppRadioGroup<String>(
        value: 'pdf',
        onChanged: (value) => picked = value,
        options: const [
          AppRadioOption(value: 'pdf', label: 'PDF'),
          AppRadioOption(value: 'docx', label: 'DOCX'),
        ],
      ),
    );

    await tester.tap(find.text('DOCX'));
    await tester.pumpAndSettle();

    expect(picked, 'docx');
  });

  testWidgets('slider maps a tap to a fraction of its width', (tester) async {
    double? value;
    await _pump(
      tester,
      SizedBox(
        width: 220,
        child: AppSlider(value: 0, onChanged: (next) => value = next),
      ),
    );

    final box = tester.getRect(find.byType(AppSlider));
    await tester.tapAt(Offset(box.right - 1, box.center.dy));
    await tester.pumpAndSettle();

    expect(value, closeTo(1, 0.01));
  });

  testWidgets('skeleton stays still in performance mode', (tester) async {
    await pumpTestApp(
      tester,
      const Center(child: AppSkeleton(width: 80)),
      graphics: GraphicsMode.performance,
    );

    expect(tester.hasRunningAnimations, isFalse);
  });
}
