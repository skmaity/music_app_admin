# Plan — Artist management

> **Superseded — do not build from this.** Written when every candidate artist
> endpoint 404'd, it assumed the backend was still ours to specify. It was not:
> `../music_apis/` already contained a working artist API on a different data
> model, and that is what shipped.
>
> | This plan assumed | What actually exists |
> |---|---|
> | `song_artists` join table, many-to-many | `songs.artist_id`, one artist per song |
> | `artists(id, name, bannerurl)` | `artists(artist_id, name, bio, imageurl, created_at)` |
> | 8 endpoints, `admin_*_artist.php` | 6 endpoints — `create_`/`update_`/`delete_artist.php`, `get_all_artists.php`, `get_artist_details.php`, `add_song_to_artist.php` |
> | `admin_link_songs_to_artist.php` (batch) | none — reuse `admin_update_song.php`, one call per song |
> | Every response `{success, message, data}` | inconsistent: `get_artist_details.php` and `update_artist.php` do not wrap in `data` |
>
> §4 (screens) and §6 (risks) still hold and were followed. §1–§3 and §5 are
> historical. See `CLAUDE.md` for the shipped shape.


Build the artist feature end to end: create artists with a name and banner,
browse them, and file songs under them — either by attaching songs that already
exist, or by uploading a new song directly under the artist.

Nothing exists today. `lib/pages/add_artist_page/add_artist_page.dart` is a
placeholder rendering "Label 1..4", and **all seven candidate artist endpoints
return 404** (verified 2026-08-02).

---

## 1. Decisions

**Songs relate to artists many-to-many, via a `song_artists` join table.**
Live data already credits several artists per song — `"Dev Negi, Palak Muchhal,
Alka Yagnik"` — so a single `artist_id` foreign key would destroy information on
the way in. One song can be filed under any number of artists.

**`songs.artist` stays exactly as it is.** It remains the free-text display
string, authored by the add/edit-song flows and read by the consumer app. The
join table answers a different question: *which artist pages does this song
appear on.* Nothing in this plan rewrites `songs.artist` — see §6 for why that
matters.

**Artists carry a banner, not a square cover.** Wide image, used as the header
of the artist page.

**Backend split:** this plan specifies the schema and the endpoint contract;
you implement the PHP. Everything in §3 onwards is the Flutter side.

---

## 2. Backend contract

### 2.1 Schema

```sql
CREATE TABLE artists (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(255) NOT NULL,
  bannerurl  VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_artist_name (name)
);

CREATE TABLE song_artists (
  song_id   INT NOT NULL,
  artist_id INT NOT NULL,
  PRIMARY KEY (song_id, artist_id),
  CONSTRAINT fk_sa_song   FOREIGN KEY (song_id)   REFERENCES songs(songid) ON DELETE CASCADE,
  CONSTRAINT fk_sa_artist FOREIGN KEY (artist_id) REFERENCES artists(id)   ON DELETE CASCADE
);
```

The composite primary key makes linking idempotent — use `INSERT IGNORE` and a
double-add is a no-op rather than an error.

`ON DELETE CASCADE` means deleting an artist drops their credits but **never
touches the songs themselves**. That is the intended behaviour: deleting an
artist must not delete music.

Banners upload to `uploads/banners/`, alongside the existing `uploads/covers/`
and `uploads/songs/`. `bannerurl` is stored **relative**, like `coverurl`.

### 2.2 Backfill (one-off)

Populate the join table from the artist strings already in `songs`:

1. For each row in `songs`, split `artist` on `,`.
2. Trim each fragment; skip empties and `"Unknown Artist"`.
3. `INSERT IGNORE INTO artists (name) VALUES (?)` — the unique key dedupes.
4. `INSERT IGNORE INTO song_artists (song_id, artist_id)` for each pair.

Artists created this way have `bannerurl = NULL`; the UI must render a
placeholder for that (§4.1). Run it once, after the tables exist and before the
admin starts creating artists by hand.

### 2.3 Endpoints

Base URL and conventions as the existing API: `admin_*` writes, `get_*` reads,
every response `{success, message, data}`.

| # | Endpoint | Method | Request | `data` on success |
|---|---|---|---|---|
| 1 | `get_all_artists.php` | GET | — | `[{id, name, bannerurl, songcount}]` |
| 2 | `admin_add_artist.php` | POST multipart | `name`, `bannerfile` | `{id}` |
| 3 | `admin_update_artist.php` | POST multipart | `id`, `name?`, `bannerfile?` | — |
| 4 | `admin_delete_artist.php` | POST json | `{id}` | — |
| 5 | `get_artist_songs.php` | GET | `?artist_id=N` | `[song]` |
| 6 | `admin_link_songs_to_artist.php` | POST json | `{artist_id, songids: [1,2,3]}` | `{linked: n}` |
| 7 | `admin_unlink_song_from_artist.php` | POST json | `{artist_id, songid}` | — |
| 8 | `admin_add_artist_song.php` | POST multipart | `artist_id`, `title`, `coverfile`, `songfile` | `{songid}` |

Notes that matter to the client:

