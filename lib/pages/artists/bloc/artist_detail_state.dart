part of 'artist_detail_bloc.dart';

class ArtistDetailState extends Equatable {
  final Artist? artist;
  final List<MySongs> songs;
  final bool isLoading;

  /// Set when the artist could not be fetched at all — a bad id in the URL, or
  /// a row that has since been deleted.
  final String? loadError;

  /// The one song currently being written.
  final int? busyId;

  /// The whole library, loaded lazily the first time the link dialog opens.
  final List<MySongs> library;
  final bool libraryLoading;

  final bool isLinking;
  final bool isUploading;

  final String? toastMessage;
  final bool? toastSuccess;

  const ArtistDetailState({
    this.artist,
    this.songs = const [],
    this.isLoading = false,
    this.loadError,
    this.busyId,
    this.library = const [],
    this.libraryLoading = false,
    this.isLinking = false,
    this.isUploading = false,
    this.toastMessage,
    this.toastSuccess,
  });

  /// Songs already credited here, so the link dialog can show them checked and
  /// disabled instead of silently hiding them.
  Set<int> get creditedIds => songs.map((s) => s.songid).toSet();

  ArtistDetailState copyWith({
    Artist? artist,
    List<MySongs>? songs,
    bool? isLoading,
    String? Function()? loadError,
    int? Function()? busyId,
    List<MySongs>? library,
    bool? libraryLoading,
    bool? isLinking,
    bool? isUploading,
    String? Function()? toastMessage,
    bool? Function()? toastSuccess,
  }) {
    return ArtistDetailState(
      artist: artist ?? this.artist,
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      loadError: loadError != null ? loadError() : this.loadError,
      busyId: busyId != null ? busyId() : this.busyId,
      library: library ?? this.library,
      libraryLoading: libraryLoading ?? this.libraryLoading,
      isLinking: isLinking ?? this.isLinking,
      isUploading: isUploading ?? this.isUploading,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
      toastSuccess: toastSuccess != null ? toastSuccess() : this.toastSuccess,
    );
  }

  @override
  List<Object?> get props => [
        artist,
        songs,
        isLoading,
        loadError,
        busyId,
        library,
        libraryLoading,
        isLinking,
        isUploading,
        toastMessage,
        toastSuccess,
      ];
}
