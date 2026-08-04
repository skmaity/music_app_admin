# Progress — music_app_admin

Last verified: **2026-08-02**, against `flutter analyze` (0 errors, 3 info) and a
successful `flutter build web`.

Legend: ✅ done · 🔄 partial · ⬜ not started · — n/a

---

## Feature status

| Feature | API | Bloc | UI | Notes |
|---|:--:|:--:|:--:|---|
| Admin login | ✅ | ✅ | ✅ | No token issued — see BUG-04 |
| List all songs | ✅ | ✅ | ✅ | Search + count, on the dashboard |
| Add song (single) | ✅ | 🔄 | ⬜ | `AddSongsBloc` complete; page still GetX |
| Add song (bulk) | ✅ | 🔄 | ⬜ | same — bloc ready, dialog still GetX |
| Edit song | ✅ | ✅ | ✅ | Dispatches and closes; row shows progress |
| Delete song | ✅ | ✅ | ✅ | With confirmation |
| Quick picks | ✅ | ⬜ | ⬜ | Entirely GetX |
| **Artists** | ⬜ | ⬜ | ⬜ | Nothing exists — see `plan-add-artist.md` |

## GetX → flutter_bloc migration

| Module | Bloc written | View converted | Old GetX files removed |
|---|:--:|:--:|:--:|
| Login | ✅ | ✅ | ⬜ `login_controller.dart` still present (dead) |
| All Songs | ✅ | ✅ | ✅ |
| Add Songs | ✅ | ⬜ | ⬜ |
| Quick Picks | ⬜ | ⬜ | ⬜ |

**The Add Songs module is the odd one out.** `AddSongsBloc` is written and
complete, but `add_songs_page.dart` and `bulk_upload_dialog.dart` still drive
`AddSongsController` + `AddSongsFunctions` through `Obx`/`Get.put`. Converting
those two views is the single largest remaining chunk of migration work, and it
retires three files at once.

`get` stays in `pubspec.yaml` until Add Songs and Quick Picks are both
converted. `song_tile.dart` also still uses `Get.dialog` for its hover preview
and `context.width`/`context.height` from GetX extensions.

---

## Done — 2026-08-02

Build was broken; it now compiles. Errors went 113 → 0.

- Added the missing `flutter_bloc` and `equatable` dependencies. Six files
  imported them without them being declared, which alone accounted for ~109 of
  the errors.
- Collapsed the two competing `MySongs` classes into `lib/models/song_model.dart`
  (the Equatable one) and deleted `pages/quick_picks/models/song_model.dart`.
- Rewired `showEditSongDialog` from the deleted GetX controller to
  `AllSongsBloc`; it now dispatches `UpdateSong` and closes immediately, which
  let the dialog's local `_saving` state go away entirely.
- Deleted `all_songs_controller.dart`, which that was the last caller of.
- Fixed an unbalanced paren in `login_page.dart` left by the `BlocProvider`
  wrapper — the file did not parse.
- Provided `AllSongsBloc` in `home_page.dart`. `AllSongsSection` was calling
  `context.read` with no provider above it, which would have crashed at runtime
  the moment the build was fixed.
- Wrote `CLAUDE.md`.

---

## Dead code — safe to delete

Verified unreferenced, or referenced only from commented-out lines:

| File | Why |
|---|---|
| `lib/services.dart` | Empty Firebase shell; named only in comments |
| `lib/initial_binding.dart` | Wired from a commented-out line in `main.dart` |
| `lib/pages/login_page/controller/login_controller.dart` | Only `initial_binding.dart` used it, and that is dead too |
| `lib/widgets/alert_msg/alert_msg.dart` | Entire file is commented out |
| `lib/network_manager/dio_helper.dart` | Never imported; points at a placeholder host |
| `lib/pages/addsongs_page/bindings/add_songs_bindings.dart` | Named only in a comment |

Left in place deliberately — deleting them is cleanup, not a blocker, and it is
better done as one commit than mixed into feature work.

## Backlog

| Task | Priority | Notes |
|---|---|---|
| Build the artist feature | **High** | `plan-add-artist.md` |
| Convert Add Songs views to bloc | High | Retires 3 GetX files |
| Convert Quick Picks to bloc | Medium | Then `get` can be dropped |
| Auth tokens | Medium | Needs backend work first — BUG-04 |
| Delete the dead files above | Low | One commit |
| Shrink the 95 MB GIF | Low | BUG-02 |
| Rename `responce_message.dart` | Low | Typo, no runtime impact |
| `withOpacity` → `withValues` in `song_tile.dart` | Low | The 2 remaining lints |
| Real tests | Low | `widget_test.dart` is still the template |
