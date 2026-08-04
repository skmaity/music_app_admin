import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/pages/artists/bloc/artist_detail_bloc.dart';

const _glow = [Shadow(blurRadius: 9, color: Colors.white, offset: Offset(0, 0))];

/// Mounted on the root navigator, above the [ArtistDetailBloc] provider, so
/// the bloc is read here and handed over directly.
Future<void> showLinkSongsDialog(BuildContext context, String artistName) {
  final bloc = context.read<ArtistDetailBloc>()..add(LoadLibrary());
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(120),
    builder: (_) => LinkSongsDialog(bloc: bloc, artistName: artistName),
  );
}

/// Picks songs already in the library and credits them to this artist.
class LinkSongsDialog extends StatefulWidget {
  const LinkSongsDialog({
    super.key,
    required this.bloc,
    required this.artistName,
  });

  final ArtistDetailBloc bloc;
  final String artistName;

  @override
  State<LinkSongsDialog> createState() => _LinkSongsDialogState();
}

class _LinkSongsDialogState extends State<LinkSongsDialog> {
  final _selected = <int>{};
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<MySongs> _visible(List<MySongs> library) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return library;
    return library
        .where((s) =>
            s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q))
        .toList();
  }

  void _confirm() {
    final songs = widget.bloc.state.library
        .where((s) => _selected.contains(s.songid))
        .toList();
    if (songs.isEmpty) return;
    widget.bloc.add(LinkSongs(songs));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 520,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200.withAlpha(70), width: 1),
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200.withAlpha(60),
            ),
            child: BlocBuilder<ArtistDetailBloc, ArtistDetailState>(
              bloc: widget.bloc,
              builder: (context, state) {
                final credited = state.creditedIds;
                final visible = _visible(state.library);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add existing songs',
                        style: TextStyle(
                            color: Colors.white, fontSize: 24, shadows: _glow)),
                    const SizedBox(height: 4),
                    Text(
                      _selected.isEmpty
                          ? 'A song belongs to one artist — adding it here moves '
                              'it to ${widget.artistName}.'
                          : '${_selected.length} selected',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Search by title or artist',
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
                    ),
                    const SizedBox(height: 12),
                    Flexible(child: _list(state, visible, credited)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(60),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withAlpha(20),
                            disabledForegroundColor: Colors.white38,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                          ),
                          onPressed: _selected.isEmpty ? null : _confirm,
                          icon: const Icon(Icons.playlist_add, size: 18),
                          label: Text(_selected.isEmpty
                              ? 'Add songs'
                              : 'Add ${_selected.length} song'
                                  '${_selected.length == 1 ? '' : 's'}'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(ArtistDetailState state, List<MySongs> visible, Set<int> credited) {
    if (state.libraryLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
        ),
      );
    }

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            state.library.isEmpty
                ? 'The library is empty — add a song first.'
                : 'No song matches "$_query".',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: visible.length,
      itemBuilder: (_, index) {
        final song = visible[index];
        // Songs already on this artist stay listed but locked, so their
        // absence from the pickable set is explained rather than mysterious.
        final already = credited.contains(song.songid);

        return CheckboxListTile(
          value: already || _selected.contains(song.songid),
          onChanged: already
              ? null
              : (checked) => setState(() => checked == true
                  ? _selected.add(song.songid)
                  : _selected.remove(song.songid)),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.white,
          checkColor: Colors.black,
          side: const BorderSide(color: Colors.white54),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: already ? Colors.white38 : Colors.white),
          ),
          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: already ? Colors.white24 : Colors.white70, fontSize: 12),
          ),
          secondary: already
              ? const Text('Already added',
                  style: TextStyle(color: Colors.white38, fontSize: 11))
              : null,
        );
      },
    );
  }
}
