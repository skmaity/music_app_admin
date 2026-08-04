import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The admin session token, persisted across page reloads.
///
/// On web a refresh restarts the isolate, so an in-memory token meant every
/// reload bounced back to login. The token is written to `shared_preferences`
/// (localStorage on web) and restored by [restore] before `runApp`, so the
/// router's first redirect already sees the session. Logout still invalidates
/// it server-side, and `admin_sessions` remains the source of truth — a stale
/// saved token is rejected with a 401 and cleared by [authDio]. (C3/C4)
class Session {
  Session._();

  static const _key = 'admin_token';
  static SharedPreferences? _prefs;

  /// Held in a notifier so the router can listen: clearing the token (logout,
  /// or a 401) re-runs the redirect guard and lands on login immediately.
  static final ValueNotifier<String?> _token = ValueNotifier(null);

  static Listenable get changes => _token;

  static String? get token => _token.value;

  static set token(String? value) {
    final t = (value != null && value.isNotEmpty) ? value : null;
    if (t == null) {
      _prefs?.remove(_key);
    } else {
      _prefs?.setString(_key, t);
    }
    _token.value = t;
  }

  static bool get isAuthed => _token.value != null;

  static void clear() => token = null;

  /// Loads any saved token. Must be awaited before `runApp`.
  static Future<void> restore() async {
    _prefs = await SharedPreferences.getInstance();
    _token.value = _prefs!.getString(_key);
  }
}

/// A [Dio] that attaches the session token and sane timeouts to every request.
///
/// Use this for all admin calls: a write can then never go out unauthenticated,
/// and no request can hang forever (H3). Read endpoints simply ignore the
/// header. Login itself uses its own client — it has no token to send yet.
Dio authDio() {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 120),
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final t = Session.token;
      if (t != null && t.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $t';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      // A restored token the server no longer knows about. Drop it so the
      // router guard returns to login instead of leaving a dead session up.
      if (error.response?.statusCode == 401) {
        Session.clear();
      }
      handler.next(error);
    },
  ));
  return dio;
}
