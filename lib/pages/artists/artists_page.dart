import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app_admin/models/artist_model.dart';
import 'package:music_app_admin/pages/artists/bloc/artists_bloc.dart';
import 'package:music_app_admin/pages/artists/widgets/artist_card.dart';
import 'package:music_app_admin/pages/artists/widgets/artist_form_dialog.dart';
import 'package:music_app_admin/widgets/top_right_msg.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// Browse every artist, and create / edit / delete them.
class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistsBloc()..add(LoadArtists()),
      child: const _ArtistsView(),
    );
  }
}

class _ArtistsView extends StatelessWidget {
  const _ArtistsView();

  /// Deleting an artist only drops the credit — `delete_songs` is never sent
  /// as 1 — so the wording has to make that plain.
  Future<void> _confirmDelete(BuildContext context, Artist artist) async {
    final bloc = context.read<ArtistsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this artist?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '"${artist.name}" will be removed, along with their uploaded banner. '
          'Their ${artist.totalSongs} song(s) stay in the library — they just '
          'lose this credit.',
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
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) bloc.add(DeleteArtist(artist));
  }

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
          child: BlocListener<ArtistsBloc, ArtistsState>(
            listenWhen: (previous, current) => current.toastMessage != null,
            listener: (context, state) {
              showOverlayToast(
                  context, state.toastSuccess ?? false, state.toastMessage!);
              context.read<ArtistsBloc>().add(ArtistOperationCompleted());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 20),
                _search(context),
                const SizedBox(height: 20),
                Expanded(child: _grid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('Artists',
              style: TextStyle(color: Colors.white, fontSize: 32, shadows: _glow)),
          const SizedBox(width: 12),
          BlocBuilder<ArtistsBloc, ArtistsState>(
            buildWhen: (p, c) => p.artists.length != c.artists.length,
            builder: (context, state) => Text(
              '${state.artists.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<ArtistsBloc>().add(LoadArtists()),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              final bloc = context.read<ArtistsBloc>();
              showArtistFormDialog(
                context,
                onSubmit: (name, bio, image) =>
                    bloc.add(CreateArtist(name, bio, image)),
              );
            },
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.add, color: Colors.white, shadows: _glow),
            label: const Text('New artist',
                style: TextStyle(color: Colors.white, fontSize: 18, shadows: _glow)),
          ),
        ],
      );

  Widget _search(BuildContext context) => TextField(
        onChanged: (value) => context.read<ArtistsBloc>().add(FilterArtists(value)),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Search artists by name',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      );

  Widget _grid(BuildContext context) {
    return BlocBuilder<ArtistsBloc, ArtistsState>(
      builder: (context, state) {
        if (state.isLoading && state.artists.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
          );
        }

        final artists = state.visibleArtists;
        if (artists.isEmpty) {
          return Center(
            child: Text(
              state.artists.isEmpty
                  ? 'No artists yet — create one to get started.'
                  : 'No artist matches "${state.query}".',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // ~280 per card, so the grid reflows from one column on a narrow
            // window up to six on a wide desktop.
            final columns = (constraints.maxWidth / 280).floor().clamp(1, 6);

            return GridView.builder(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 16 / 9,
              ),
              itemCount: artists.length,
              itemBuilder: (_, index) {
                final artist = artists[index];
                return ArtistCard(
                  artist: artist,
                  isBusy: state.busyId == artist.artistId,
                  onTap: () => context.push('/artists/${artist.artistId}'),
                  onEdit: () {
                    final bloc = context.read<ArtistsBloc>();
                    showArtistFormDialog(
                      context,
                      artist: artist,
                      onSubmit: (name, bio, image) =>
                          bloc.add(UpdateArtist(artist, name, bio, image)),
                    );
                  },
                  onDelete: () => _confirmDelete(context, artist),
                );
              },
            );
          },
        );
      },
    );
  }
}
