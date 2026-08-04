import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app_admin/models/artist_model.dart';
import 'package:music_app_admin/pages/artists/repo/artist_repo.dart';

part 'artists_event.dart';
part 'artists_state.dart';

/// Drives the artists grid: load, client-side search, and create / edit /
/// delete. Everything network-facing lives in [ArtistRepo].
class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  ArtistsBloc({ArtistRepo? repo})
      : _repo = repo ?? ArtistRepo(),
        super(const ArtistsState()) {
    on<LoadArtists>(_onLoad);
    on<FilterArtists>(_onFilter);
    on<CreateArtist>(_onCreate);
    on<UpdateArtist>(_onUpdate);
    on<DeleteArtist>(_onDelete);
    on<ArtistOperationCompleted>(_onCompleted);
  }

  final ArtistRepo _repo;

  Future<void> _onLoad(LoadArtists event, Emitter<ArtistsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      emit(state.copyWith(artists: await _repo.getArtists(), isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: () => 'Failed to fetch artists: $e',
        toastSuccess: () => false,
      ));
    }
  }

  void _onFilter(FilterArtists event, Emitter<ArtistsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onCreate(CreateArtist event, Emitter<ArtistsState> emit) async {
    await _write(
      emit,
      () => _repo.createArtist(name: event.name, bio: event.bio, image: event.image),
    );
  }

  Future<void> _onUpdate(UpdateArtist event, Emitter<ArtistsState> emit) async {
    await _write(
      emit,
      busyId: event.artist.artistId,
      () => _repo.updateArtist(
        artistId: event.artist.artistId,
        name: event.name,
        bio: event.bio,
        image: event.image,
      ),
    );
  }

  Future<void> _onDelete(DeleteArtist event, Emitter<ArtistsState> emit) async {
    await _write(
      emit,
      busyId: event.artist.artistId,
      () => _repo.deleteArtist(event.artist.artistId),
    );
  }

  /// Every write follows the same shape: mark the row busy, call the repo,
  /// raise the server's message as a toast, then reload so counts stay honest.
  Future<void> _write(
    Emitter<ArtistsState> emit,
    Future<String> Function() call, {
    int? busyId,
  }) async {
    emit(state.copyWith(busyId: () => busyId));
    try {
      final message = await call();
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => message,
        toastSuccess: () => true,
      ));
      add(LoadArtists());
    } catch (e) {
      emit(state.copyWith(
        busyId: () => null,
        toastMessage: () => '$e',
        toastSuccess: () => false,
      ));
    }
  }

  void _onCompleted(ArtistOperationCompleted event, Emitter<ArtistsState> emit) {
    emit(state.copyWith(toastMessage: () => null, toastSuccess: () => null));
  }
}
