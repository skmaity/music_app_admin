import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/pages/quick_picks/bloc/quick_picks_bloc.dart';
import 'package:music_app_admin/pages/quick_picks/song_tile.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

class QuickPicksPage extends StatelessWidget {
  const QuickPicksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuickPicksBloc()..add(LoadQuickPicks()),
      child: const _QuickPicksView(),
    );
  }
}

class _QuickPicksView extends StatelessWidget {
  const _QuickPicksView();

  static const int _containerOpacity = 60;
  static const int _borderOpacity = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: BlocListener<QuickPicksBloc, QuickPicksState>(
        listenWhen: (p, c) => c.toastMessage != null,
        listener: (context, state) {
          showOverlayToast(context, state.toastSuccess ?? false, state.toastMessage!);
          context.read<QuickPicksBloc>().add(QuickPicksOperationCompleted());
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _column(
                  context,
                  title: 'Quick Picks',
                  builder: (state) => _list(
                    context,
                    songs: state.quickPicks,
                    busyId: state.busyId,
                    isLoading: state.isLoading,
                    emptyText: 'No quick picks yet — add some from the right.',
                    isQuickPick: true,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _column(
                  context,
                  title: 'All Songs',
                  builder: (state) => _list(
                    context,
                    songs: state.allSongs,
                    busyId: state.busyId,
                    isLoading: state.isLoading,
                    emptyText: 'No songs in the library yet.',
                    isQuickPick: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _column(
    BuildContext context, {
    required String title,
    required Widget Function(QuickPicksState) builder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey.shade200.withAlpha(_borderOpacity),
        ),
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200.withAlpha(_containerOpacity),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 32, shadows: _glow),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<QuickPicksBloc, QuickPicksState>(builder: (_, s) => builder(s)),
          ),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context, {
    required List<MySongs> songs,
    required int? busyId,
    required bool isLoading,
    required String emptyText,
    required bool isQuickPick,
  }) {
    if (isLoading && songs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
      );
    }
    if (songs.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final bloc = context.read<QuickPicksBloc>();
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (_, index) {
        final song = songs[index];
        return SongTile(
          isQuickPick: isQuickPick,
          song: song,
          isLoading: busyId == song.songid,
          onpressed: () {},
          onIconBtnPressed: () => bloc.add(
            isQuickPick ? RemoveFromQuickPicks(song) : AddToQuickPicks(song),
          ),
        );
      },
    );
  }
}
