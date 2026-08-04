# Design language — music_app_admin

Dark-mode **glassmorphism**: translucent blurred panels floating over a
full-bleed background image, white text lifted off it with a soft glow.

Every value below is taken from the shipped code. When building a new screen,
pull from this file rather than inventing a variant.

---

## The glass stack

Panels are always built in this order. Getting the order wrong (blur outside the
clip, fill outside the blur) is what makes glass look muddy.

```dart
Container(                                    // 1. border lives on the outside
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      width: 0.5,
      color: Colors.grey.shade200.withAlpha(70),
    ),
  ),
  child: ClipRRect(                           // 2. clip before blurring
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(                    // 3. blur what is behind
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(                       // 4. translucent fill on top
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade200.withAlpha(60),
        ),
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ),
  ),
)
```

Backgrounds sit under it as: full-bleed image (`BoxFit.cover`) → a
`Container(color: Colors.black.withAlpha(70))` scrim → content.

### Blur radius by context

| Context | sigma |
|---|---|
| Login card | 7 |
| Toasts, bulk-upload dialog, song hover preview | 10 |
| Edit-song dialog | 12 |

Rule of thumb: the more content sits behind it, the stronger the blur.

---

## Colour

Alpha is expressed with `withAlpha(0–255)`, not `withOpacity` — the two
`withOpacity` calls left in `song_tile.dart` are deprecated and on the cleanup
list.

| Token | Value | Use |
|---|---|---|
| Background scrim | `Colors.black.withAlpha(70)` | over background media |
| Heavy scrim | `Colors.black.withAlpha(120)` | dialog barriers |
| Glass fill | `Colors.grey.shade200.withAlpha(60–80)` | panel interiors |
| Glass border | `Colors.grey.shade200.withAlpha(70–120)` | panel edges, `0.5–1.0` wide |
| Nested fill | `Colors.grey.shade100.withAlpha(40)` | rows inside a panel |
| Opaque surface | `Color(0xFF1F1F1F)` | `AlertDialog`, list-tile hover |
| Primary text | `Colors.white` | titles, labels, icons |
| Secondary text | `Colors.white70` | hints, subtitles, metadata |
| Idle border | `Colors.white30` | inputs, outlined buttons |
| Focus border | `Colors.white` | focused inputs |
| Destructive | `Colors.redAccent` | delete |
| Error text | `Color(0xFFFFB4AB)` | validation messages |
| Failure text | `Colors.red[100]` | failed-row detail |
| Success | `Colors.greenAccent` | completed upload |
| Warning / info | `Colors.amber[100]` | file size, missing-art callouts |
| Seed | `Colors.blue` | `ColorScheme.fromSeed` |

There is no accent brand colour. Hierarchy comes from **white at different
opacities**, plus glow.

---

## Glow

The signature effect. Applied to headings, primary icons and primary button
labels — never to body text.

```dart
const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];
```

Declare it once per file as a private top-level `const`. Amber variants exist
for the file-size readout.

---

## Type

`GoogleFonts.josefinSansTextTheme()` for everything, `GoogleFonts.pacifico()`
for `TextButton` labels via `textButtonTheme` — set globally in
`main.dart`, so buttons pick it up without per-widget styling.

| px | Use |
|---|---|
| 32 | Section headings ("All Songs", "Quick Picks") |
| 26 | Dialog titles |
| 24 | Page / smaller dialog titles |
| 20 | Primary button labels, dialog field labels |
| 18 | Secondary button labels |
| 16 | Nav-card labels, list headers, body |
| 14 | Compact button labels |
| 13 | Input text |
| 12 | Subtitles, file metadata, counts |
| 11 | Callouts, error detail |

---

## Shape and spacing

**Radius** — 20 panels/dialogs/nav cards · 15 inputs · 12 thumbnails and
previews · 10 nested images · 8 list rows · 6 bulk-upload thumbnails.

**Padding** — `fromLTRB(24, 80, 24, 24)` page content (the 80 clears the top
edge) · `all(24)` large panels · `all(20)` cards · `fromLTRB(20, 20, 10, 20)`
list panels (short right side leaves room for the scrollbar) · `all(10)` compact
· `symmetric(horizontal: 20)` rows · `symmetric(vertical: 16)` inputs.

**Gaps** — 4, 8, 10, 12, 20, 24, 40, 80.

---

## Components

### Input

