import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/artist_model.dart';
import 'package:music_app_admin/models/song_model.dart';
import 'package:music_app_admin/pages/artists/repo/artist_repo.dart';

part 'artist_detail_event.dart';
part 'artist_detail_state.dart';

/// One artist: their header, the songs credited to them, and the writes that
/// change that list. Scoped to a single artist — the page owns the provider.
class ArtistDetailBloc extends Bloc<ArtistDetailEvent, ArtistDetailState> {
  ArtistDetailBloc({required this.artistId, ArtistRepo? repo})
      : _repo = repo ?? ArtistRepo(),
        super(const ArtistDetailState()) {
    on<LoadArtistDetails>(_onLoad);
    on<LoadLibrary>(_onLoadLibrary);
    on<EditArtist>(_onEditArtist);
    on<LinkSongs>(_onLinkSongs);
    on<UnlinkSong>(_onUnlinkSong);
    on<AddSongToArtist>(_onAddSong);
    on<DetailOperationCompleted>(_onCompleted);
  }

  final int artistId;
  final ArtistRepo _repo;

  Future<void> _onLoad(LoadArtistDetails event, Emitter<ArtistDetailState> emit) async {
    emit(state.copyWith(isLoading: true, loadError: () => null));
    try {
      final (artist, songs) = await _repo.getArtistDetails(artistId);
      emit(state.copyWith(artist: artist, songs: songs, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, loadError: () => '$e'));
    }
  }

  /// The full library only matters once the link dialog opens, so it is
  /// fetched then rather than on page load.
  Future<void> _onLoadLibrary(LoadLibrary event, Emitter<ArtistDetailState> emit) async {
    if (state.libraryLoading || state.library.isNotEmpty) return;
    emit(state.copyWith(libraryLoading: true));
    try {
      emit(state.copyWith(library: await _repo.getAllSongs(), libraryLoading: false));
    } catch (e) {
      emit(state.copyWith(
        libraryLoading: false,
        toastMessage: () => 'Failed to load the song library: $e',
        toastSuccess: () => false,
      ));
    }
  }

  Future<void> _onEditArtist(EditArtist event, Emitter<ArtistDetailState> emit) async {
    try {
      final message = await _repo.updateArtist(
        artistId: artistId,
        name: event.name,
        bio: event.bio,
        image: event.image,
      );
      emit(state.copyWith(toastMessage: () => message, toastSuccess: () => true));
      add(LoadArtistDetails());
    } catch (e) {
      emit(state.copyWith(toastMessage: () => '$e', toastSuccess: () => false));
    }
  }

  /// There is no batch endpoint, so this is one request per song. Partial
  /// success is reported honestly rather than rounded up to "done".
  Future<void> _onLinkSongs(LinkSongs event, Emitter<ArtistDetailState> emit) async {
    emit(state.copyWith(isLinking: true));

    var linked = 0;
    final failed = <String>[];
    for (final song in event.songs) {
      try {
        await _repo.setSongArtist(song: song, artistId: artistId);
        linked++;
      } catch (_) {
        failed.add(song.title);
      }
    }

    final plural = linked == 1 ? 'song' : 'songs';
    emit(state.copyWith(
      isLinking: false,
      // The library now has stale artist credits; drop it so the next open
      // of the dialog refetches.
      library: const [],
      toastMessage: () => failed.isEmpty
          ? '$linked $plural added to this artist.'
          : '$linked $plural added — could not add ${failed.join(', ')}.',
      toastSuccess: () => failed.isEmpty,
    ));
    add(LoadArtistDetails());
  }

  Future<void> _onUnlinkSong(UnlinkSong event, Emitter<ArtistDetailState> emit) async {
    emit(state.copyWith(busyId: () => event.song.songid));
    try {
      await _repo.setSongArtist(song: event.song);
      emit(state.copyWith(
        busyId: () => null,
        library: const [],
        toastMessage: () => '"${event.song.title}" removed from this artist.',
        toastSuccess: () => true,
      ));
      add(LoadArtistDetails());
    } catch (e) {
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => '$e',
        toastSuccess: () => false,
      ));
    }
  }

  Future<void> _onAddSong(AddSongToArtist event, Emitter<ArtistDetailState> emit) async {
    emit(state.copyWith(isUploading: true));
    try {
      final message = await _repo.addSongToArtist(
        artistId: artistId,
        title: event.title,
        cover: event.cover,
        audio: event.audio,
      );
      emit(state.copyWith(
        isUploading: false,
        library: const [],
        toastMessage: () => message,
        toastSuccess: () => true,
      ));
      add(LoadArtistDetails());
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        toastMessage: () => '$e',
        toastSuccess: () => false,
      ));
    }
  }

  void _onCompleted(DetailOperationCompleted event, Emitter<ArtistDetailState> emit) {
    emit(state.copyWith(toastMessage: () => null, toastSuccess: () => null));
  }
}
