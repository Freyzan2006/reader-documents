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
  static const _pageSize = Size(794, 1123);

  final DocumentThumbnailCacheRepository cacheRepository;

  @override
  bool supports(DocumentType type) => type == DocumentType.docx;

  @override
  Widget build(BuildContext context, DocumentFile file, {bool preview = true}) {
    if (!preview) return const _DocxPreviewPlaceholder(compact: true);
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

  @visibleForTesting
  Future<Uint8List?> debugRender(DocumentFile file) =>
      _render(file, rethrowErrors: true);

  Future<Uint8List?> _load(DocumentFile file) {
    final key = _cacheKey(file);
    return _cache.putIfAbsent(key, () => _loadOrRender(file, key));
  }

  Future<Uint8List?> _loadOrRender(DocumentFile file, String key) async {
    final signature = _signature(file);
    final cached = await cacheRepository.read(file.path, signature);
    if (cached != null) return cached;

    final bytes = await _render(file);
    if (bytes != null) {
      await cacheRepository.write(file.path, signature, bytes);
      return bytes;
    }
    _cache.remove(key);
    return null;
  }

  Future<Uint8List?> _render(
    DocumentFile file, {
    bool rethrowErrors = false,
  }) async {
    try {
      final doc = await DocxReader.loadFromBytes(
        await File(file.path).readAsBytes(),
      );
      await _loadFonts(doc);
      final page = _firstPage(doc);
      if (page == null) return null;
      return await _captureWidget(page);
    } catch (_) {
      if (rethrowErrors) rethrow;
      return null;
    }
  }

  static Future<void> _loadFonts(DocxBuiltDocument doc) async {
    for (final font in doc.fonts) {
      await EmbeddedFontLoader.loadFont(
        font.familyName,
        font.bytes,
        obfuscationKey: font.obfuscationKey,
      );
    }
  }

  static Widget? _firstPage(DocxBuiltDocument doc) {
    final widgets = DocxWidgetGenerator(
      config: DocxViewConfig(
        pageMode: DocxPageMode.paged,
        pageWidth: _pageSize.width,
        pageHeight: _pageSize.height,
        enableSearch: false,
        enableZoom: false,
        enableSelection: false,
        showPageBreaks: false,
      ),
      theme: DocxViewTheme.light(),
      docxTheme: doc.theme,
    ).generateWidgets(doc);
    return widgets.isEmpty ? null : widgets.first;
  }

  static Future<Uint8List?> _captureWidget(Widget widget) async {
    final boundary = RenderRepaintBoundary();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final renderView = RenderView(
      view: view,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tightFor(
          width: _pageSize.width,
          height: _pageSize.height,
        ),
        devicePixelRatio: _pixelRatio,
      ),
    );
    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    final buildOwner = BuildOwner(focusManager: FocusManager());
    renderView.prepareInitialFrame();
    renderView.child = RenderPositionedBox(
      alignment: Alignment.topCenter,
      child: RenderConstrainedBox(
        additionalConstraints: BoxConstraints.tightFor(
          width: _pageSize.width,
          height: _pageSize.height,
        ),
        child: boundary,
      ),
    );

    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(
            size: _pageSize,
            devicePixelRatio: _pixelRatio,
          ),
          child: ColoredBox(color: const Color(0xFFFFFFFF), child: widget),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    try {
      buildOwner
        ..buildScope(element)
        ..finalizeTree();
      pipelineOwner
        ..flushLayout()
        ..flushCompositingBits()
        ..flushPaint();
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      buildOwner.finalizeTree();
      renderView.child = null;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_overriding_member
      element.deactivate();
      buildOwner.finalizeTree();
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_overriding_member
      element.unmount();
      pipelineOwner.rootNode = null;
    }
  }

  static int _signature(DocumentFile file) =>
      Object.hash(file.sizeBytes, file.modifiedAt.microsecondsSinceEpoch);

  static String _cacheKey(DocumentFile file) =>
      '${file.path}:${_signature(file)}';
}

class _DocxPreviewPlaceholder extends StatelessWidget {
  const _DocxPreviewPlaceholder({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => _DocxPreviewFrame(
    compact: compact,
    lineColor: context.tokens.palette.ruleStrong,
  );
}

class _DocxPreviewSkeleton extends StatelessWidget {
  const _DocxPreviewSkeleton();

  @override
  Widget build(BuildContext context) =>
      _DocxPreviewFrame(lineColor: context.tokens.palette.shadeStrong);
}

class _DocxPreviewFrame extends StatelessWidget {
  const _DocxPreviewFrame({required this.lineColor, this.compact = false});

  final Color lineColor;
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
                        color: lineColor,
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
