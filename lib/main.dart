import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_app_admin/home_page.dart';
import 'package:music_app_admin/pages/addsongs_page/add_songs_page.dart';
import 'package:music_app_admin/pages/artists/artist_detail_page.dart';
import 'package:music_app_admin/pages/artists/artists_page.dart';
import 'package:music_app_admin/pages/landing/landing_page.dart';
import 'package:music_app_admin/pages/login_page/login_page.dart';
import 'package:music_app_admin/pages/quick_picks/quick_picks_page.dart';
import 'package:music_app_admin/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Nyro',
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
  refreshListenable: Session.changes,
  redirect: (context, state) {
    final location = state.matchedLocation;
    final public = location == '/' || location == '/admin';
    if (!Session.isAuthed) return public ? null : '/admin';
    if (location == '/admin') return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
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
      pageBuilder: (context, state) => _slideIn(
        ArtistDetailPage(
          artistId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
    ),
  ],
);

CustomTransitionPage _slideIn(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
