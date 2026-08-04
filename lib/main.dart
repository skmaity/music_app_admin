import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_app_admin/home_page.dart';
import 'package:music_app_admin/pages/addsongs_page/add_songs_page.dart';
import 'package:music_app_admin/pages/artists/artist_detail_page.dart';
import 'package:music_app_admin/pages/artists/artists_page.dart';
import 'package:music_app_admin/pages/login_page/login_page.dart';
import 'package:music_app_admin/pages/quick_picks/quick_picks_page.dart';
import 'package:music_app_admin/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the saved token first, so the router's initial redirect sees an
  // existing session and a page reload doesn't land on login.
  await Session.restore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,

      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(GoogleFonts.pacifico()),
          ),
        ),
        textTheme: GoogleFonts.josefinSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  // Re-run the guard whenever the token changes, so logout and an expired
  // session (401) leave the current page instead of waiting for a navigation.
  refreshListenable: Session.changes,
  // Login lives at '/'. Everything else needs a session; without one you land
  // back on login, and an already-signed-in admin skips it. (C4)
  redirect: (context, state) {
    final atLogin = state.matchedLocation == '/';
    if (!Session.isAuthed) return atLogin ? null : '/';
    if (atLogin) return '/home';
    return null;
  },
  routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => LoginPage(),
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: '/addsong',
    pageBuilder: (context, state) => _slideIn(AddSongsPage()),
  ),
  GoRoute(
    path: '/quickpicks',
    pageBuilder: (context, state) => _slideIn(QuickPicksPage()),
  ),
  GoRoute(
    path: '/artists',
    pageBuilder: (context, state) => _slideIn(const ArtistsPage()),
  ),
  GoRoute(
    path: '/artists/:id',
    // A hand-typed id that is not a number renders the "not found" state
    // rather than throwing.
    pageBuilder: (context, state) => _slideIn(
      ArtistDetailPage(artistId: int.tryParse(state.pathParameters['id'] ?? '')),
    ),
  ),
]);

/// Right-to-left slide, matching the old `Transition.rightToLeft`.
CustomTransitionPage _slideIn(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
