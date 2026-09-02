# CLAUDE.md

Admin panel for a music streaming app. Flutter, targeting **web/desktop** (wide
two-column layouts, `file_picker` with `withData: true` for in-memory bytes —
there is no mobile layout).

## Commands

```bash
flutter pub get
flutter analyze          # expected: 3 info-level lints, 0 errors
flutter build web        # the primary target
flutter run -d chrome
```

`test/widget_test.dart` is still the untouched Flutter template — there is no
real test suite.

## Backend

A PHP API, not Firebase. Firebase was the original backend; every trace of it is
commented out (`lib/services.dart` is an empty shell kept only for reference).

All endpoints live in `lib/url_admin.dart` as top-level `String` globals built
from `baseUrl` (`https://workwithshubh.online/music_apis/`). Add new endpoints
there rather than inlining URLs.

Responses are `{success: bool, message: String, data: [...]}`. Uploads are
multipart form-data via Dio; cover/audio go as `MultipartFile.fromBytes`.

Note `lib/network_manager/dio_helper.dart` is **not used** — it points at a
placeholder host. Each bloc constructs its own `Dio()`; `ArtistRepo` is the one
exception and owns the Dio for all six artist endpoints.

The PHP sources live in `../music_apis/`. Read them rather than guessing a
contract — the response shape is not uniform. Most endpoints wrap their payload
in `data`, but `get_artist_details.php` returns `artist` and `songs` at the top
level and `update_artist.php` is flat. Every artist endpoint reads `$_POST`, so
writes must go out as `FormData`; a JSON body arrives empty.

**Artists relate to songs one-to-many** via `songs.artist_id` (`ON DELETE SET
NULL`). There is no join table — a song has at most one artist.

## State management: mid-migration GetX → BLoC

This is the single most important thing to know about the codebase. Both
patterns are live simultaneously.

| Module | Pattern | Notes |
| --- | --- | --- |
| Login | **BLoC** | `LoginBloc` + `LoginRepo`; done |
| All Songs | **BLoC** | `AllSongsBloc`; done |
| Add Songs | **BLoC written, UI not migrated** | `AddSongsBloc` exists and is complete, but `add_songs_page.dart` and `bulk_upload_dialog.dart` still drive `AddSongsController` via `Obx`/`Get.put` |
| Quick Picks | **GetX** | untouched |
| Artists | **BLoC** | `ArtistsBloc` + `ArtistDetailBloc` on a shared `ArtistRepo`; done |
| Listeners | **BLoC** | `StatsBloc`; done. Card on the home page, not a route |

**Write new code as BLoC.** `get` stays in `pubspec.yaml` only until Add Songs
and Quick Picks are migrated; `song_tile.dart` also still uses `Get.dialog` for
its hover preview.

Bloc conventions in use:

- `part 'x_event.dart'` / `part 'x_state.dart'` alongside the bloc.
- States extend `Equatable`. Single-state-class blocs (`AllSongsBloc`,
  `AddSongsBloc`) use `copyWith`; `LoginBloc` uses discrete state subclasses.
- To *clear* a nullable field, `copyWith` takes a getter-wrapped param
  (`String? Function()? toastMessage`) so `null` means "unchanged" and
  `() => null` means "clear it". Don't break this pattern.

## Toasts and per-row feedback

Blocs never touch `BuildContext`. They put `toastMessage`/`toastSuccess` on the
state; a `BlocListener` in the view calls `showOverlayToast` and then dispatches
a "completed" event to clear it (see `all_songs_section.dart`).

`showOverlayToast` (`lib/widgets/top_right_msg.dart`) is a custom top-right
`OverlayEntry` with an animated countdown bar. Not a SnackBar. Use it for all
user feedback.

Row-level operations set `busyId` (the `songid` being written) so a single row
spins rather than the whole list. Dialogs that trigger a write dispatch the
event and pop immediately — the row spinner and the toast are the feedback.

## Layout of `lib/`

