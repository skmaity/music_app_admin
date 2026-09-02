import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app_admin/pages/all_songs/all_songs_section.dart';
import 'package:music_app_admin/pages/all_songs/bloc/all_songs_bloc.dart';
import 'package:music_app_admin/pages/stats/bloc/stats_bloc.dart';
import 'package:music_app_admin/pages/stats/listeners_card.dart';
import 'package:music_app_admin/session.dart';
import 'package:music_app_admin/url_admin.dart';

const _glow = [
  Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int containerOpacity = 80;
  int borderOpacity = 120;

  /// Invalidates the token server-side, clears it locally, then the router
  /// guard sends us back to login. (C4)
  Future<void> _logout() async {
    try {
      await authDio().post(adminLogoutUrl);
    } catch (_) {
      // Even if the network call fails, drop the local token below.
    }
    Session.clear();
    if (mounted) context.go('/admin');
  }

  Widget _navCard(IconData icon, String label, String route) => Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(route),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1,
                  color: Colors.grey.shade200.withAlpha(borderOpacity)),
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200.withAlpha(containerOpacity),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, shadows: _glow, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, shadows: _glow),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/sunflower-girl.1920x1080.gif'),
              fit: BoxFit.cover),
        ),
        child: Container(
          color: Colors.black.withAlpha(70),
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 340,
                child: Column(
                  children: [
                    _navCard(Icons.music_note, 'Add Songs', '/addsong'),
                    _navCard(Icons.hotel_class_rounded, 'Quick picks',
                        '/quickpicks'),
                    _navCard(Icons.person, 'Artists', '/artists'),
                    // Not a nav card and not a route: the count is here to be
                    // seen without being asked for.
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: BlocProvider(
                        create: (_) => StatsBloc()..add(const LoadStats()),
                        child: const ListenersCard(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _logout,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.logout,
                            color: Colors.white, shadows: _glow, size: 18),
                        label: const Text('Logout',
                            style:
                                TextStyle(color: Colors.white, shadows: _glow)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: BlocProvider(
                  create: (_) => AllSongsBloc(),
                  child: const AllSongsSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
