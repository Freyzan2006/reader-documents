import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_documents/features/documents/presentation/menu/opened_ago.dart';
import 'package:reader_documents/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ru'));
  final ago = OpenedAgo(l10n, DateTime(2026, 11, 27, 0, 30));

  test('counts calendar days, not 24-hour spans', () {
    expect(ago.format(DateTime(2026, 11, 27, 0, 5)), 'сегодня');
    expect(ago.format(DateTime(2026, 11, 26, 23, 50)), 'вчера');
    expect(ago.format(DateTime(2026, 11, 24, 12)), '3 дня назад');
    expect(ago.format(DateTime(2026, 11, 12, 9)), '12.11');
  });
}