```
models/song_model.dart      MySongs — the ONE song model, Equatable
model/responce_message.dart ResponceMessage (sic — typo is in the filename too)
url_admin.dart              all API endpoint globals
widgets/top_right_msg.dart  showOverlayToast
pages/<feature>/
  bloc/                     bloc + part'd event/state
  repo/                     login and artists have one; other blocs call Dio directly
models/artist_model.dart    Artist — Equatable, parses defensively
pages/artists/              grid, detail, and the three dialogs
```

`SongTile` lives under `pages/quick_picks/` but is shared with the home page's
All Songs list — it takes a `trailing` widget to swap the quick-pick button for
edit/delete actions.

## Routing

`go_router`, routes declared in `lib/main.dart`. Sub-pages use `_slideIn()` for
a right-to-left transition (this replaced GetX's `Transition.rightToLeft`).

## Design language

Dark-mode glassmorphism, fully documented in **`doc/design.md`** — read it
before touching UI. The short version: `BackdropFilter` blur 7–12, fills of
`Colors.grey.shade200.withAlpha(60–80)`, radius 20, white text with
`Shadow(blurRadius: 9, color: Colors.white)` glow, Josefin Sans body + Pacifico
on buttons.

- `doc/requirements.md` — feature spec and the endpoint table. Endpoints are
  marked **Live** (verified against the running API) or **Proposed**.
- `doc/progress.md` — what is built, what is mid-migration, what is dead code.
- `doc/bugs_and_errors.md` — known issues, and the recurring traps in "Patterns
  to watch".
- `doc/plan-add-artist.md` — **superseded**; it designed a many-to-many join
  table that the shipped backend does not have. Kept for the rationale only.

## Gotchas

- **The listener stats need two deploy steps before they show anything.**
  `../music_apis/migration_app_users.sql` must be run once in phpMyAdmin, and
  `track_user.php` + `get_app_stats.php` uploaded. Separately, the count only
  grows once a **phone app release carrying the launch ping** is out — the ping
  lives in `music_app`'s `UseridController._ping`, so the installs already in
  the wild are invisible until users update. The migration backfills whatever
  it can from `user_fav`, which is the only table that has ever held a real
  user id, so the card starts with a real (under-counted) number rather than 0.
- **The live DB is missing the artist schema.** The six artist endpoints *are*
  deployed now (200, not 404) but all of them answer
  `{"success":false,"message":"Internal server error."}` because neither the
  `artists` table nor the `songs.artist_id` column exists in `u562761769_db1`
  (checked 2026-08-04). The missing column also breaks
  `admin_update_song.php`, so editing a song fails too. Fix is
  `../music_apis/migration_artists.sql`, run once in phpMyAdmin — no code
  change; the Flutter side is complete.
- There is no link-song endpoint. `ArtistRepo.setSongArtist` reuses
  `admin_update_song.php`, which owns `songs.artist_id`. Unlinking works by
  passing the `"Unknown Artist"` sentinel, because that endpoint rejects a
  request carrying neither an artist name nor an id.
- **Known issue, deferred:** the background `assets/sunflower-girl.1920x1080.gif`
  is **91 MB** and backs three pages. On web it regularly fails to load and it
  thrashes Flutter's 100 MiB `imageCache` (~8.3 MB per decoded 1920x1080 frame),
  so it re-fetches whenever you move between those pages. The fix is to
  re-encode it to animated WebP (~5-10 MB, `AssetImage` decodes it natively) and
  repoint the three `AssetImage`s. Note `pubspec.yaml` globs all of `assets/`,
  so the old file must be deleted or it still ships in the bundle.
- Login returns a token, stored via `shared_preferences` and restored by
  `Session.restore()` before `runApp` so a page reload keeps the session.
  `Session.changes` is the router's `refreshListenable`; `authDio()` clears the
  token on a 401, which bounces to login.
- `MySongs.fromJson` assumes every field is present and correctly typed — a
  missing field crashes at runtime.
- Dio calls have no timeout configured.
- Dead code still present: `services.dart`, `widgets/alert_msg/alert_msg.dart`
  (entirely commented out), `initial_binding.dart`, `network_manager/dio_helper.dart`.
