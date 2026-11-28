import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';
import 'package:reader_documents/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

abstract final class DocumentQuote {
  static String format({
    required AppLocalizations l10n,
    required String text,
    required String title,
    int? pageNumber,
  }) {
    final (open, close) = l10n.localeName.startsWith('en')
        ? ('“', '”')
        : ('«', '»');
    final source = pageNumber == null
        ? title
        : l10n.quoteSourceWithPage(title, pageNumber);
    return '$open${text.trim()}$close\n— $source';
  }

  static Future<void> copy(String quote) =>
      Clipboard.setData(ClipboardData(text: quote));

  static Future<void> share({
    required String quote,
    required String title,
    Rect? origin,
  }) => SharePlus.instance.share(
    ShareParams(text: quote, subject: title, sharePositionOrigin: origin),
  );
}