- **#1** `songcount` comes from `COUNT(song_artists.song_id)` via `LEFT JOIN`, so
  artists with no songs return `0`, not a missing key.
- **#5** returns song objects in the **same shape** `get_all_songs.php` uses, so
  the client decodes them with the existing `MySongs.fromJson` and renders them
  with the existing `SongTile`. Do not invent a trimmed shape here.
- **#6** takes an array so attaching twelve songs is one request, not twelve.
  Return `{linked: n}` — with `INSERT IGNORE`, `n` may be less than the number
  submitted if some were already credited, which the UI reports honestly.
- **#8** creates the song *and* the credit in one transaction. On success set
  `songs.artist` to the artist's name — this is the one flow where the display
  string is authoritative, because the song is new and has no other credits.
  Reject with `success: false` if either half fails; do not leave an orphan.
- **#2/#3** the unique name constraint will throw on a duplicate. Catch it and
  return `{success: false, message: "An artist with that name already exists"}`
  rather than a 500 — the UI surfaces `message` verbatim.

---

## 3. Flutter — files

```
lib/models/artist_model.dart                          Artist (Equatable)
lib/pages/artists/repo/artist_repo.dart               all 8 calls
lib/pages/artists/bloc/artists_bloc.dart              list screen
    + artists_event.dart  + artists_state.dart        (part files)
lib/pages/artists/bloc/artist_detail_bloc.dart        one artist
    + artist_detail_event.dart + artist_detail_state.dart
lib/pages/artists/artists_page.dart                   grid + search
lib/pages/artists/artist_detail_page.dart             banner header + songs
lib/pages/artists/widgets/artist_card.dart
lib/pages/artists/widgets/artist_form_dialog.dart     create + edit
lib/pages/artists/widgets/link_songs_dialog.dart      attach existing
lib/pages/artists/widgets/add_artist_song_dialog.dart upload new
```

Deleted: `lib/pages/add_artist_page/` (the stub).

A **repo** is warranted here even though only `LoginBloc` has one today — eight
endpoints shared across two blocs, several of them multipart. Keep all Dio and
all URL construction inside it; the blocs stay pure state machines.

### 3.1 Model

```dart
class Artist extends Equatable {
  final int id;
  final String name;
  final String? bannerurl;   // nullable — backfilled artists have none
  final int songCount;
}
```

Parse defensively — `bannerurl` is genuinely nullable, and per BUG-03 the API
may hand back numbers as strings. `int.tryParse('${json["songcount"]}') ?? 0`.

### 3.2 Bloc conventions

Follow `AllSongsBloc` exactly, because it is the reference implementation:

- One state class per bloc with `copyWith`, extending `Equatable`.
- Nullable fields that need clearing use the getter-wrapped parameter —
  `int? Function()? busyId` — where omitting means *unchanged* and `() => null`
  means *clear*. Do not copy `AddSongsState`'s shortcut here (BUG-09).
- `toastMessage` / `toastSuccess` on the state; the view's `BlocListener` renders
  and then dispatches a clear-event. **Blocs never hold a `BuildContext`.**
- `busyId` marks the one row currently being written.

`ArtistsBloc`: `LoadArtists`, `FilterArtists`, `CreateArtist`, `UpdateArtist`,
`DeleteArtist`, `ArtistOperationCompleted`.

`ArtistDetailBloc`: `LoadArtistSongs`, `LinkSongs`, `UnlinkSong`,
`AddSongToArtist`, `DetailOperationCompleted`. It also needs the full song
library for the link dialog — load it lazily on first open via
`adminGetAllSongsUrl`, not on page load.

### 3.3 URLs

Eight `String` globals appended to `lib/url_admin.dart`, same style as the rest.

---

## 4. Screens

Follow `design.md` — glass stack, `withAlpha`, glow on headings and primary
actions only, `showOverlayToast` for feedback, `strokeWidth: 0.5` row spinners,
`CachedNetworkImage` with placeholder **and** error widget for every remote
image. Two patterns here are new to the app (a card grid, and a banner header),
so run the `ui-ux-pro-max` skill before writing them and fold the result back
into `design.md`.

### 4.1 Artists — `/artists`

Same shell as the dashboard: background GIF → `black.withAlpha(70)` scrim →
content at `fromLTRB(24, 80, 24, 24)`.

- Header row: **Artists** (32px, glow) · count in `white70` · spacer · refresh
  icon · **New artist** primary `TextButton.icon`.
- Search field below, styled per `design.md`, filtering by name client-side —
  same shape as the All Songs search.
- Responsive grid of `ArtistCard`, ~260 wide, `LayoutBuilder` deciding the
  column count.

`ArtistCard`: 16:9 banner at radius 20 with a bottom-up dark gradient, name
(16px, glow) and `N songs` (12px, `white70`) overlaid bottom-left. Whole card is
an `InkWell` → detail. Edit and delete icon buttons fade in on hover, top-right,
with tooltips; delete confirms through the same `Color(0xFF1F1F1F)` `AlertDialog`
that `_confirmDelete` uses for songs — copy that wording, including the warning
that credits are removed but **songs are not deleted**.

