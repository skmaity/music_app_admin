import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/pages/all_songs/bloc/all_songs_bloc.dart';
import 'package:music_app_admin/pages/all_songs/edit_song_dialog.dart';
import 'package:music_app_admin/pages/quick_picks/song_tile.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// Home page section listing every song, with edit and delete on each row.
class AllSongsSection extends StatefulWidget {
  const AllSongsSection({super.key});

  @override
  State<AllSongsSection> createState() => _AllSongsSectionState();
}

class _AllSongsSectionState extends State<AllSongsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AllSongsBloc>().add(LoadAllSongs());
    });
  }

  Future<void> _confirmDelete(MySongs song) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this song?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '"${song.title}" by ${song.artist} will be removed for good, '
          'along with its uploaded audio and cover.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white70)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AllSongsBloc>().add(DeleteSong(song));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AllSongsBloc, AllSongsState>(
      listenWhen: (previous, current) => current.toastMessage != null,
      listener: (context, state) {
        if (state.toastMessage != null) {
          showOverlayToast(context, state.toastSuccess ?? false, state.toastMessage!);
          context.read<AllSongsBloc>().add(SongOperationCompleted());
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.shade200.withAlpha(70)),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade200.withAlpha(60),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  const Text(
                    'All Songs',
                    style: TextStyle(
                        color: Colors.white, fontSize: 32, shadows: _glow),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<AllSongsBloc, AllSongsState>(
                    builder: (context, state) {
                      return Text(
                        '${state.songs.length}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      );
                    }
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => context.read<AllSongsBloc>().add(LoadAllSongs()),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextField(
                onChanged: (value) => context.read<AllSongsBloc>().add(FilterSongs(value)),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search by title or artist',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<AllSongsBloc, AllSongsState>(
                builder: (context, state) {
                  if (state.isLoading && state.songs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 1),
                    );
                  }

                  final songs = state.visibleSongs;
                  if (songs.isEmpty) {
                    return Center(
                      child: Text(
                        state.songs.isEmpty
                            ? 'No songs yet — add one from "Add Songs".'
                            : 'No song matches "${state.query}".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (_, index) => _songRow(songs[index], state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _songRow(MySongs song, AllSongsState state) => SongTile(
    song: song,
    onIconBtnPressed: null,
    onpressed: null,
    trailing: state.busyId == song.songid
        ? const Padding(
            padding: EdgeInsets.only(right: 7),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 0.5),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit song',
                hoverColor: Colors.white24,
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => showEditSongDialog(context, song),
              ),
              IconButton(
                tooltip: 'Delete song',
                hoverColor: Colors.redAccent.withAlpha(60),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent),
                onPressed: () => _confirmDelete(song),
              ),
            ],
          ),
  );
}
