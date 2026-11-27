import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_outline_node.dart';
import 'package:reader_documents/features/documents/presentation/viewer/common/document_viewer_bottom_bar.dart';
import 'package:reader_documents/features/documents/presentation/viewer/contract/document_viewer_controller.dart';

import '../helpers/test_app.dart';

class _FakeViewer extends DocumentViewerController {
  int page = 1;
  double _zoom = 1;
  final pagesVisited = <int>[];

  @override
  bool get supportsPagination => true;

  @override
  int? get currentPage => page;

  @override
  int get pageCount => 128;

  @override
  Future<void> goToPage(int pageNumber) async {
    pagesVisited.add(pageNumber);
    page = pageNumber;
    notifyListeners();
  }

  @override
  Widget buildPageThumbnail(
    BuildContext context,
    int pageNumber, {
    required bool isCurrent,
  }) => const SizedBox.shrink();

  @override
  bool get supportsZoom => true;

  @override
  double get zoom => _zoom;

  @override
  double get minZoom => 0.5;

  @override
  double get maxZoom => 3;

  @override
  Future<void> setZoom(double zoom) async {
    _zoom = zoom;
    notifyListeners();
  }

  @override
  Future<void> zoomIn() => setZoom(_zoom + 0.1);

  @override
  Future<void> zoomOut() => setZoom(_zoom - 0.1);

  @override
  void invalidate() {}

  @override
  DocumentSearchSession? get search => null;

  @override
  List<DocumentOutlineNode> get outline => const [];
}

Future<_FakeViewer> _pump(
  WidgetTester tester, {
  void Function()? onBookmark,
  void Function()? onWarm,
}) async {
  final viewer = _FakeViewer()..page = 54;
  addTearDown(viewer.dispose);
  await pumpTestApp(
    tester,
    Align(
      alignment: Alignment.bottomCenter,
      child: ListenableBuilder(
        listenable: viewer,
        builder: (context, _) => DocumentViewerBottomBar(
          controller: viewer,
          isBookmarked: false,
          onToggleBookmark: onBookmark ?? () {},
          warmFilterEnabled: false,
          onToggleWarmFilter: onWarm ?? () {},
        ),
      ),
    ),
  );
  return viewer;
}

void main() {
  testWidgets('shows the current page out of the total', (tester) async {
    await _pump(tester);
    expect(find.text('54 / 128'), findsOneWidget);
  });

  testWidgets('scrubber jumps to the page under the finger', (tester) async {
    final viewer = await _pump(tester);

    final slider = tester.getRect(find.byType(AppSlider));
    await tester.tapAt(Offset(slider.right - 1, slider.center.dy));
    await tester.pumpAndSettle();

    expect(viewer.pagesVisited.last, 128);
    expect(find.text('128 / 128'), findsOneWidget);
  });

  testWidgets('zoom buttons step the zoom and tools fire', (tester) async {
    var bookmarks = 0;
    var warm = 0;
    final viewer = await _pump(
      tester,
      onBookmark: () => bookmarks++,
      onWarm: () => warm++,
    );

    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.tap(find.byIcon(AppIcons.bookmark));
    await tester.tap(find.byIcon(AppIcons.lamp));
    await tester.pumpAndSettle();

    expect(viewer.zoom, closeTo(1.1, 0.001));
    expect(bookmarks, 1);
    expect(warm, 1);
  });
}
