part of 'artists_bloc.dart';

class ArtistsState extends Equatable {
  final List<Artist> artists;
  final String query;
  final bool isLoading;

  /// The one artist currently being written, so a single card spins rather
  /// than the whole grid.
  final int? busyId;
  final String? toastMessage;
  final bool? toastSuccess;

  const ArtistsState({
    this.artists = const [],
    this.query = '',
    this.isLoading = false,
    this.busyId,
    this.toastMessage,
    this.toastSuccess,
  });

  List<Artist> get visibleArtists {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return artists;
    return artists.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  ArtistsState copyWith({
    List<Artist>? artists,
    String? query,
    bool? isLoading,
    int? Function()? busyId,
    String? Function()? toastMessage,
    bool? Function()? toastSuccess,
  }) {
    return ArtistsState(
      artists: artists ?? this.artists,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      busyId: busyId != null ? busyId() : this.busyId,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
      toastSuccess: toastSuccess != null ? toastSuccess() : this.toastSuccess,
    );
  }

  @override
  List<Object?> get props => [artists, query, isLoading, busyId, toastMessage, toastSuccess];
}