Missing banner → the glass fill plus a centred `Icons.person` in `white70`.
Backfilled artists will all look like this, so it needs to look deliberate.

Empty state: "No artists yet — create one to get started."

### 4.2 Artist detail — `/artists/:id`

- **Banner header**, full width, ~220 tall, `BoxFit.cover`, with a
  `black.withAlpha(120)` scrim so text stays legible over any image. Artist name
  32px + glow bottom-left, `N songs` under it. Back button top-left, edit
  top-right.
- **Action row**: `Add existing songs` and `Upload new song`, both primary
  `TextButton.icon`.
- **Song list**: `SongTile` reused as-is, with `trailing` set to a
  remove-from-artist `IconButton` (`Icons.link_off`, tooltip "Remove from this
  artist"). Confirm before unlinking, and say plainly that the song stays in the
  library.
- Row being written → `busyId` spinner, exactly as All Songs does.
- Empty state: "No songs credited to this artist yet."

### 4.3 Link existing songs — dialog

Glass dialog, blur 12, ~520 wide, capped at 75% viewport height.

- Title **Add existing songs**, subtitle showing the selected count.
- Search across title and artist.
- Scrolling `CheckboxListTile` list of the whole library. Songs already credited
  render checked and disabled with a "Already added" trailing label — clearer
  than hiding them, since it explains their absence.
- Footer: `Cancel` · `Add N songs`, disabled at zero.
- Confirm dispatches **one** `LinkSongs` with the selected ids, closes, and the
  detail page reloads. If the server reports fewer linked than submitted, the
  toast says so.

### 4.4 Upload new song under artist — dialog

Structurally the edit-song dialog, so lift its layout.

- Cover picker (`jpg/jpeg/png/webp`) with a live `Image.memory` preview at 110².
- Audio picker (`mp3`), showing the chosen filename.
- Title field, required.
- Artist shown as **fixed, non-editable** text — this is the artist's page, and
  the credit is implied by where you are.
- `Upload` dispatches `AddSongToArtist` and closes; the detail page reloads.

Both dialogs mount on the root navigator, above the `BlocProvider` — so read the
bloc **before** `showDialog` and pass the instance into the widget, exactly as
`showEditSongDialog` does. See BUG-P2.

---

## 5. Phases

Each phase ends compiling and analyzer-clean.

| # | Phase | Deliverable | Depends on |
|---|---|---|---|
| 0 | Backend | Tables, backfill, 8 endpoints live | — |
| 1 | Foundation | URLs, `Artist` model, `ArtistRepo` | 0 |
| 2 | Artists list | `ArtistsBloc`, page, card, form dialog. Create/edit/delete/search all work | 1 |
| 3 | Artist detail | `ArtistDetailBloc`, banner header, song list, unlink | 2 |
| 4 | Link existing | `link_songs_dialog.dart` | 3 |
| 5 | Upload new | `add_artist_song_dialog.dart` | 3 |
| 6 | Wiring | Routes, nav card → `/artists`, delete the stub, update docs | 2–5 |

Phases 4 and 5 are independent of each other.

**If the backend lags**, phases 1–6 can be built against a repo returning
hardcoded fixtures — the seam is `ArtistRepo`, and swapping it for the real Dio
calls touches one file. Worth doing rather than blocking, but do not merge
fixtures to `main`.

### Routing

```dart
GoRoute(path: '/artists',     pageBuilder: (c, s) => _slideIn(const ArtistsPage())),
GoRoute(path: '/artists/:id', pageBuilder: (c, s) => _slideIn(
  ArtistDetailPage(artistId: int.parse(s.pathParameters['id']!)))),
```

Replaces `/addartist`. The dashboard nav card becomes **Artists**. `ArtistsPage`
and `ArtistDetailPage` each own their `BlocProvider` — do not hoist to the
router; the detail bloc is scoped to one artist.

`int.parse` on a hand-typed URL throws — use `tryParse` and render a "not found"
state.

---

## 6. Risks

**`songs.artist` and the join table will drift.** Editing a song's artist text
does not change its credits, and linking does not change the text. This is the
deliberate cost of not destroying the multi-artist strings. It is invisible in
the admin panel — but if the consumer app ever needs artist pages, it must read
the join table, not the string. Reconciling them is a later migration; do not
half-fix it by rewriting the string on link.

**Backfill quality.** Splitting on commas produces artists from whatever is in
the data — featured-artist suffixes, inconsistent spellings, `"Unknown Artist"`.
Expect to merge duplicates by hand afterwards. Consider running the backfill on
a copy first and eyeballing the artist list before committing.

**Artist rename is safe** under this design (ids are the link), which is exactly
why the name-matching approach was rejected.

**Banner sizes.** Nothing constrains the upload, and this app already ships
113 MB of assets (BUG-02). Cap `bannerfile` server-side — reject over ~2 MB, or
downscale to 1280 wide on receipt.

**No auth.** These eight endpoints are as open as the existing ones (BUG-01).
Not a reason to block, but do not treat them as safer than what is already
there.
