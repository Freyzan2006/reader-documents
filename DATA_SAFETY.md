# Play Console — Data Safety form answer key

Fill this in yourself in Play Console → App content → Data safety (Google
doesn't expose this as an API, only a UI form). This is the answer key,
grounded in what was actually verified in this codebase — not guessed.

## Grounding: what was checked

- `android/app/src/main/AndroidManifest.xml` (the release manifest, not
  the debug/profile ones) declares **zero** `uses-permission` entries.
- Every native dependency's own Android manifest was checked for
  permissions it might merge in: `pdfrx`, `syncfusion_flutter_pdf`,
  `share_plus`, `receive_sharing_intent`, `file_picker`,
  `url_launcher_android`, `path_provider_android` — none declare any
  permission either.
- No analytics, crash-reporting, or ad SDK is a dependency (checked
  `pubspec.yaml`) — see the full dependency list there.
- Local storage the app does use (`SharedPreferences`, app-private
  filesystem directory via `path_provider`) never leaves the device —
  there is no networking code anywhere in `lib/`.

Per Play's own Data Safety definition, "collection" means data
**transmitted off the device**. Purely on-device storage (your
documents, tags, highlights, reading progress, optional profile
name/email in Settings) does not count as collection — Google's help
docs say so explicitly for locally-stored files/logs that never leave
the device. That's this app's exact situation.

## Answers

**"Does your app collect or share any of the required user data
types?"** → **No**

That single "No" is the answer to the whole form for this app. Google
will still ask a couple of follow-ups even after "No" — answer them as
below if they appear:

| Follow-up (wording may vary slightly by Play Console version) | Answer |
|---|---|
| Is all user data collected by your app encrypted in transit? | Not applicable — no data is collected/transmitted |
| Do you provide a way for users to request their data be deleted? | Not applicable for off-device data (none exists); locally, users can delete a document/tag/highlight in-app or remove all data by uninstalling |
| Has your app had an independent security review? | No |

## Optional justification note (paste into the form's free-text field if offered)

> This app stores documents, tags, highlights, and preferences only in
> local on-device storage (SharedPreferences and the app's private
> filesystem directory). It has no backend, no account system, and no
> third-party SDKs. Verified: the release Android manifest declares no
> permissions, and no code path performs network I/O.

## Caveat

Google periodically reshuffles the Data Safety form's exact wording and
steps. Treat this as the answer key for the underlying questions, and
adjust to whatever labels the live form shows.
