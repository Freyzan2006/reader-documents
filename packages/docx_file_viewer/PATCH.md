# Vendored fork — local patch notes

Vendored from `docx_file_viewer` **1.0.4** (pub.dev), copied verbatim from
`~/.pub-cache/hosted/pub.dev/docx_file_viewer-1.0.4/` except for `example/`
(removed, not needed here) and the change below.

## Why this is vendored instead of a plain pub.dev dependency

The app wraps the rendered document in Flutter's own `SelectionArea` to get a
custom, app-styled selection context menu (matching the PDF viewer's) instead
of the platform default. That only works for descendants built from `Text`/
`Text.rich`/`RichText` — Flutter's ambient-`SelectionArea` auto-registration
lives in the `Text` widget itself. The stock package instead used
`SelectableText.rich` (a widget with its *own*, independent selection and
default Material toolbar, with no `contextMenuBuilder` exposed to override
it) whenever `DocxViewConfig.enableSelection` is `true`, which doesn't
register with an ambient `SelectionArea` at all.

## The patch

Two call sites changed from `SelectableText.rich` to `Text.rich` under the
`config.enableSelection` branch (`Text.rich` still renders identically —
selection now just comes from the ambient `SelectionArea` in
`DocxDocumentViewer` instead of a per-widget one):

- `lib/src/widget_generator/paragraph_builder.dart` — two occurrences
  (the "no floats" fast path, and the floating-layout text widget).
- `lib/src/widget_generator/list_builder.dart` — one occurrence (list item
  text).

Each site has an inline comment explaining why.

## Updating to a newer upstream version

1. Fetch the new version's source, e.g. `flutter pub cache add
   docx_file_viewer:<version>` in a scratch project, then copy
   `~/.pub-cache/hosted/pub.dev/docx_file_viewer-<version>/` over this
   directory (keep this `PATCH.md`, drop `example/` again).
2. Reapply the same edit at the three call sites above (search each file for
   `SelectableText.rich` — if upstream hasn't restructured that code, that's
   all of them; if it has, adapt the same substitution to the new shape).
3. Bump the version note at the top of this file.
4. `flutter pub get` in the app, then a full `flutter analyze` / `flutter
   test` / on-device pass before trusting the update.
