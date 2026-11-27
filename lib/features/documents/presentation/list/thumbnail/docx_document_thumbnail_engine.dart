import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:docx_creator/docx_creator.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';
// ignore: implementation_imports
import 'package:docx_file_viewer/src/font_loader/embedded_font_loader.dart';
// ignore: implementation_imports
import 'package:docx_file_viewer/src/widget_generator/docx_widget_generator.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:reader_documents/core/ui_kit/ui_kit.dart';
import 'package:reader_documents/features/documents/data/models/document_file.dart';
import 'package:reader_documents/features/documents/data/repositories/document_thumbnail_cache_repository.dart';

import 'document_thumbnail_engine.dart';

final class DocxDocumentThumbnailEngine implements DocumentThumbnailEngine {
  const DocxDocumentThumbnailEngine({
    this.cacheRepository = const DocumentThumbnailCacheRepository(),
  });

  static final _cache = <String, Future<Uint8List?>>{};
  static const _pixelRatio = 2.0;
  static const _pageWidth = 794.0;
  static const _pageHeight = 1123.0;

  final DocumentThumbnailCacheRepository cacheRepository;

  @override
  bool supports(DocumentType type) => type == DocumentType.docx;

  static int _signature(DocumentFile file) =>
      Object.hash(file.sizeBytes, file.modifiedAt.microsecondsSinceEpoch);

  static String _cacheKey(DocumentFile file) =>
      '${file.path}:${_signature(file)}';

  Future<Uint8List?> _load(DocumentFile file) {
    final key = _cacheKey(file);
    final existing = _cache[key];
    if (existing != null) return existing;
    final future = () async {
      final signature = _signature(file);
      final cached = await cacheRepository.read(file.path, signature);
      if (cached != null) return cached;

      final bytes = await _render(file);
      if (bytes != null) {
        await cacheRepository.write(file.path, signature, bytes);
      }
      return bytes;
    }();
    _cache[key] = future;
    future.then((bytes) {
      if (bytes == null && _cache[key] == future) _cache.remove(key);
    });
    return future;
  }

  @visibleForTesting
  Future<Uint8List?> debugRender(DocumentFile file) =>
      _render(file, rethrowErrors: true);

  Future<Uint8List?> _render(
    DocumentFile file, {
    bool rethrowErrors = false,
  }) async {
    try {
      final bytes = await File(file.path).readAsBytes();
      final doc = await DocxReader.loadFromBytes(bytes);

      for (final font in doc.fonts) {
        await EmbeddedFontLoader.loadFont(
          font.familyName,
          font.bytes,
          obfuscationKey: font.obfuscationKey,
        );
      }

      final generator = DocxWidgetGenerator(
        config: const DocxViewConfig(
          pageMode: DocxPageMode.paged,
          pageWidth: _pageWidth,
          pageHeight: _pageHeight,
          enableSearch: false,
          enableZoom: false,
          enableSelection: false,
          showPageBreaks: false,
        ),
        theme: DocxViewTheme.light(),
        docxTheme: doc.theme,
      );
      final widgets = generator.generateWidgets(doc);
      if (widgets.isEmpty) return null;

      final repaintBoundary = RenderRepaintBoundary();
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final renderView = RenderView(
        view: view,
        configuration: ViewConfiguration(
          logicalConstraints: const BoxConstraints.tightFor(
            width: _pageWidth,
            height: _pageHeight,
          ),
          devicePixelRatio: _pixelRatio,
        ),
      );
      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();

      final root = RenderPositionedBox(
        alignment: Alignment.topCenter,
        child: RenderConstrainedBox(
          additionalConstraints: const BoxConstraints.tightFor(
            width: _pageWidth,
            height: _pageHeight,
          ),
          child: repaintBoundary,
        ),
      );
      renderView.child = root;

      final element = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(_pageWidth, _pageHeight),
              devicePixelRatio: _pixelRatio,
            ),
            child: ColoredBox(
              color: const Color(0xFFFFFFFF),
              child: widgets.first,
            ),
          ),
        ),
      ).attachToRenderTree(buildOwner);

      buildOwner
        ..buildScope(element)
        ..finalizeTree();
      pipelineOwner
        ..flushLayout()
        ..flushCompositingBits()
        ..flushPaint();

      final image = await repaintBoundary.toImage(pixelRatio: _pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);

      buildOwner.finalizeTree();
      renderView.child = null;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_overriding_member
      element.deactivate();
      buildOwner.finalizeTree();
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_overriding_member
      element.unmount();
      pipelineOwner.rootNode = null;

      return data?.buffer.asUint8List();
    } catch (e) {
      if (rethrowErrors) rethrow;
      return null;
    }
  }

  @override
  Widget build(BuildContext context, DocumentFile file, {bool preview = true}) {
    if (!preview) return _DocxPreviewPlaceholder(compact: true);
    return FutureBuilder<Uint8List?>(
      future: _load(file),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DocxPreviewSkeleton();
        }
        final bytes = snapshot.data;
        if (bytes == null) return const _DocxPreviewPlaceholder();
        return AppReveal(
          visible: true,
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _DocxPreviewPlaceholder extends StatelessWidget {
  const _DocxPreviewPlaceholder({this.compact = false});

  final bool compact;

  static const _lines = [0.56, 0.86, 0.74, 0.9, 0.62];
  static const _compactLines = [0.72, 0.56];

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return ColoredBox(
      color: palette.sheet,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = compact || constraints.maxHeight < 72;
          final lines = isCompact ? _compactLines : _lines;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              isCompact ? 8 : 12,
              10,
              isCompact ? 6 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.fileText,
                  size: isCompact ? 12 : 14,
                  color: palette.ink3,
                ),
                SizedBox(height: isCompact ? 4 : 8),
                for (final width in lines) ...[
                  FractionallySizedBox(
                    widthFactor: width,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: palette.ruleStrong,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 3 : 4),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DocxPreviewSkeleton extends StatelessWidget {
  const _DocxPreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.palette;
    return ColoredBox(
      color: palette.sheet,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 72;
          final widths = compact
              ? const [0.72, 0.56]
              : const [0.56, 0.86, 0.74, 0.9, 0.62];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              compact ? 8 : 12,
              10,
              compact ? 6 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.fileText,
                  size: compact ? 12 : 14,
                  color: palette.ink3,
                ),
                SizedBox(height: compact ? 4 : 8),
                for (final width in widths) ...[
                  FractionallySizedBox(
                    widthFactor: width,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: palette.shadeStrong,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 3 : 4),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
