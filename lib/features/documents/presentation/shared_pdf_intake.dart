import 'dart:async';

import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../application/documents_providers.dart';
import 'pdf_viewer_screen.dart';

abstract final class SharedPdfIntake {
  static bool _handling = false;
  static String? _lastHandledPath;

  static Future<void> checkInitial(BuildContext context, WidgetRef ref) async {
    final media = await ReceiveSharingIntent.instance.getInitialMedia();
    unawaited(ReceiveSharingIntent.instance.reset());
    if (!context.mounted) return;
    await _handleAll(context, ref, media);
  }

  static StreamSubscription<List<SharedMediaFile>> listen(
    BuildContext context,
    WidgetRef ref,
  ) => ReceiveSharingIntent.instance.getMediaStream().listen((media) {
    if (!context.mounted) return;
    _handleAll(context, ref, media);
  });

  static Future<void> _handleAll(
    BuildContext context,
    WidgetRef ref,
    List<SharedMediaFile> media,
  ) async {
    for (final item in media) {
      if (!item.path.toLowerCase().endsWith('.pdf')) continue;
      if (_handling || item.path == _lastHandledPath) continue;
      if (!context.mounted) return;

      _handling = true;
      _lastHandledPath = item.path;
      try {
        final file = await ref
            .read(documentsProvider.notifier)
            .import(item.path);
        if (!context.mounted) return;

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PdfViewerScreen(file: file)),
        );
      } finally {
        _handling = false;
      }
    }
  }
}
