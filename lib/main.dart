import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_app_admin/home_page.dart';
import 'package:music_app_admin/pages/add_artist_page.dart';
import 'package:music_app_admin/pages/addsongs_page/add_songs_page.dart';
import 'package:music_app_admin/pages/login_page/login_page.dart';
import 'package:music_app_admin/pages/quick_picks/quick_picks_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      // initialBinding: RootBinding(),
      // home: LoginPage()
      // home: HomePage()
    );
  }
}

final GoRouter _router = GoRouter(initialLocation: '/', routes: [
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
    path: '/addartist',
    pageBuilder: (context, state) => _slideIn(AddArtistPage()),
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
