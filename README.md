# reader_documents

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## DOCX rendering

DOCX files are converted to PDF on the device with `docx_creator` and displayed
by the same `pdfrx` viewer used for PDFs. Nothing is uploaded, no WebView or
server is involved. Generated PDFs are cached in the app's support directory
under a signature of the source file, so editing the DOCX invalidates the
cache and the copies never show up in the document library.

The converter uses `docx_creator`'s document model, not a page-perfect Word
layout engine. Unmodelled OOXML, recalculated TOC fields and floating-object
wrap may differ from Word. The read-only PDF is a projection: future editing
will operate on the document model and refresh that projection.

The app depends only on the interfaces in
`lib/features/documents/data/conversion/` (`PdfConverter`,
`ConvertedPdfCache`, `PdfProjection`). `docx_creator` lives in a single
adapter, `DocxCreatorPdfConverter`, and the implementations are wired in
`docxPdfProjectionProvider`. Swapping the converter means writing another
`PdfConverter` and changing that provider; its `id` is part of the cache key,
so PDFs from the old converter are not reused.
`test/architecture/library_boundaries_test.dart` fails if `docx_creator`,
`pdfrx` or `syncfusion_flutter_pdf` is imported outside its adapters.

Synthetic OOXML fixtures live in `test/fixtures/docx`. Regenerate them with:

```sh
dart run tool/generate_docx_fixtures.dart
```

## Development checks

Git hooks are managed by [lefthook](https://lefthook.dev/) through the
`lefthook_dart` dev dependency. The tracked `.githooks/pre-commit` script
delegates to lefthook, so no global `lefthook` binary is needed. It formats
staged Dart files, regenerates
localizations when ARB sources change, then runs `flutter analyze` and
`flutter test`.

Install the hooks once after cloning:

```sh
flutter pub get
make hooks-install
```

Run the hook manually with `make hooks-run`, or run the CI-style checks with
`make check` (it fails on unformatted code instead of restaging fixes).
Use `LEFTHOOK=0 git commit ...` to bypass the hook when needed.

## License

Source-available under the [PolyForm Noncommercial License 1.0.0](LICENSE) — free to read, fork, modify, and use for any noncommercial purpose. Commercial use requires the copyright holder's permission.
