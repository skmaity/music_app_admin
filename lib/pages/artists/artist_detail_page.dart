import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app_admin/models/artist_model.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/pages/artists/bloc/artist_detail_bloc.dart';
import 'package:music_app_admin/pages/artists/widgets/add_artist_song_dialog.dart';
import 'package:music_app_admin/pages/artists/widgets/artist_form_dialog.dart';
import 'package:music_app_admin/pages/artists/widgets/link_songs_dialog.dart';
import 'package:music_app_admin/pages/quick_picks/song_tile.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// One artist: banner header, the songs credited to them, and the two ways to
/// add more — attach something already in the library, or upload a new file.
class ArtistDetailPage extends StatelessWidget {
  const ArtistDetailPage({super.key, required this.artistId});

  /// Null when the id in the URL was not a number.
  final int? artistId;

  @override
  Widget build(BuildContext context) {
    final id = artistId;
    if (id == null) return const _Shell(child: _NotFound());

    return BlocProvider(
      create: (_) => ArtistDetailBloc(artistId: id)..add(LoadArtistDetails()),
      child: const _ArtistDetailView(),
    );
  }
}

/// Background GIF → scrim → content, the same shell every page uses.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

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
        child: Container(color: Colors.black.withAlpha(70), child: child),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'That artist could not be found.',
            style: TextStyle(color: Colors.white, fontSize: 24, shadows: _glow),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.canPop() ? context.pop() : context.go('/artists'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text('Back to artists',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _ArtistDetailView extends StatelessWidget {
  const _ArtistDetailView();

  /// Unlinking leaves the song in the library — it just becomes unattributed.
  Future<void> _confirmUnlink(BuildContext context, MySongs song) async {
    final bloc = context.read<ArtistDetailBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove from this artist?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '"${song.title}" stays in the library along with its audio and cover. '
          'It just stops being credited here, and shows as "Unknown Artist" '
          'until you file it somewhere else.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.link_off, size: 18),
            label: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) bloc.add(UnlinkSong(song));
  }

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: BlocListener<ArtistDetailBloc, ArtistDetailState>(
        listenWhen: (previous, current) => current.toastMessage != null,
        listener: (context, state) {
          showOverlayToast(
              context, state.toastSuccess ?? false, state.toastMessage!);
          context.read<ArtistDetailBloc>().add(DetailOperationCompleted());
        },
        child: BlocBuilder<ArtistDetailBloc, ArtistDetailState>(
          builder: (context, state) {
            if (state.loadError != null && state.artist == null) {
              return const _NotFound();
            }
            final artist = state.artist;
            if (artist == null) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 1),
              );
            }

            return Column(
              children: [
                _Banner(artist: artist),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _actions(context, artist, state),
                        const SizedBox(height: 20),
                        Expanded(child: _songs(context, state)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Uploading is the primary action; attaching an existing song is the
  /// quieter one, so only the upload carries the glow.
  Widget _actions(BuildContext context, Artist artist, ArtistDetailState state) => Row(
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onPressed: () => showLinkSongsDialog(context, artist.name),
            icon: const Icon(Icons.playlist_add, size: 18),
            label: const Text('Add existing songs', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () => showAddArtistSongDialog(context, artist.name),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.cloud_upload_outlined,
                color: Colors.white, shadows: _glow),
            label: const Text('Upload new song',
                style:
                    TextStyle(color: Colors.white, fontSize: 18, shadows: _glow)),
          ),
          const Spacer(),
          if (state.isLinking || state.isUploading)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 0.5),
              ),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<ArtistDetailBloc>().add(LoadArtistDetails()),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      );

  Widget _songs(BuildContext context, ArtistDetailState state) {
    if (state.isLoading && state.songs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
      );
    }

    if (state.songs.isEmpty) {
      return const Center(
        child: Text(
          'No songs credited to this artist yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey.shade200.withAlpha(70)),
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200.withAlpha(60),
      ),
      child: ListView.builder(
        itemCount: state.songs.length,
        itemBuilder: (_, index) {
          final song = state.songs[index];
          return SongTile(
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
                : IconButton(
                    tooltip: 'Remove from this artist',
                    hoverColor: Colors.redAccent.withAlpha(60),
                    icon: const Icon(Icons.link_off, color: Colors.redAccent),
                    onPressed: () => _confirmUnlink(context, song),
                  ),
          );
        },
      ),
    );
  }
}

/// Full-width banner with the name over it, plus back and edit.
class _Banner extends StatelessWidget {
  const _Banner({required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final count = artist.totalSongs;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _image(),
          // Strong enough that the name stays legible over any photo.
          Container(color: Colors.black.withAlpha(120)),
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 32, shadows: _glow),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 1 ? '1 song' : '$count songs',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                if (artist.bio != null && artist.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    artist.bio!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 16,
            child: IconButton(
              tooltip: 'Back',
              hoverColor: Colors.white24,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/artists'),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            top: 20,
            right: 16,
            child: IconButton(
              tooltip: 'Edit artist',
              hoverColor: Colors.white24,
              onPressed: () {
                final bloc = context.read<ArtistDetailBloc>();
                showArtistFormDialog(
                  context,
                  artist: artist,
                  onSubmit: (name, bio, image) =>
                      bloc.add(EditArtist(name, bio, image)),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    final url = artist.imageLink;
    if (url == null) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => _placeholder(),
      placeholder: (_, __) => _placeholder(),
    );
  }

  Widget _placeholder() => ColoredBox(
        color: Colors.grey.shade200.withAlpha(60),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white70, size: 64),
        ),
      );
}
