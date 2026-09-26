import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class ArbMerger {
  const ArbMerger({
    required this.sections,
    required this.sourceDir,
    required this.outputDir,
  });

  final List<String> sections;
  final String sourceDir;
  final String outputDir;

  void run() {
    final locales = _findLocales();
    final messageKeysByLocale = <String, Set<String>>{};

    for (final locale in locales) {
      final merged = _mergeLocale(locale);
      messageKeysByLocale[locale] = merged.keys
          .where((key) => !key.startsWith('@'))
          .toSet();
      _writeMerged(locale, merged);
    }

    _reportDrift(messageKeysByLocale);
  }

  List<String> _findLocales() {
    final root = Directory(sourceDir);
    if (!root.existsSync()) {
      stderr.writeln('No $sourceDir directory found.');
      exit(1);
    }

    final locales = root.listSync().whereType<Directory>().map(
      (dir) => p.basename(dir.path),
    ).toList()..sort();

    if (locales.isEmpty) {
      stderr.writeln('No locale directories found under $sourceDir.');
      exit(1);
    }
    return locales;
  }

  Map<String, dynamic> _mergeLocale(String locale) {
    final merged = <String, dynamic>{'@@locale': locale};

    for (final section in sections) {
      final file = File(p.join(sourceDir, locale, '$section.arb'));
      if (!file.existsSync()) continue;
      final entries =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      merged.addAll(entries);
    }

    return merged;
  }

  void _writeMerged(String locale, Map<String, dynamic> merged) {
    final encoded = const JsonEncoder.withIndent('  ').convert(merged);
    final outFile = File(p.join(outputDir, 'app_$locale.arb'));
    outFile.writeAsStringSync('$encoded\n');
    stdout.writeln('Wrote ${outFile.path} (${merged.length} entries)');
  }

  void _reportDrift(Map<String, Set<String>> messageKeysByLocale) {
    final allKeys = messageKeysByLocale.values.expand((keys) => keys).toSet();
    var hasDrift = false;

    for (final entry in messageKeysByLocale.entries) {
      final missing = allKeys.difference(entry.value);
      if (missing.isEmpty) continue;
      hasDrift = true;
      stderr.writeln('${entry.key} is missing: ${missing.join(', ')}');
    }

    if (hasDrift) exit(1);
  }
}

void main() {
  const ArbMerger(
    sections: [
      'common',
      'navigation',
      'home',
      'documents',
      'tags',
      'pdfview',
      'settings',
    ],
    sourceDir: 'lib/l10n/src',
    outputDir: 'lib/l10n',
  ).run();
}