```dart
TextFormField(
  style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(
    hintStyle: const TextStyle(color: Colors.white70),
    errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white30),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  ),
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

### Buttons

- **Primary** — `TextButton.icon`, white label + `_glow`,
  `iconAlignment: IconAlignment.end` (icon trails the label).
- **Confirm inside a dialog** — `FilledButton.icon`,
  `backgroundColor: Colors.white.withAlpha(60)`.
- **Destructive** — `FilledButton.icon` on `Colors.redAccent`.
- **File picker** — full-width `OutlinedButton.icon`, `Colors.white30` side.
- **Tertiary** — bare `TextButton`, `Colors.white70`.

Icon buttons carry a `tooltip` and a tinted `hoverColor` (`Colors.white24`, or
`Colors.redAccent.withAlpha(60)` when destructive).

### Nav card

80 tall, in a 340-wide rail, `all(10)` outer padding, centred icon + 16px label,
wrapped in `InkWell(borderRadius: BorderRadius.circular(20))`.

### List row

`ListTile` inside `Material(color: Colors.transparent)`, radius 8,
`tileColor` a translucent grey, `hoverColor: Color(0xFF1F1F1F)`, 50×50 leading
thumbnail at radius 12 via `CachedNetworkImage`.

`SongTile` takes an optional `trailing` widget so the same row serves both the
quick-picks screen and the editable All Songs list.

### Card grid

`LayoutBuilder` → `columns = (maxWidth / 280).floor().clamp(1, 6)`, then a
`GridView.builder` with `mainAxisSpacing`/`crossAxisSpacing` 20 and
`childAspectRatio: 16 / 9`.

The card itself is a 16:9 `AspectRatio` inside `ClipRRect` radius 20, stacked
as: image → bottom-up `LinearGradient` to `Colors.black87` (stops `0, 0.7`) →
title 16px + `_glow` and metadata 12px `white70` at bottom-left → a transparent
`Material`/`InkWell` covering the card → row actions top-right.

Fixing the aspect ratio up front is what stops the grid reflowing as remote
images arrive.

**Row actions stay visible**, on a `Colors.black.withAlpha(70)` pill at radius
20, rather than fading in on hover — a hover-only affordance is invisible to
touch and keyboard, and on the artist card it is the only route to edit.

Missing image → glass fill plus a centred `Icons.person` in `white70`. Enough
rows have no image that the placeholder has to look deliberate.

### Banner header

220 tall, full width, `BoxFit.cover`, under a flat
`Colors.black.withAlpha(120)` scrim — heavier than the page scrim because
32px text sits directly on the photo. Title + count bottom-left at 24 inset,
back top-left and edit top-right at `top: 20`.

### Toast — `showOverlayToast(context, success, message)`

300×65 `OverlayEntry` pinned top-right, blur 10, rounded on the top corners
only, message capped at 2 lines, and a `LinearProgressIndicator` counting the
3-second dismissal down (`RotatedBox(quarterTurns: 2)` so it drains
right-to-left). White bar on success, `Colors.redAccent` on failure.

### Images

Remote images always go through `CachedNetworkImage` with both a
`placeholder` (`CircularProgressIndicator`, `strokeWidth: 0.5`) and an
`errorWidget`. URLs from the API are relative — always `"$baseUrl${song.coverurl}"`.

### Progress

Thin, white, deliberately understated: `strokeWidth: 0.5` inline in rows and
image placeholders, `2` inside buttons.

---

## Motion

Route pushes slide right-to-left over `Curves.easeOut` (`_slideIn` in
`main.dart`). The login background pans horizontally on a 200-second repeating
`AnimationController` across three tiled copies of the image.

---

## Assets

| File | Size | Used by |
|---|---|---|
| `sunflower-girl.1920x1080.gif` | 95.6 MB | home, add-artist backgrounds |
| `my_bg_2.png` | 12.1 MB | login, panning background |
| `my_bg.png` | 4.0 MB | unused |
| `gradient_layer.png` | 1.8 MB | login gradient overlay |
| `soch na sake.jpg` | 71 KB | unused |

~113 MB total, all of it shipped in the web bundle. The GIF alone is 85% of it —
see `bugs_and_errors.md` → BUG-02 before adding more background media.

---

## Applying this to new screens

1. Full-bleed background → `black.withAlpha(70)` scrim → glass panels.
2. Reach for an existing token before adding a value.
3. Glow on headings and primary actions only.
4. Feedback is a toast; row-level progress is a `strokeWidth: 0.5` spinner that
   replaces that row's actions.
5. Every remote image gets a placeholder and an error widget.
