# Deploy: Google Play CI/CD

Status: blocked on Google Play developer account verification. Resume here once approved.

## Decisions already made

- Versioning: conventional commits → semver (fix→patch, feat→minor, `BREAKING CHANGE`→major), auto-bumped in `pubspec.yaml` on every merge to `main`.
- Release track: Production, directly from `main` (no staging track).
- `main` is always the latest released version — no long-lived release branch.

## Already done

- Brand name: **MDocumentsManager**. `applicationId`/`namespace` set to
  `uz.freyzan.mdocumentsmanager` (Android + iOS bundle id kept in sync).
  See the commit that moved `MainActivity.kt` and updated
  `build.gradle.kts` / `Info.plist` / `project.pbxproj`.
- App icon generated (`flutter_launcher_icons`, adaptive icon for
  Android + full iOS set) from `assets/logo.png`.
- Store listing copy written: `metadata/listing.md` (title, short/full
  description in en/ru/uz, category, ASO keywords).
- Privacy policy page written: `docs/privacy-policy.html` (en/ru,
  toggle in-page). Verified against the actual codebase: release
  manifest + every native dependency declare zero Android permissions,
  no analytics/ads SDK, no backend — so the policy can honestly say
  "no data collected or shared."
- Data Safety form answer key written: `DATA_SAFETY.md` — the whole
  form reduces to one "No" plus two follow-ups, with the reasoning
  behind that answer.
- Privacy policy contact email filled in (`docs/privacy-policy.html`):
  freyzan2006@gmail.com.
- Phone screenshots captured on the connected device (220733SFG),
  cropped to Play's required ≤2:1 aspect ratio (720×1436, 24-bit PNG,
  no alpha): `metadata/screenshots/phone/01_home.png` (Home with recent
  documents), `02_documents.png` (library list with tags/favorites),
  `03_reader.png` (PDF reading view, diagrams visible), `04_settings.png`
  (theme/language). Deliberately used a public-domain textbook (*The Art
  of Electronics*) as demo content for the reader screenshot — the
  documents you'd originally imported for testing (`Programing.pdf`,
  `math.pdf`, `logic.pdf`) contain real personal names and ID numbers
  and must never be used in public screenshots; their filenames are
  harmless and appear in the list/home screenshots, but their *content*
  was never opened on-camera.
- Feature graphic generated programmatically (Pillow: app icon +
  Liberation Sans Bold title + violet accent subtitle on a black
  canvas matching brand colors): `metadata/feature_graphic.png`
  (1024×500, RGB PNG, no alpha).

## Blocking manual steps (cannot be automated)

1. Finish Google Play developer account verification.
2. Enable GitHub Pages for this repo (Settings → Pages → Source:
   Deploy from a branch → `main` / `/docs`). Once enabled, the policy
   is public at `https://freyzan2006.github.io/reader-documents/privacy-policy.html`
   — that's the URL to paste into Play Console's privacy policy field.
3. Create the app in [Play Console](https://play.google.com/console): name, package name, store listing (use `metadata/listing.md` + `metadata/screenshots/phone/` + `metadata/feature_graphic.png`), content rating, privacy policy URL (step 2), data safety form (use `DATA_SAFETY.md`).
4. Optional: tablet screenshots (not captured — no tablet/emulator on hand this session).
5. Generate the upload keystore (once, keep forever, back it up somewhere outside this repo):
   ```
   keytool -genkeypair -v -keystore upload-keystore.jks \
     -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
6. Add release signing to `android/app/build.gradle.kts` (`signingConfigs.release`, reading keystore path/passwords from `key.properties`, not committed).
7. Build and upload the **first** release manually through the Play Console UI (`flutter build appbundle --release`). The Play Developer API cannot create a new app or do this first upload — only update an app that already has at least one release.
8. In Google Cloud Console: enable the **Google Play Android Developer API**, create a service account, download its JSON key.
9. In Play Console → Users and permissions: invite that service account, grant it release permissions (production + testing tracks) scoped to this app.

## GitHub repo secrets to add (Settings → Secrets and variables → Actions)

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` output |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password chosen in step 4 |
| `ANDROID_KEY_ALIAS` | `upload` (or whatever alias was chosen) |
| `ANDROID_KEY_PASSWORD` | key password chosen in step 4 |
| `PLAY_SERVICE_ACCOUNT_JSON` | full contents of the service account JSON key from step 7 |
| `GH_TOKEN` (only if `main` has branch protection) | a PAT with `contents: write`, since the default `GITHUB_TOKEN` may not be able to push the version-bump commit/tag |

## CI/CD plan (to implement once the above is done)

Single workflow, triggered on push to `main`, skipped on the bot's own version-bump commit:

1. Checkout with full git history.
2. Run `semantic-release` (with the `semantic-release-flutter-plugin`) to analyze commits since the last tag:
   - No releasable commits → stop here, nothing else runs.
   - Releasable → bump `version:` in `pubspec.yaml`, commit `chore(release): X.Y.Z [skip ci]`, tag, push, create a GitHub release.
3. Decode `ANDROID_KEYSTORE_BASE64` to a file, write `key.properties` from the other signing secrets.
4. `flutter build appbundle --release --build-name=<version> --build-number=<code>`.
5. Upload via `r0adkll/upload-google-play`: `packageName`, `releaseFiles: build/app/outputs/bundle/release/app-release.aab`, `serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}`, `track: production`.

