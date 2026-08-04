# Requirements — music_app_admin

Admin panel for a music streaming app. Flutter, targeting **web/desktop**.
Backend is a PHP + MySQL API; there is no Firebase (it was removed early on).

> Everything marked **Live** below was verified against the running API.
> Everything marked **Proposed** does not exist yet.

---

## 1. Platform

- Flutter web is the primary target (`flutter build web`). Layouts are
  two-column and assume a wide viewport; there is no mobile breakpoint.
- Files are handled entirely in memory — `file_picker` runs with
  `withData: true` and uploads go out as `MultipartFile.fromBytes`. No
  `dart:io` paths on the web path.
- Wasm builds are blocked by `flutter_media_metadata` (it depends on
  `package:js`). The default JS build is unaffected.

## 2. Authentication

**FR-1.1** Admin logs in with an ID and password. No registration — accounts are
created directly in the database.

**FR-1.2** Failure shows an error toast; success routes to `/home`.

**Known gap:** the API returns only `{success, message}`. No token is issued,
nothing is persisted, and no later request carries credentials. Any route can be
reached by URL without logging in. See `bugs_and_errors.md` → BUG-04.

## 3. Dashboard — `/home`

**FR-2.1** Left rail of navigation cards: Add Songs, Quick Picks, Add Artists.

**FR-2.2** Right pane lists every song with a live count.

**FR-2.3** Search filters by title *or* artist, case-insensitive, client-side.

**FR-2.4** Each row offers edit and delete. Delete asks for confirmation. While a
row is being written the spinner replaces that row's actions only — the rest of
the list stays interactive.

## 4. Song management

**FR-3.1 — Add one song.** Pick a cover image and an MP3, type title and artist,
submit. All four are required.

**FR-3.2 — Bulk upload.** Select any number of MP3s. Title, artist, album and
embedded album art are read from each file's tags via `flutter_media_metadata`,
with fallbacks: track name → filename, track artists → album artist → "Unknown
Artist".

- Files with no embedded art are uploaded against one shared fallback cover the
  admin picks in the dialog. Without it those files are marked failed.
- The queue uploads serially, one request per file, each row showing
  ready / uploading / done / failed with the server's error message on failure.
- Rows can be removed from the queue before upload starts.

**FR-3.3 — Edit song.** Change title and artist; optionally replace the cover
and/or the audio file. Untouched files keep their current server-side copy.

**FR-3.4 — Delete song.** Confirmation dialog, then removal.

## 5. Quick Picks

**FR-4.1** Two-column screen: Quick Picks on the left, All Songs on the right.

**FR-4.2** Add a song to Quick Picks from the right column. Songs already
featured show a non-interactive marker instead of an add button.

**FR-4.3** Remove a song from Quick Picks from the left column.

**FR-4.4** Both lists reload after any change.

## 6. Artist management — **Proposed**

Not built. `add_artist_page.dart` is a placeholder. Full design and phasing in
**`plan-add-artist.md`**; the summary:

**FR-5.1** Create an artist with a **name** and an uploaded **banner image**.

**FR-5.2** Browse artists; edit name/banner; delete.

**FR-5.3** Open one artist to see the songs credited to them.

**FR-5.4** Attach **existing** songs to an artist (multi-select from the song
library).

**FR-5.5** Upload a **new** song directly under an artist — creates the song and
the credit in one flow.

**FR-5.6** Detach a song from an artist without deleting the song.

### Data model note

A song can credit several artists — live data contains rows like
`"Dev Negi, Palak Muchhal, Alka Yagnik"`. The relationship is therefore
**many-to-many**, backed by a `song_artists` join table. `songs.artist` stays as
the denormalised display string so existing endpoints and the consumer app keep
working unchanged.

---

## 7. Non-functional

### NFR-1 — Design
Dark-mode glassmorphism. The system is specified in **`design.md`** and must be
followed for new screens rather than reinvented.

### NFR-2 — State management
`flutter_bloc` for anything new. The codebase is mid-migration off GetX; see
`progress.md` for which modules are converted.

### NFR-3 — Feedback
All user feedback goes through `showOverlayToast` — a custom top-right overlay
with a countdown bar. Not `SnackBar`.

Blocs must not hold a `BuildContext`. They publish `toastMessage` /
`toastSuccess` on their state; the view's `BlocListener` renders it and
dispatches a clear-event.

### NFR-4 — Networking
Dio. Endpoint URLs live only in `lib/url_admin.dart`. Writes that carry files
use `multipart/form-data`.

### NFR-5 — Structure
Feature-first: `lib/pages/<feature>/{bloc,repo}/`. Shared models in
`lib/models/`, shared widgets in `lib/widgets/`.

---

## 8. API

Base URL: `https://workwithshubh.online/music_apis/`

Every response is `{"success": bool, "message": String, "data": ...}` — reads
put their payload in `data`, writes generally return only `success`+`message`.

### Live — verified present

| Endpoint | Method | Payload |
|---|---|---|
| `admin_login.php` | POST json | `{admin_id, admin_pass}` |
| `admin_add_songs.php` | POST multipart | `title, artist, coverfile, songfile` |
| `get_all_songs.php` | GET | — |
| `admin_update_song.php` | POST multipart | `songid, title, artist, coverfile?, songfile?` |
| `admin_delete_song.php` | POST json | `{songid}` |
| `add_to_quick_picks.php` | POST json | `{songid, isquickpick: 1}` |
| `get_quick_picks.php` | GET | — |
| `remove_from_quick_picks.php` | POST json | `{songid}` |

Song object:

```json
{
  "songid": 21,
  "title": "Bandhu 2.0",
  "songurl": "uploads/songs/song_6a6c9ac699edc0.38162640.mp3",
  "coverurl": "uploads/covers/cover_6a6c9ac69b8710.86777118.jpg",
  "artist": "Neeraj Shridhar, Kavita Seth",
  "isquickpick": 1
}
```

`songurl` and `coverurl` are **relative** — prefix with `baseUrl` to load them.

### Proposed — artist endpoints

None of these exist yet (all seven candidate names return 404). Contract and SQL
schema are specified in `plan-add-artist.md` §2.
