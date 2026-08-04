# Pre-Production Audit & Fix Tracker

Full production-readiness audit of **`music_app_admin`** (Flutter web) + **`music_apis`**
(PHP/MySQL on Hostinger). Findings from 2026-08-04, verified against the live host
`workwithshubh.online`.

**Verdict: 🔴 NOT READY FOR PRODUCTION.** Readiness score **22/100**. The Flutter
BLoC architecture is solid; the backend has effectively no security model.

Severity key: 🔴 Critical (blocks deploy) · 🟠 High · 🟡 Medium · 🟢 Low.

---

## Progress Tracker

Update the Status column as we go: ⬜ Todo · 🔧 In progress · ✅ Done · ⏭️ Deferred.

### The hard gate — must be done before any deploy
| ID | Severity | Issue | Status |
| --- | --- | --- | --- |
| C1 | 🔴 | `create_new_admin.php` publicly creates admins | ✅ |
| C2 | 🔴 | Plaintext passwords; login/signup hash formats disagree | ✅ |
| C3 | 🔴 | No auth/authorization on any data endpoint | ✅ |
| C4 | 🔴 | Login is client-only; routes unguarded | ✅ |
| C5 | 🔴 | Uploads executable from web root; extension-only checks | ✅ |
| H2 | 🟠 | DB credentials committed in source | ✅ code / ⬜ rotate password |

### High
| ID | Severity | Issue | Status |

| --- | --- | --- | --- |
| H1 | 🟠 | `create_artist.php` duplicate path leaks row + false success | ✅ |
| H3 | 🟠 | No Dio timeouts on most clients | ✅ |
| H4 | 🟠 | No upload size limit (client or server) | ✅ (server) |
| H5 | 🟠 | `ResponceMessage.fromJson` unguarded casts crash | ✅ |
| H6 | 🟠 | `showOverlayToast` can throw after screen disposed | ✅ |
| H7 | 🟠 | Add Songs: dup SnackBar+toast; no duplicate guard | ✅ |

### Medium
| ID | Severity | Issue | Status |
| --- | --- | --- | --- |
| M1 | 🟡 | `search_from_all_songs.php` interpolates LIMIT/OFFSET | ✅ |
| M2 | 🟡 | Duplicate GetX + BLoC for Add Songs; Quick Picks still GetX | ✅ |
| M3 | 🟡 | Dead code shipped (services, alert_msg, dio_helper, …) | ✅ |
| M4 | 🟡 | `MySongs` model drops `artist_id` | ⬜ |
| M5 | 🟡 | `debugPrint` of response bodies in upload paths | ⬜ |
| M6 | 🟡 | Title "Flutter Demo"; mismatched blue theme | ⬜ |
| M7 | 🟡 | `get_all_artists.php` join double-counts, unindexed | ⬜ |

### Low / nice-to-have
| ID | Severity | Issue | Status |
| --- | --- | --- | --- |
| L1 | 🟢 | `ResponceMessage` filename/class typo | ⬜ |
| L2 | 🟢 | Weak login validators, no trim/min-length | ⬜ |
| L3 | 🟢 | `mkdir(0777)` world-writable upload dirs | ⬜ |
| L4 | 🟢 | `PDO::ATTR_PERSISTENT` risky on shared hosting | ⬜ |
| L5 | 🟢 | Password field not `obscureText` | ⬜ |
| L6 | 🟢 | 95 MB GIF asset (~110 MB total) | ⬜ |
| L7 | 🟢 | Quick Picks has no empty/error state | ✅ (via M2) |
| L8 | 🟢 | `add_to_quick_picks.php` doesn't verify songid exists | ⬜ |
| L9 | 🟢 | CORS `*` on all endpoints | ⬜ |

### One-off cleanup
- ⬜ Delete test admin row (`admin_id` starting `probe_`) created during the audit.
- ⬜ Delete test artist `ZZProbe23233` created during earlier debugging.

---

## 🔴 Critical

### C1. `create_new_admin.php` is publicly reachable — anyone can mint an admin
- **File:** `music_apis/create_new_admin.php`
- **Problem:** No auth guard. A live POST returns `{"success":true,"message":"Admin created successfully."}`.
- **Impact:** Full compromise — attacker creates an account, logs in, deletes the catalog and files.
- **Fix:** Remove from the server, or gate behind an authenticated session + server-side secret. Stopgap in `.htaccess`:
  ```apache
  <FilesMatch "^create_new_admin\.php$">
      Require all denied
  </FilesMatch>
  ```

### C2. Passwords stored & compared in plaintext; login disagrees with signup
- **Files:** `admin_login.php:48`, `create_new_admin.php:29`
- **Problem:** Login does `$admin_pass == $result['pass']` (plaintext). Signup stores `password_hash(...)` (bcrypt). Accounts made via signup can never log in; the working account must be plaintext in the DB.
- **Impact:** DB breach exposes credentials directly; timing/type-juggling risk; formats inconsistent.
- **Fix:** bcrypt everywhere + `password_verify`; return a generic "Invalid credentials." Re-hash the existing admin password.

### C3. No authentication/authorization on any data endpoint
- **Files:** all `music_apis/*.php` except login
- **Problem:** Every write (add/update/delete song & artist, quick-picks) is anonymous. URLs are in the built JS bundle.
- **Impact:** Anyone can add/edit/delete data and upload files. Login is cosmetic.
- **Fix:** Issue a token on login (`bin2hex(random_bytes(32))`) stored in a `sessions` table; add `requireAuth()` in `config.php`, call it in every write endpoint.

