import 'package:reader_documents/l10n/app_localizations.dart';

class OpenedAgo {
  const OpenedAgo(this._l10n, this._now);

  static const _weekDays = 7;

  final AppLocalizations _l10n;
  final DateTime _now;

  String format(DateTime openedAt) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final day = DateTime(openedAt.year, openedAt.month, openedAt.day);
    final days = today.difference(day).inDays;
    if (days <= 0) return _l10n.openedToday;
    if (days == 1) return _l10n.openedYesterday;
    if (days < _weekDays) return _l10n.openedDaysAgo(days);
    return '${_two(openedAt.day)}.${_two(openedAt.month)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
