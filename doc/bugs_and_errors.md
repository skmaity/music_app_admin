# Bugs & known issues — music_app_admin

Status as of **2026-08-02**. `flutter analyze` reports 0 errors and 3
info-level lints; `flutter build web` succeeds.

Severity: 🔴 breaks or loses data · 🟠 wrong behaviour, recoverable ·
🟡 cosmetic / maintenance

---

## Open

### 🔴 BUG-01 — No auth enforcement anywhere

`admin_login.php` returns only `{success, message}`. Nothing is stored on
success, and no later request carries a credential — so every write endpoint is
open to anyone who knows the URL, and any route can be reached directly by
typing it (`/home` is not guarded by a `go_router` redirect).

Needs the backend to issue a token first. Then: persist it, attach it via a Dio
interceptor, and add a redirect on the router.

---

### 🟠 BUG-02 — 95 MB background GIF

`assets/sunflower-girl.1920x1080.gif` is 95.6 MB and backs two screens. Assets
total ~113 MB, all shipped in the web bundle — a punishing first load, and GIF
decoding holds every frame in memory.

Convert to a looping `<video>`/`webm`, or a static compressed still. Would
recover ~85% of the bundle.

---

### 🟠 BUG-03 — `MySongs.fromJson` trusts the payload

`lib/models/song_model.dart` assigns every field unguarded:

```dart
songid: json["songid"],   // throws if absent, or if the API ever returns "21"
```

A missing or retyped field crashes list rendering rather than degrading. PHP +
MySQL drivers switch between `int` and `String` for numeric columns depending on
configuration, so this is a live risk, not a theoretical one.

Fix: null-coalesce with defaults and coerce (`int.tryParse('${json["songid"]}')`).

---

### 🟠 BUG-04 — No request timeouts

Every bloc builds a bare `d.Dio()` with no `connectTimeout` / `receiveTimeout`.
A hung server leaves spinners running forever with no way back.

`lib/network_manager/dio_helper.dart` already has sensible 10-second timeouts
but is dead code pointing at a placeholder host. Either adopt it properly or set
`BaseOptions` where the blocs construct Dio.

---

### 🟠 BUG-05 — Failed requests offer no way out

When a call fails the only signal is a toast that disappears after 3 seconds.
Lists then sit empty with "No songs yet — add one from Add Songs", which reads
as *no data* rather than *the request failed*. No retry affordance.

Add an error state to the bloc states and an empty/error view with a Retry
button.

---

### 🟠 BUG-06 — `Get.context!` in the add-songs page

`add_songs_page.dart:~340` uses `showOverlayToast(Get.context!, ...)` in the
validation-failure branch. `Get.context` is nullable and this is a GetX
anti-pattern; the widget's own `context` is in scope on the same line.

Resolves itself when the page is converted to bloc — but it is a one-word fix if
touched sooner.

---

### 🟡 BUG-07 — Toast overlay is not cancel-safe

`showOverlayToast` schedules `overlayEntry.remove()` on a bare 3-second
`Future.delayed`. If the route is popped first, that fires against a disposed
overlay. Also, several toasts in quick succession stack at identical
coordinates and overlap.

Hold the entry, guard `remove()` on `entry.mounted`, and offset or queue
concurrent toasts.

---

### 🟡 BUG-08 — Two `BulkSong` / `BulkStatus` declarations

Declared in both `addsongs_page/controllers/add_songs_controller.dart` (mutable
`status`, GetX) and `addsongs_page/bloc/add_songs_state.dart` (immutable,
`copyWith`). Same names, different semantics, both compiling. Exactly the trap
the duplicate `MySongs` created before it was collapsed.

Goes away when the bulk-upload view moves to the bloc. Until then, check which
one an import resolves to before editing.

---

### 🟡 BUG-09 — `AddSongsState.copyWith` silently clears two fields

`add_songs_state.dart:~104` — `message` and `isSuccessMessage` are assigned
straight from the parameters instead of `?? this.x`:

```dart
message: message,                 // any copyWith() without message wipes it
isSuccessMessage: isSuccessMessage,
```

Deliberate (there is a comment saying so) and currently harmless, because every
caller that sets a message immediately follows with `clearMessage()`. But it
contradicts the getter-wrapped pattern the other blocs use, and it will bite
whoever adds a `copyWith` call that expects the message to survive. Convert to
`String? Function()? message` like `AllSongsState` does.

---

### 🟡 BUG-10 — `responce_message.dart` typo

`lib/model/responce_message.dart`, class `ResponceMessage`. Should be
"response". Also note this lives in `lib/model/` (singular) while every other
model is in `lib/models/`.

---

### 🟡 BUG-11 — Deprecated `withOpacity`

`song_tile.dart:139` and `:144`. The two remaining analyzer lints. Everywhere
else uses `withAlpha`. Swap for `withValues(alpha:)`.

---

### 🟡 BUG-12 — Empty catch swallows picker failures

`add_songs_bloc.dart:165` — `_onPickBulkCover` catches and does nothing, so a
failed cover pick is indistinguishable from a cancelled one. The third analyzer
lint.

---

## Patterns to watch

**P-1 — `BuildContext` across async gaps.** The surviving GetX controllers take
a `BuildContext` and use it after `await`, guarded by `context.mounted`. The
guards are correct today, but the pattern is fragile. Blocs must never hold
context — publish toast fields on the state instead.

**P-2 — Bloc-provider scope.** `AllSongsBloc` is provided in `home_page.dart`,
below the router. Dialogs opened with `showDialog` mount on the **root**
navigator, above that provider, so `context.read` inside a dialog builder fails.
Read the bloc *before* calling `showDialog` and pass the instance in — this is
what `showEditSongDialog` does, and the same applies to any artist dialog.

**P-3 — Relative media URLs.** `songurl` and `coverurl` come back relative.
Always prefix with `baseUrl`.

**P-4 — Serial bulk upload.** The queue posts one file at a time. Intentional —
it keeps memory flat and gives per-file status — but 50 files is 50 round trips.
Don't "optimise" it into parallel requests without checking what the PHP side
does under concurrent multipart writes.

---

## Fixed — 2026-08-02

| Was | Fix |
| --- | --- |
| 🔴 `flutter_bloc` / `equatable` / `bloc` imported but not in `pubspec.yaml` — 113 analyzer errors, no build | Declared both deps |
| 🔴 Two different `MySongs` classes; passing one where the other was expected | Collapsed into `lib/models/song_model.dart` |
| 🔴 `login_page.dart` unbalanced paren — file did not parse | Closed the `BlocProvider` |
| 🔴 `showEditSongDialog` called with 2 args, declared with 3, still bound to a deleted GetX controller | Rewired to `AllSongsBloc` |
| 🔴 `AllSongsSection` read `AllSongsBloc` with no provider above it — guaranteed runtime crash | Added `BlocProvider` in `home_page.dart` |
