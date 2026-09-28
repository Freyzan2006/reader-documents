import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

abstract final class DocumentPageCapture {
  static Future<void> capture(
    BuildContext context,
    GlobalKey boundaryKey,
    String documentName,
  ) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;

    final baseName = p.basenameWithoutExtension(documentName);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes.buffer.asUint8List(),
            mimeType: 'image/png',
            name: '${baseName}_screenshot.png',
          ),
        ],
      ),
    );
  }
}