### C4. Login is client-only; routes unguarded
- **Files:** `login_repo.dart`, `login_bloc.dart`, `main.dart` router
- **Problem:** App trusts `success:true` and navigates to `/home`. No server session, no `go_router` `redirect` guard — anyone can navigate straight to `/home` or call writes directly.
- **Fix:** Falls out of C3 — store token, add `redirect:` guard, attach token to Dio requests.

### C5. Uploads served from web root with no execution guard
- **Files:** `uploads/{songs,covers,artists}/`, all upload endpoints
- **Problem:** Uploads are directly downloadable; type validation is extension-only (no MIME sniff). `.htaccess` doesn't block `.php`/`.phtml`/`.phar` under `uploads/`.
- **Impact:** With no auth (C3), an uploaded `shell.php` = remote code execution.
- **Fix:** `uploads/.htaccess`:
  ```apache
  php_flag engine off
  <FilesMatch "\.(php|phtml|phar|phps|cgi|pl)$">
      Require all denied
  </FilesMatch>
  Options -ExecCGI -Indexes
  ```
  Plus `finfo_file` MIME allowlist and a size cap (H4).

---

## 🟠 High

### H1. `create_artist.php` duplicate path leaks row + false success
- **File:** `create_artist.php:56-60` — duplicate name returns `success:true` and dumps the existing row.
- **Fix:** Return `success:false, 'Artist already exists.'` with no payload. Rely on `UNIQUE KEY uniq_artist_name`.

### H2. DB credentials committed in source
- **File:** `config.php:5-8` (host/db/user/password in the repo, in git history).
- **Fix:** Move to env vars outside web root; **rotate the password** (already exposed).

### H3. No Dio timeouts on most clients
- **Files:** `all_songs_bloc.dart:12`, `add_songs_bloc.dart:15`, `add_songs_controller.dart:38`, `quick_picks_controller.dart:11`, `login_repo.dart:8`. Only `ArtistRepo` sets them.
- **Fix:** `BaseOptions(connectTimeout: 20s, receiveTimeout: 120s)` on every `Dio()`.

### H4. No upload size limit (client or server)
- **Files:** all upload endpoints; pickers use `withData:true` (whole file in memory).
- **Fix:** Server-side byte cap per file (e.g. 15 MB audio / 5 MB image), validate `$_FILES['x']['size']` before `move_uploaded_file`; surface PHP size errors.

### H5. `ResponceMessage.fromJson` unguarded casts crash
- **File:** `model/responce_message.dart:28-31` — `success: json["success"]`, `message: json["message"]`.
- **Fix:** `success: json['success'] == true`, `message: '${json['message'] ?? ''}'`.

### H6. `showOverlayToast` can throw after screen disposed
- **File:** `widgets/top_right_msg.dart:19-21` — unconditional `Future.delayed(3s, remove)`.
- **Fix:** Guard removal (`if (overlayEntry.mounted) overlayEntry.remove();`).

### H7. Add Songs: duplicate SnackBar+toast; no duplicate guard
- **File:** `addsongs_page/add_songs_page.dart:349` — fires SnackBar and overlay toast; re-uploading same title/artist makes a second row.
- **Fix:** Drop the SnackBar; add duplicate guard or confirm.

---

## 🟡 Medium

- **M1** `search_from_all_songs.php:39` interpolates `LIMIT $limit OFFSET $offset` (int-cast + clamped, so not currently injectable). Bind as `PARAM_INT`.
- **M2** `add_songs_controller.dart` (GetX) duplicates `add_songs_bloc.dart` (unused); Quick Picks still GetX. Finish migration, delete controller + `get`.
- **M3** Dead code: `services.dart`, `widgets/alert_msg/alert_msg.dart`, `initial_binding.dart`, `network_manager/dio_helper.dart` (placeholder host), `login_controller.dart`. Delete.
- **M4** `models/song_model.dart` has no `artist_id`. Add it.
- **M5** `debugPrint` of response bodies in `add_songs_controller.dart` / `add_songs_bloc.dart`. Remove or gate on `kDebugMode`.
- **M6** `main.dart:25,33` title `'Flutter Demo'` + blue seed; Add Songs/Quick Picks use `Colors.blueAccent` scaffold. Align theme.
- **M7** `get_all_artists.php:22` `OR s.artist = a.name` join double-counts and can't use the `artist_id` index. Count by id, backfill, drop name-match.

## 🟢 Low

- **L1** `ResponceMessage` typo (class + filename).
- **L2** Login validators generic; no trim/min-length.
- **L3** `mkdir(0777)` → use `0755`.
- **L4** `PDO::ATTR_PERSISTENT` risky on shared hosting.
- **L5** Password field missing `obscureText: true`.
- **L6** 95 MB GIF asset; ~110 MB assets. Compress to WebP/video.
- **L7** Quick Picks lacks empty/error state.
- **L8** `add_to_quick_picks.php` doesn't verify songid exists (silent 0-row success).
- **L9** CORS `*` everywhere — tighten to the domain once auth exists.

---

## Edge cases traced

| Scenario | Today |
| --- | --- |
| Duplicate artist | `success:true` + leaks row (H1) |
| Duplicate song | Silently creates second row (H7) |
| Empty form | ✅ Blocked by validators |
| Invalid file type | ✅ Extension-checked; ❌ MIME not verified (C5) |
| Huge file / network drop | ❌ Hangs (H3), no size cap (H4), no retry |
| Refresh during upload | ❌ Lost silently |
| Expired/no session | ❌ No sessions exist (C3) |
| Bad artist id in URL | ✅ Clean "not found" |
| SQL injection via search | ✅ Prepared/bound |
| Stranger calls delete endpoint | ❌ Works — no auth (C3) |
